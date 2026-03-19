//+------------------------------------------------------------------+
//| ENV_FIBO6 - Fibonacci Strategy with Trend Line Flatness - v1.00  |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;
COrderInfo     ord;

//==================== INPUTS ====================//

input double   RiskPercent            = 1.0;
input double   MaxDrawdownPercent     = 30.0;
input int      MaxConsecutiveLoss     = 5;

input int      ATR_Period             = 14;
input double   inpDeviation           = 1.5;

input int      SpreadMaxPoints        = 80;

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;
input int      TrailingStepPoints     = 50;

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1; // Timeframe de 1 hora
input int      MagicNumber            = 20250302;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
double CachedATR    = 0.0;

// Custom Indicator Handle
int FiboInd_Handle  = INVALID_HANDLE;

// Buffer Mapping for ATR Trend env_fibo.mq5
// Buffer 0: lineup (Up trend line / Smin)
// Buffer 1: linedn (Down trend line / Smax)
// Buffer 4: Fibo 23.6%
// Buffer 8: Fibo 76.4%
// Buffer 9: ATR

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   // 1) Handle para o indicador customizado ATR Trend env_fibo
   FiboInd_Handle = iCustom(_Symbol, Timeframe, "ATR Trend env_fibo", ATR_Period, inpDeviation);
   if(FiboInd_Handle == INVALID_HANDLE) return(INIT_FAILED);

   // 2) O ATR_Handle aponta para o buffer 9 do indicador customizado
   ATR_Handle = FiboInd_Handle;

   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(FiboInd_Handle != INVALID_HANDLE) IndicatorRelease(FiboInd_Handle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   if(!UpdateIndicators()) return;

   // Gestão de posições em cada tick
   ManagePosition();

   // 3) Obter níveis atuais e anteriores do indicador
   double f236_buf[], f764_buf[], up_line_buf[], dn_line_buf[];
   ArraySetAsSeries(f236_buf, true);
   ArraySetAsSeries(f764_buf, true);
   ArraySetAsSeries(up_line_buf, true);
   ArraySetAsSeries(dn_line_buf, true);

   // Precisamos de 2 barras para verificar o nivel "mesmo preço há 2 barras"
   if(CopyBuffer(FiboInd_Handle, 4, 0, 2, f236_buf) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 8, 0, 2, f764_buf) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 0, 0, 2, up_line_buf) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 1, 0, 2, dn_line_buf) <= 0) return;

   double f236 = f236_buf[0];
   double f764 = f764_buf[0];

   if(f236 == EMPTY_VALUE || f764 == EMPTY_VALUE) return;

   // Reconstituir os limites Smax e Smin a partir dos níveis Fibo (pois up/dn_line podem estar mascarados)
   // f236 = Smax - 0.236*(Smax-Smin) => f236 = 0.764*Smax + 0.236*Smin
   // f764 = Smax - 0.764*(Smax-Smin) => f764 = 0.236*Smax + 0.764*Smin
   double range = (f236 - f764) / (0.764 - 0.236);
   double smax = f236 + 0.236 * range;
   double smin = smax - range;

   // 4) Lógica de Expiração de Ordens Pendentes
   CheckPendingOrderExpiry(smax, smin);

   if(!IsNewBar()) return;

   if(!CheckSpread()) return;
   if(!CheckDrawdown()) return;
   if(!CheckConsecutiveLosses()) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // 5) Regra operacional: apenas 1 ordem pendente/posição por vez
   if(CountOrders() == 0 && CountPositions() == 0)
   {
      // Regra de Compra:
      // Preço cruzar 23.6% (Buy Stop se preço abaixo)
      // Down trend line (Buffer 1) no mesmo preço há 2 barras
      // Nota: dn_line_buf contém o valor do buffer 1, que é preenchido em downtrend.
      // Se estiver flat, usamos para confirmação.
      if(ask < f236 && dn_line_buf[0] != EMPTY_VALUE && dn_line_buf[1] != EMPTY_VALUE && NormalizeDouble(dn_line_buf[0] - dn_line_buf[1], _Digits) == 0)
      {
         // TP na borda ATR superior (Smax), SL na inferior (Smin)
         PlacePendingStop(POSITION_TYPE_BUY, f236, smax, smin, "Fibo 23.6 Buy Stop (Flat)");
      }

      // Regra de Venda:
      // Preço cruzar 76.4% (Sell Stop se preço acima)
      // Up trend line (Buffer 0) no mesmo preço há 2 barras
      else if(bid > f764 && up_line_buf[0] != EMPTY_VALUE && up_line_buf[1] != EMPTY_VALUE && NormalizeDouble(up_line_buf[0] - up_line_buf[1], _Digits) == 0)
      {
         // TP na borda ATR inferior (Smin), SL na superior (Smax)
         PlacePendingStop(POSITION_TYPE_SELL, f764, smin, smax, "Fibo 76.4 Sell Stop (Flat)");
      }
   }
}

//==================== TRADE ====================//

