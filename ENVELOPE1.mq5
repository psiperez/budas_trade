//+------------------------------------------------------------------+
//| ENVELOPE1 - Fibonacci & Channel Strategy - Version 1.20          |
//+------------------------------------------------------------------+
#property strict
#property version   "1.20"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;

//==================== INPUTS ====================//

input double   RiskPercent            = 1.0;
input double   MaxDrawdownPercent     = 30.0;
input int      MaxConsecutiveLoss     = 5;

input int      ATR_Period             = 14;     // Período ATR (Trend Envelope & Management)
input double   RR_Ratio               = 2.5;

input int      SpreadMaxPoints        = 80;

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;
input int      TrailingStepPoints     = 50;     // Passo mínimo para modificar Trailing

input bool     UsePartialStages       = true;   // Realizações parciais 25, 50, 75%
input double   StagePercent           = 25.0;   // % do lote original em cada estágio

input double   inpDeviation           = 1.5;    // ATR multiplication factor for Trend Envelope

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      MagicNumber            = 20250224;

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
   double smin;
   double smax;
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
   ObjectsDeleteAll(0, "EV1_");
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

   int lookback = 100;
   int total_bars = Bars(_Symbol, Timeframe);
   if(total_bars < lookback + ATR_Period + 10) return;

   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   int needed = lookback + ATR_Period + 10;
   if(CopyHigh(_Symbol, Timeframe, 0, needed, high) < needed) return;
   if(CopyLow(_Symbol, Timeframe, 0, needed, low) < needed) return;
   if(CopyClose(_Symbol, Timeframe, 0, needed, close) < needed) return;

   sTrendEnvelope res_curr;

   ArrayResize(workTrendEnvelopes, lookback + 5);
   for(int k=0; k < (lookback + 5); k++)
   {
      workTrendEnvelopes[k][0 + _teSmin] = 0;
      workTrendEnvelopes[k][0 + _teSmax] = 0;
      workTrendEnvelopes[k][0 + _teTrend] = 0;
   }

   for(int shift = lookback; shift >= 1; shift--)
   {
      double _atr = 0;
      int count = 0;
      for (int k=0; k<ATR_Period; k++)
      {
         int idx = shift + k;
         if(idx + 1 >= needed) break;
         _atr += MathMax(high[idx], close[idx+1]) - MathMin(low[idx], close[idx+1]);
         count++;
      }
      if(count > 0) _atr /= count;

      res_curr = iTrendEnvelope(high[shift], low[shift], close[shift], _atr * inpDeviation, shift, lookback);
   }

   if(res_curr.trendChange)
   {
      // Limpar setup anterior
      CloseAll();
      ObjectsDeleteAll(0, "EV1_");

      double range = res_curr.smax - res_curr.smin;
      double fibo50 = res_curr.smin + (range * 0.5);

      // Desenhar Canal e Fibonacci
      DrawStrategyVisuals(res_curr.smin, res_curr.smax, fibo50);

      // Stop Loss no limite oposto do envelope
      double sl = (res_curr.trend == 1) ? res_curr.smin : res_curr.smax;

      // Abrir ordem pendente
      PlacePendingOrder(res_curr.trend, fibo50, sl);
   }
}

//==================== LOGIC ====================//

sTrendEnvelope iTrendEnvelope(double vh, double vl, double vc, double dev, int i, int max_i, int instanceNo=0)
{
   instanceNo*=_trendEnvelopesInstancesSize;

   workTrendEnvelopes[i][instanceNo+_teSmax]  = vh+dev;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = vl-dev;

   if(i >= max_i)
   {
      workTrendEnvelopes[i][instanceNo+_teTrend] = 0;
   }
   else
   {
      double pSmax = workTrendEnvelopes[i+1][instanceNo+_teSmax];
      double pSmin = workTrendEnvelopes[i+1][instanceNo+_teSmin];
      double pTrend = workTrendEnvelopes[i+1][instanceNo+_teTrend];

      int currTrend = (vc > pSmax && pSmax > 0) ? 1 : (vc < pSmin && pSmin > 0) ? -1 : (int)pTrend;
      workTrendEnvelopes[i][instanceNo+_teTrend] = currTrend;

      if (currTrend > 0 && (workTrendEnvelopes[i][instanceNo+_teSmin] < pSmin || pSmin == 0))
         if(pSmin > 0) workTrendEnvelopes[i][instanceNo+_teSmin] = pSmin;

      if (currTrend < 0 && (workTrendEnvelopes[i][instanceNo+_teSmax] > pSmax || pSmax == 0))
         if(pSmax > 0) workTrendEnvelopes[i][instanceNo+_teSmax] = pSmax;
   }

   sTrendEnvelope r;
   r.trend = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
   r.trendChange = (i < max_i) ? (workTrendEnvelopes[i][instanceNo+_teTrend] != workTrendEnvelopes[i+1][instanceNo+_teTrend]) : false;
   r.smin = workTrendEnvelopes[i][instanceNo+_teSmin];
   r.smax = workTrendEnvelopes[i][instanceNo+_teSmax];
   return r;
}

void DrawStrategyVisuals(double smin, double smax, double mid)
{
   datetime t0 = iTime(_Symbol, Timeframe, 0);
   datetime t1 = iTime(_Symbol, Timeframe, 50); // Linha estendida para trás

   // Canal Equidistante
   if(ObjectCreate(0, "EV1_Channel", OBJ_CHANNEL, 0, t1, smax, t0, smax, t1, smin))
   {
      ObjectSetInteger(0, "EV1_Channel", OBJPROP_COLOR, clrDodgerBlue);
      ObjectSetInteger(0, "EV1_Channel", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, "EV1_Channel", OBJPROP_RAY_RIGHT, true);
   }

   // Fibonacci Retracement
   if(ObjectCreate(0, "EV1_Fibo", OBJ_FIBO, 0, t1, smin, t1, smax))
   {
      ObjectSetInteger(0, "EV1_Fibo", OBJPROP_COLOR, clrGoldenrod);
      ObjectSetInteger(0, "EV1_Fibo", OBJPROP_RAY_RIGHT, true);
   }
}

void PlacePendingOrder(int trend, double entry, double sl)
{
   double price = (trend == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double tp = entry + (entry - sl) * RR_Ratio;
   double lot = CalculateLot(entry, sl);
   if(lot <= 0) return;

   // Lógica para Ordem Stop no nível de 50%
   // Se o preço já estiver além do nível (comum em rompimentos fortes), usamos o tipo de ordem permitido
   if(trend == 1)
   {
      if(price < entry)
         trade.BuyStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits));
      else
         trade.BuyLimit(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits));
   }
   else
   {
      if(price > entry)
         trade.SellStop(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits));
      else
         trade.SellLimit(lot, NormalizeDouble(entry, _Digits), _Symbol, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits));
   }
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

void CloseAll()
{
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(pos.SelectByIndex(i))
         if(pos.Magic()==MagicNumber && pos.Symbol()==_Symbol)
            trade.PositionClose(pos.Ticket());

   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber && OrderGetString(ORDER_SYMBOL)==_Symbol)
            trade.OrderDelete(ticket);
   }
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
