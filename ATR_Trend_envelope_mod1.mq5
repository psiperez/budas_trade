//+------------------------------------------------------------------+
//| ATR_Trend_envelope_mod1 - EA with Fibo and Trend Persistence    |
//+------------------------------------------------------------------+
#property strict
#property version   "1.20"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;
COrderInfo     ord;

//==================== INPUTS ====================//

input double   RiskPercent            = 1.0;
input double   MaxDrawdownPercent     = 30.0;
input int      MaxConsecutiveLoss     = 5;

input int      ATR_Period             = 14;     
input double   RR_Ratio               = 2.5;

input int      SpreadMaxPoints        = 80;     

input int      inpAtrPeriod           = 14;     // ATR period for Trend Envelope
input double   inpDeviation           = 1.5;    // ATR multiplication factor for Trend Envelope

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      MagicNumber            = 20250225;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
int Fibo_Handle     = INVALID_HANDLE;

double CachedATR    = 0.0;

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   ATR_Handle = iATR(_Symbol, Timeframe, ATR_Period);
   if(ATR_Handle == INVALID_HANDLE) return(INIT_FAILED);

   // Usamos o indicador customizado para garantir sincronização de estado
   Fibo_Handle = iCustom(_Symbol, Timeframe, "ATR_Trend_envo_fibo", inpAtrPeriod, inpDeviation);
   if(Fibo_Handle == INVALID_HANDLE) return(INIT_FAILED);

   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ATR_Handle != INVALID_HANDLE) IndicatorRelease(ATR_Handle);
   if(Fibo_Handle != INVALID_HANDLE) IndicatorRelease(Fibo_Handle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateIndicators();
   ManagePosition();

   if(!IsNewBar()) return;

   if(!CheckSpread()) return;
   if(!CheckDrawdown()) return;
   if(!CheckConsecutiveLosses()) return; 

   // Coletamos dados do indicador (Shift 1 = barra fechada, Shift 2 = barra anterior)
   double upLine[], dnLine[], f236[], f618[], smin[], smax[];
   ArraySetAsSeries(upLine, true);
   ArraySetAsSeries(dnLine, true);
   ArraySetAsSeries(f236, true);
   ArraySetAsSeries(f618, true);
   ArraySetAsSeries(smin, true);
   ArraySetAsSeries(smax, true);

   if(CopyBuffer(Fibo_Handle, 0, 1, 2, upLine) < 2) return;
   if(CopyBuffer(Fibo_Handle, 1, 1, 2, dnLine) < 2) return;
   if(CopyBuffer(Fibo_Handle, 2, 1, 2, f236) < 2) return;
   if(CopyBuffer(Fibo_Handle, 3, 1, 2, f618) < 2) return;
   if(CopyBuffer(Fibo_Handle, 6, 1, 2, smin) < 2) return;
   if(CopyBuffer(Fibo_Handle, 7, 1, 2, smax) < 2) return;

   // Com ArraySetAsSeries(true):
   // Index 0 = Barra 1 (mais recente fechada)
   // Index 1 = Barra 2 (anterior)

   double high1 = iHigh(_Symbol, Timeframe, 1);
   double high2 = iHigh(_Symbol, Timeframe, 2);

   // Regra a: COMPRA
   // 1. Manutenção do upLine (Trend UP) por 2 candles (upLine != EMPTY_VALUE e estável)
   bool upTrend_curr = (upLine[0] != EMPTY_VALUE);
   bool upTrend_prev = (upLine[1] != EMPTY_VALUE);
   
   if(upTrend_curr && upTrend_prev)
   {
      if(MathAbs(upLine[0] - upLine[1]) < _Point)
      {
         // 2. Cruzamento da máxima (High) no nível 23.6%
         if(high1 > f236[0] && high2 <= f236[1])
         {
            if(CountPositions() == 0)
            {
               double entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               // Stop Loss na "down trend line" (Smax) conforme pedido literal.
               // Nota: Se Smax estiver acima de ASK, a ordem será rejeitada. 
               // Usaremos o valor subjacente smax[0].
               double sl = smax[0]; 
               
               // Validação de segurança para evitar erro do servidor:
               if(sl >= entry) sl = smin[0] - 100*_Point; // Fallback para suporte se for inválido

               PlaceBuyMarket(entry, sl);
            }
         }
      }
   }

   // Regra b: VENDA
   // 1. Manutenção do dnLine (Trend DOWN) por 2 candles
   bool dnTrend_curr = (dnLine[0] != EMPTY_VALUE);
   bool dnTrend_prev = (dnLine[1] != EMPTY_VALUE);

   if(dnTrend_curr && dnTrend_prev)
   {
      if(MathAbs(dnLine[0] - dnLine[1]) < _Point)
      {
         // 2. Cruzamento da máxima (High) no nível 61.8%
         if(high1 > f618[0] && high2 <= f618[1])
         {
            if(CountPositions() == 0)
            {
               double entry = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               // Stop Loss na "up trend line" (Smin) conforme pedido literal.
               double sl = smin[0]; 
               
               if(sl <= entry && sl != 0) sl = smax[0] + 100*_Point;

               PlaceSellMarket(entry, sl);
            }
         }
      }
   }
}

