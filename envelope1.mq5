//+------------------------------------------------------------------+
//| ENVELOPE1 - ATR Trend Envelope Version 1.00                      |
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

input int      ATR_Period             = 14;     // Período ATR (Trend Envelope)
input double   ATR_Multiplier_SL      = 2.0;    // Não usado na lógica de SL fixa do envelope, mas mantido para compatibilidade
input double   RR_Ratio               = 2.5;

input double   ATR_Minimum_Points     = 80;
input double   ATR_Strength_Factor    = 0.5;    // ATR atual >= 50% da média

input int      SpreadMaxPoints        = 80;

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;
input int      TrailingStepPoints     = 50;     // Passo mínimo para modificar Trailing

input bool     UsePartialStages       = true;   // Realizações parciais 25, 50, 75%
input double   StagePercent           = 25.0;   // % do lote original em cada estágio

input int      inpAtrPeriod           = 14;     // ATR period for Trend Envelope
input double   inpDeviation           = 1.5;    // ATR multiplication factor for Trend Envelope

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      ExpirationHours        = 8;
input int      MagicNumber            = 20250224; // Updated Magic Number

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
double CachedATR    = 0.0;

// Trend Envelope Global State
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1
#define _teTrend 2

struct sTrendEnvelope
{
   double upline;
   double downline;
   int    trend;
   bool   trendChange;
};

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   ATR_Handle = iATR(_Symbol, Timeframe, ATR_Period);
   if(ATR_Handle == INVALID_HANDLE) return(INIT_FAILED);


   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ATR_Handle != INVALID_HANDLE) IndicatorRelease(ATR_Handle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   // Gestão de posições em cada tick
   ManagePosition();

   if(!IsNewBar()) return;

   if(!UpdateIndicators()) return;
   if(!CheckSpread()) return;
   if(!CheckDrawdown()) return;
   if(!CheckConsecutiveLosses()) return;

   // Sincronizamos o histórico do envelope para garantir detecção correta de mudança
   int lookback = inpAtrPeriod + 5;
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   if(CopyHigh(_Symbol, Timeframe, 0, lookback + 5, high) < lookback + 5) return;
   if(CopyLow(_Symbol, Timeframe, 0, lookback + 5, low) < lookback + 5) return;
   if(CopyClose(_Symbol, Timeframe, 0, lookback + 5, close) < lookback + 5) return;

   int rates_total = (int)SeriesInfoInteger(_Symbol, Timeframe, SERIES_BARS_COUNT);
   sTrendEnvelope res_curr;

   // Processamos o histórico recente para preencher workTrendEnvelopes
   for(int shift = lookback; shift >= 1; shift--)
   {
      double _atr = 0;
      for (int k=0; k<inpAtrPeriod; k++)
         _atr += MathMax(high[shift+k], close[shift+1+k]) - MathMin(low[shift+k], close[shift+1+k]);
      _atr /= inpAtrPeriod;

      int i = rates_total - 1 - shift;
      res_curr = iTrendEnvelope(high[shift], low[shift], close[shift], _atr * inpDeviation, i, rates_total);
   }

   if(res_curr.trendChange)
   {
      CloseAll();

      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double entry = (res_curr.trend == 1) ? ask : bid;

      // Stop Loss no nível do trend anterior à mudança (Smax se mudou para UP, Smin se mudou para DOWN)
      // O nível anterior está em i_prev = rates_total - 1 - 2
      int i_prev = rates_total - 1 - 2;
      double sl = (res_curr.trend == 1) ? workTrendEnvelopes[i_prev][0 + _teSmax] : workTrendEnvelopes[i_prev][0 + _teSmin];

      if(res_curr.trend == 1)
         PlaceBuyMarket(entry, sl);
      else if(res_curr.trend == -1)
         PlaceSellMarket(entry, sl);
   }
}

//==================== INDICATORS ====================//

bool UpdateIndicators()
{
   double atr[];
   ArraySetAsSeries(atr,true);
   if(CopyBuffer(ATR_Handle,0,1,1,atr)<=0) return false;
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
   if(!trade.Buy(lot,_Symbol,NormalizeDouble(entry,_Digits),NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),"Envelope Buy"))
      Print("Buy Error: ",trade.ResultRetcode());
}

void PlaceSellMarket(double entry, double sl)
{
   double tp = entry - MathAbs(sl-entry)*RR_Ratio;
   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;
   if(!trade.Sell(lot,_Symbol,NormalizeDouble(entry,_Digits),NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),"Envelope Sell"))
      Print("Sell Error: ",trade.ResultRetcode());
}