void CheckPendingOrderExpiry(double smax, double smin)
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         if(OrderGetInteger(ORDER_MAGIC) != MagicNumber || OrderGetString(ORDER_SYMBOL) != _Symbol) continue;

         double tp = OrderGetDouble(ORDER_TP);
         long type = OrderGetInteger(ORDER_TYPE);

         bool shouldExpire = false;

         // A ordem pendente deve expirar se o TP for zero ou inconsistente com a evolução da borda ATR alvo
         if(type == ORDER_TYPE_BUY_STOP)
         {
            if(tp <= 0 || smax <= 0 || NormalizeDouble(tp - smax, _Digits) != 0) shouldExpire = true;
         }
         else if(type == ORDER_TYPE_SELL_STOP)
         {
            if(tp <= 0 || smin <= 0 || NormalizeDouble(tp - smin, _Digits) != 0) shouldExpire = true;
         }

         if(shouldExpire)
         {
            trade.OrderDelete(ticket);
            Print("Pending order expired due to Trend Line evolution or zero TP.");
         }
      }
   }
}

void PlacePendingStop(ENUM_POSITION_TYPE type, double entry, double tp, double sl, string comment)
{
   double lot = CalculateLot(entry, sl);
   if(lot <= 0) return;

   // Verifica validade básica do TP e SL
   if(tp <= 0 || sl <= 0 || tp == EMPTY_VALUE || sl == EMPTY_VALUE) return;

   bool success = false;
   if(type == POSITION_TYPE_BUY)
   {
      // Garantir que é um Buy Stop (preço < entry)
      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) < entry)
         success = trade.BuyStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), ORDER_TIME_GTC, 0, comment);
   }
   else
   {
      // Garantir que é um Sell Stop (preço > entry)
      if(SymbolInfoDouble(_Symbol, SYMBOL_BID) > entry)
         success = trade.SellStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), ORDER_TIME_GTC, 0, comment);
   }

   if(!success && trade.ResultRetcode() != 0)
      Print(comment + " Error: ", trade.ResultRetcode());
}

//==================== HELPERS ====================//

bool UpdateIndicators()
{
   double buf[];
   ArraySetAsSeries(buf, true);
   // Buffer 9 do indicador customizado contém o ATR calculado
   if(CopyBuffer(ATR_Handle, 9, 0, 1, buf) <= 0) return false;
   CachedATR = buf[0];
   return (CachedATR > 0);
}

bool IsNewBar()
{
   static datetime last=0;
   datetime current=iTime(_Symbol, Timeframe, 0);
   if(current!=last) { last=current; return true; }
   return false;
}

bool CheckSpread()
{
   double spread=(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID))/_Point;
   return (spread<=SpreadMaxPoints);
}

bool CheckDrawdown()
{
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity>PeakEquity) PeakEquity=equity;
   double dd=(PeakEquity-equity)/PeakEquity*100.0;
   return (dd<MaxDrawdownPercent);
}

bool CheckConsecutiveLosses()
{
   HistorySelect(0, TimeCurrent());
   int total = HistoryDealsTotal();
   int count = 0;
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != MagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_SWAP) + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      if(profit < 0) count++;
      else break;
   }
   return (count < MaxConsecutiveLoss);
}

int CountOrders()
{
   int count = 0;
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber && OrderGetString(ORDER_SYMBOL)==_Symbol)
            count++;
   }
   return count;
}

int CountPositions()
{
   int count = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(pos.SelectByIndex(i))
         if(pos.Magic()==MagicNumber && pos.Symbol()==_Symbol)
            count++;
   return count;
}

double CalculateLot(double entry, double sl)
{
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE)*RiskPercent/100.0;
   double stopDist  = MathAbs(entry-sl);
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize<=0 || tickValue<=0 || stopDist<=0) return 0;
   double costPerLot = (stopDist/tickSize)*tickValue;
   if(costPerLot<=0) return 0;
   double lot = riskMoney/costPerLot;
   double step   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lot = MathFloor(lot/step)*step;
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(minLot, MathMin(maxLot, lot));
   int digits = (int)-MathLog10(step);
   if(digits < 0) digits = 0;
   return NormalizeDouble(lot, digits);
}

void ManagePosition()
{
   if(CachedATR <= 0) return;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic()!=MagicNumber || pos.Symbol()!=_Symbol) continue;

      bool isBuy = (pos.PositionType()==POSITION_TYPE_BUY);
      double price = isBuy ? bid : ask;
      double open = pos.PriceOpen();
      double sl = pos.StopLoss();
      double tp = pos.TakeProfit();
      double targetSL = sl;
      bool needsModify = false;

      // Break-even
      if(UseBreakEven && MathAbs(price - open) >= CachedATR * BreakEvenTriggerATR)
      {
         if(isBuy && (targetSL < open || targetSL == 0)) { targetSL = open; needsModify = true; }
         if(!isBuy && (targetSL > open || targetSL == 0)) { targetSL = open; needsModify = true; }
      }

      // Trailing
      if(UseTrailingATR)
      {
         double trailingSL = isBuy ? (bid - CachedATR * TrailingATRMultiplier) : (ask + CachedATR * TrailingATRMultiplier);
         if(isBuy && trailingSL > targetSL + TrailingStepPoints * _Point) { targetSL = trailingSL; needsModify = true; }
         if(!isBuy && (targetSL == 0 || trailingSL < targetSL - TrailingStepPoints * _Point)) { targetSL = trailingSL; needsModify = true; }
      }

      if(needsModify)
         trade.PositionModify(pos.Ticket(), NormalizeDouble(targetSL, _Digits), NormalizeDouble(tp, _Digits));
   }
}