//==================== INDICATORS ====================//

bool UpdateIndicators()
{
   double atr[];
   ArraySetAsSeries(atr,true);
   if(CopyBuffer(ATR_Handle,0,0,1,atr)<=0) return false;
   CachedATR = atr[0];
   return true;
}

//==================== CORE ====================//

bool IsNewBar()
{
   static datetime last=0;
   datetime current=iTime(_Symbol,Timeframe,0);
   if(current!=last)
   {
      last=current;
      return true;
   }
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
   if(MaxConsecutiveLoss <= 0) return true;
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

//==================== ORDERS ====================//

void PlaceBuyMarket(double entry, double sl)
{
   double tp = entry + MathAbs(entry-sl)*RR_Ratio;
   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;
   if(!trade.Buy(lot,_Symbol,NormalizeDouble(entry,_Digits),NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),"Mod1 Buy"))
      Print("Buy Error: ",trade.ResultRetcode());
}

void PlaceSellMarket(double entry, double sl)
{
   double tp = entry - MathAbs(sl-entry)*RR_Ratio;
   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;
   if(!trade.Sell(lot,_Symbol,NormalizeDouble(entry,_Digits),NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),"Mod1 Sell"))
      Print("Sell Error: ",trade.ResultRetcode());
}

//==================== LOT ====================//

double CalculateLot(double entry,double sl)
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
   double minLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   lot = MathFloor(lot/step)*step;
   lot = MathMax(minLot,MathMin(maxLot,lot));
   int digits = (int)-MathLog10(step);
   if(digits < 0) digits = 0;
   return NormalizeDouble(lot, digits);
}

//==================== POSITION MANAGEMENT ====================//

void ManagePosition()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic()!=MagicNumber || pos.Symbol()!=_Symbol) continue;

      bool isBuy = (pos.PositionType()==POSITION_TYPE_BUY);
      double sl   = pos.StopLoss();
      double tp   = pos.TakeProfit();
      
      double targetSL = sl;
      bool needsModify = false;

      // Trailing Stop Mod1: Acompanha lineup (upLine) para compra ou linedn (dnLine) para venda
      double envelope[1];
      int bufferIdx = isBuy ? 0 : 1; // 0 = up trend line, 1 = down trend line
      if(CopyBuffer(Fibo_Handle, bufferIdx, 0, 1, envelope) > 0)
      {
         if(envelope[0] != EMPTY_VALUE)
         {
            if(isBuy && envelope[0] > targetSL + 10*_Point) { targetSL = envelope[0]; needsModify = true; }
            if(!isBuy && (targetSL == 0 || envelope[0] < targetSL - 10*_Point)) { targetSL = envelope[0]; needsModify = true; }
         }
      }

      if(needsModify)
      {
         trade.PositionModify(pos.Ticket(), NormalizeDouble(targetSL, _Digits), NormalizeDouble(tp, _Digits));
      }
   }
}

int CountPositions()
{
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(pos.SelectByIndex(i))
         if(pos.Magic()==MagicNumber && pos.Symbol()==_Symbol)
            total++;
   return total;
}
