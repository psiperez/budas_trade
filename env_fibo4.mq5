//+------------------------------------------------------------------+
//| ENV_FIBO4 - Fibonacci Indicator Strategy - Version 1.00          |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;

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

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      MagicNumber            = 20250228;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
double CachedATR    = 0.0;

// Custom Indicator Handle
int FiboInd_Handle  = INVALID_HANDLE;

// Buffer Mapping for ATR Trend env_fibo.mq5
// Buffer 0: lineup (Smin in uptrend)
// Buffer 1: linedn (Smax in downtrend)
// Buffer 2: arrowup
// Buffer 3: arrowdn
// Buffer 4: Fibo 23.6%
// Buffer 5: Fibo 38.2%
// Buffer 6: Fibo 50.0%
// Buffer 7: Fibo 61.8%
// Buffer 8: Fibo 76.4%

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   // 1) Handle para o indicador de ATR padrão (usado para gestão de stop)
   ATR_Handle = iATR(_Symbol, Timeframe, ATR_Period);
   if(ATR_Handle == INVALID_HANDLE) return(INIT_FAILED);

   // 2) Handle para o indicador customizado ATR Trend env_fibo
   FiboInd_Handle = iCustom(_Symbol, Timeframe, "ATR Trend env_fibo", ATR_Period, inpDeviation);
   if(FiboInd_Handle == INVALID_HANDLE) return(INIT_FAILED);

   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ATR_Handle != INVALID_HANDLE) IndicatorRelease(ATR_Handle);
   if(FiboInd_Handle != INVALID_HANDLE) IndicatorRelease(FiboInd_Handle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   if(!UpdateIndicators()) return;

   // Gestão de posições em cada tick
   ManagePosition();

   if(!IsNewBar()) return;

   if(!CheckSpread()) return;
   if(!CheckDrawdown()) return;
   if(!CheckConsecutiveLosses()) return;

   // 3) Recuperar níveis do indicador customizado
   double fibo236[], fibo618[], lineup[], linedn[];
   ArraySetAsSeries(fibo236, true);
   ArraySetAsSeries(fibo618, true);
   ArraySetAsSeries(lineup, true);
   ArraySetAsSeries(linedn, true);

   // Buffer 4: 23.6%, Buffer 7: 61.8%
   // Buffer 0: lineup (Smin), Buffer 1: linedn (Smax)
   if(CopyBuffer(FiboInd_Handle, 4, 1, 1, fibo236) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 7, 1, 1, fibo618) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 0, 1, 1, lineup) <= 0) return;
   if(CopyBuffer(FiboInd_Handle, 1, 1, 1, linedn) <= 0) return;

   double f236 = fibo236[0];
   double f618 = fibo618[0];

   // Identificar Smin e Smax (o indicador preenche lineup em uptrend e linedn em downtrend)
   // Mas os níveis fibo são calculados entre Smin e Smax globais.
   // No meu indicador fixado, smin e smax são persistentes.
   // Vou assumir que f236 e f618 são válidos se f236 != EMPTY_VALUE.
   if(f236 == EMPTY_VALUE || f618 == EMPTY_VALUE) return;

   // Precisamos das bordas do ATR para TP e SL
   // No Trend Envelope, TP é a borda mais próxima e SL a mais distante.
   // Para Buy Stop no f236: TP=Smax, SL=Smin.
   // No indicador, Fibo levels são baseados em (Smax - Smin).
   // f236 = Smax - 0.236*Range. f618 = Smax - 0.618*Range.
   // Portanto Smax > f236 > f618 > Smin.

   // Recuperar Smin e Smax das fórmulas do indicador:
   // f236 = Smax - 0.236*(Smax-Smin) => f236 = 0.764*Smax + 0.236*Smin
   // f618 = Smax - 0.618*(Smax-Smin) => f618 = 0.382*Smax + 0.618*Smin
   // Resolvendo para Smax e Smin:
   double range = (f236 - f618) / (0.618 - 0.236);
   double smax = f236 + 0.236 * range;
   double smin = smax - range;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // 4) Regra operacional: apenas 1 ordem pendente por vez (tipo stop)
   if(CountOrders() == 0 && CountPositions() == 0)
   {
      // Regra 1: Preço cruza 23.6% -> Compra
      // Se preço atual abaixo de 23.6%, coloca Buy Stop.
      if(ask < f236)
         PlacePendingStop(POSITION_TYPE_BUY, f236, smax, smin, "Fibo 23.6 Buy Stop");

      // Regra 2: Preço cruza 61.8% -> Venda
      // Se preço atual acima de 61.8%, coloca Sell Stop.
      else if(bid > f618)
         PlacePendingStop(POSITION_TYPE_SELL, f618, smin, smax, "Fibo 61.8 Sell Stop");
   }
}

//==================== TRADE ====================//

void PlacePendingStop(ENUM_POSITION_TYPE type, double entry, double tp, double sl, string comment)
{
   double lot = CalculateLot(entry, sl);
   if(lot <= 0) return;

   bool success = false;
   if(type == POSITION_TYPE_BUY)
      success = trade.BuyStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), ORDER_TIME_GTC, 0, comment);
   else
      success = trade.SellStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), ORDER_TIME_GTC, 0, comment);

   if(!success)
      Print(comment + " Error: ", trade.ResultRetcode());
}

//==================== HELPERS ====================//

bool UpdateIndicators()
{
   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(ATR_Handle, 0, 0, 1, buf) <= 0) return false;
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