void CloseAll()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(pos.SelectByIndex(i))
         if(pos.Magic()==MagicNumber && pos.Symbol()==_Symbol)
            trade.PositionClose(pos.Ticket());

   for(int i=OrdersTotal()-1;i>=0;i--)
      if(ord.SelectByIndex(i))
         if(ord.Magic()==MagicNumber && ord.Symbol()==_Symbol)
            trade.OrderDelete(ord.Ticket());
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
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic()!=MagicNumber || pos.Symbol()!=_Symbol) continue;

      bool isBuy = (pos.PositionType()==POSITION_TYPE_BUY);
      double price = isBuy ? bid : ask;

      double open = pos.PriceOpen();
      double sl   = pos.StopLoss();
      double tp   = pos.TakeProfit();

      double targetSL = sl;
      bool needsModify = false;

      // 1. Lógica de Break-even
      if(UseBreakEven && CachedATR > 0)
      {
         if(MathAbs(price-open) >= CachedATR*BreakEvenTriggerATR)
         {
            if(isBuy && (targetSL < open || targetSL == 0)) { targetSL = open; needsModify = true; }
            if(!isBuy && (targetSL > open || targetSL == 0)) { targetSL = open; needsModify = true; }
         }
      }

      // 2. Realização Parcial (Estágios 25, 50, 75% do TP)
      if(UsePartialStages && tp > 0)
      {
         double totalProfitDist = MathAbs(tp - open);
         double currentProfitDist = isBuy ? (bid - open) : (open - ask);
         double progress = currentProfitDist / totalProfitDist;
         double vol = pos.Volume();

         double initialVol = 0;
         if(HistorySelectByPosition(pos.Ticket()))
         {
            int deals = HistoryDealsTotal();
            for(int d=0; d<deals; d++)
            {
               ulong d_ticket = HistoryDealGetTicket(d);
               if(HistoryDealGetInteger(d_ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
               {
                  initialVol = HistoryDealGetDouble(d_ticket, DEAL_VOLUME);
                  break;
               }
            }
         }

         if(initialVol > 0)
         {
            double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            int volDigits = (int)-MathLog10(step);
            if(volDigits<0) volDigits=0;

            double closeLot = 0;

            if(progress >= 0.75 && vol > NormalizeDouble(initialVol * 0.25 + 0.0001, volDigits))
               closeLot = vol - (initialVol * 0.25);
            else if(progress >= 0.50 && progress < 0.75 && vol > NormalizeDouble(initialVol * 0.50 + 0.0001, volDigits))
               closeLot = vol - (initialVol * 0.50);
            else if(progress >= 0.25 && progress < 0.50 && vol > NormalizeDouble(initialVol * 0.75 + 0.0001, volDigits))
               closeLot = vol - (initialVol * 0.75);

            if(closeLot > 0)
            {
               closeLot = MathFloor(closeLot/step)*step;
               if(closeLot >= minL && (vol - closeLot) >= minL)
               {
                  if(trade.PositionClosePartial(pos.Ticket(), closeLot))
                  {
                     targetSL = open;
                     needsModify = true;
                  }
               }
            }
         }
      }

      // 3. Lógica de Trailing Stop
      if(UseTrailingATR && CachedATR > 0)
      {
         double trailingSL = isBuy ? (bid - CachedATR*TrailingATRMultiplier) : (ask + CachedATR*TrailingATRMultiplier);
         if(isBuy && trailingSL > targetSL + TrailingStepPoints*_Point) { targetSL = trailingSL; needsModify = true; }
         if(!isBuy && (targetSL == 0 || trailingSL < targetSL - TrailingStepPoints*_Point)) { targetSL = trailingSL; needsModify = true; }
      }

      if(needsModify)
      {
         trade.PositionModify(pos.Ticket(), NormalizeDouble(targetSL, _Digits), NormalizeDouble(tp, _Digits));
      }
   }
}

//==================== TREND ENVELOPE LOGIC ====================//

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars);
   instanceNo*=_trendEnvelopesInstancesSize;

   workTrendEnvelopes[i][instanceNo+_teSmax]  = valueh+deviation;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = valuel-deviation;

   if(i==0)
   {
      workTrendEnvelopes[i][instanceNo+_teTrend] = 0;
   }
   else
   {
      double prevSmax = workTrendEnvelopes[i-1][instanceNo+_teSmax];
      double prevSmin = workTrendEnvelopes[i-1][instanceNo+_teSmin];
      double prevTrend = workTrendEnvelopes[i-1][instanceNo+_teTrend];

      workTrendEnvelopes[i][instanceNo+_teTrend] = (value>prevSmax) ? 1 : (value<prevSmin) ? -1 : prevTrend;

      if (workTrendEnvelopes[i][instanceNo+_teTrend]>0 && workTrendEnvelopes[i][instanceNo+_teSmin]<prevSmin)
         workTrendEnvelopes[i][instanceNo+_teSmin] = prevSmin;
      if (workTrendEnvelopes[i][instanceNo+_teTrend]<0 && workTrendEnvelopes[i][instanceNo+_teSmax]>prevSmax)
         workTrendEnvelopes[i][instanceNo+_teSmax] = prevSmax;
   }

   sTrendEnvelope _result;
   _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
   _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
   _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? workTrendEnvelopes[i][instanceNo+_teSmin] : EMPTY_VALUE;
   _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? workTrendEnvelopes[i][instanceNo+_teSmax] : EMPTY_VALUE;
   return(_result);
}
