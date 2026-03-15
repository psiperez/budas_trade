//+------------------------------------------------------------------+
//| MAR3_EURUSD - Contra-Tendência Version 5.40 (EURUSD)            |
//+------------------------------------------------------------------+
#property strict
#property version   "5.40"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;
COrderInfo     ord;

//==================== INPUTS ====================//

input double   RiskPercent            = 1.5;    // Risco ligeiramente aumentado para EURUSD
input double   MaxDrawdownPercent     = 15.0;   // Mais conservador no Drawdown
input int      MaxConsecutiveLoss     = 4;

input int      BarsLookback           = 20;
input int      ATR_Period             = 14;
input int      ATR_MA_Period          = 50;     // Média do ATR (usado no filtro M15)
input double   ATR_Multiplier_SL      = 2.0;
input double   RR_Ratio               = 2.5;

input int      EMA_Period             = 200;

input double   ATR_Minimum_Points     = 150;
input double   ATR_Strength_Factor    = 0.7;    // ATR atual >= 70% da média (M15)

input double   BreakoutBufferPoints   = 30;     // Reduzido para maior sensibilidade no EURUSD
input int      SpreadMaxPoints        = 25;     // Mais restrito para EURUSD

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;
input int      TrailingStepPoints     = 50;     // Passo mínimo para modificar Trailing

input bool     UseDynamicTrailing     = true;   // Trailing pelas máximas/mínimas anteriores
input int      TrailingLookback       = 2;      // Quantas barras atrás para o Stop

input bool     UsePartialClose        = true;   // Realização Parcial
input double   PartialClosePercent    = 50.0;   // % do lote a fechar
input double   PartialCloseRR         = 1.0;    // Fechar ao atingir 1:1 do risco ATR

input ENUM_TIMEFRAMES Timeframe       = PERIOD_M15; // Otimizado para M15 no EURUSD
input int      ExpirationHours        = 2;          // Expiração mais curta para scalping/reversão
input int      MagicNumber            = 20250223;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
int EMA_Handle      = INVALID_HANDLE;

double CachedATR     = 0.0;
double CachedEMA     = 0.0;

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   ATR_Handle = iATR(_Symbol, Timeframe, ATR_Period);
   if(ATR_Handle == INVALID_HANDLE) return(INIT_FAILED);

   EMA_Handle = iMA(_Symbol, Timeframe, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   if(EMA_Handle == INVALID_HANDLE) return(INIT_FAILED);

   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ATR_Handle != INVALID_HANDLE) IndicatorRelease(ATR_Handle);
   if(EMA_Handle != INVALID_HANDLE) IndicatorRelease(EMA_Handle);
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
   if(!VolatilityFilter()) return;

   if(CountPositions()>0 || CountOrders()>0) return;

   double high = GetHighestHigh();
   double low  = GetLowestLow();
   if(high<=0 || low<=0) return;

   PlaceOrders(high,low);
}
//==================== INDICATORS ====================//

bool UpdateIndicators()
{
   double atr[];
   double ema[];

   ArraySetAsSeries(atr,true);
   ArraySetAsSeries(ema,true);

   if(CopyBuffer(ATR_Handle,0,1,1,atr)<=0) return false;
   if(CopyBuffer(EMA_Handle,0,1,1,ema)<=0) return false;

   CachedATR     = atr[0];
   CachedEMA     = ema[0];

   return true;
}

//==================== VOLATILITY FILTER PRO ====================//

bool VolatilityFilter()
{
   if(CachedATR<=0) return false;

   double atrPoints = CachedATR/_Point;

   if(atrPoints < ATR_Minimum_Points)
      return false;

   double atrHistory[];
   ArraySetAsSeries(atrHistory,true);

   if(CopyBuffer(ATR_Handle,0,1,ATR_MA_Period,atrHistory)<=0)
      return false;

   double sum=0;
   for(int i=0;i<ATR_MA_Period;i++)
      sum+=atrHistory[i];

   double atrAverage=sum/ATR_MA_Period;

   if(CachedATR < atrAverage*ATR_Strength_Factor)
      return false;

   int stopLevel=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(atrPoints <= stopLevel)
      return false;

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
   double spread=(SymbolInfoDouble(_Symbol,SYMBOL_ASK)
                 -SymbolInfoDouble(_Symbol,SYMBOL_BID))/_Point;

   return (spread<=SpreadMaxPoints);
}

bool CheckDrawdown()
{
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);

   if(equity>PeakEquity)
      PeakEquity=equity;

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

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                    + HistoryDealGetDouble(ticket, DEAL_SWAP)
                    + HistoryDealGetDouble(ticket, DEAL_COMMISSION);

      if(profit < 0) count++;
      else break;
   }

   return (count < MaxConsecutiveLoss);
}

double GetHighestHigh()
{
   double high[];
   ArraySetAsSeries(high,true);
   if(CopyHigh(_Symbol,Timeframe,1,BarsLookback,high) < BarsLookback) return -1;
   int idx=ArrayMaximum(high);
   return high[idx];
}

double GetLowestLow()
{
   double low[];
   ArraySetAsSeries(low,true);
   if(CopyLow(_Symbol,Timeframe,1,BarsLookback,low) < BarsLookback) return -1;
   int idx=ArrayMinimum(low);
   return low[idx];
}

//==================== ORDERS ====================//

void PlaceOrders(double high,double low)
{
   double buyEntry  = high + BreakoutBufferPoints*_Point;
   double sellEntry = low  - BreakoutBufferPoints*_Point;

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   // Lógica de Contra-Tendência (Entradas contrárias à EMA)
   if(bid < CachedEMA)
      PlaceBuy(buyEntry);

   if(bid > CachedEMA)
      PlaceSell(sellEntry);
}

void PlaceBuy(double entry)
{
   double sl = entry - CachedATR*ATR_Multiplier_SL;
   double tp = entry + (entry-sl)*RR_Ratio;

   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;

   if(!trade.BuyStop(lot,NormalizeDouble(entry,_Digits),_Symbol,NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),
      ORDER_TIME_SPECIFIED,
      TimeCurrent()+ExpirationHours*3600,
      "Buy Breakout"))
   {
      Print("BuyStop Error: ",trade.ResultRetcode(),
            " ",trade.ResultRetcodeDescription());
   }
}

void PlaceSell(double entry)
{
   double sl = entry + CachedATR*ATR_Multiplier_SL;
   double tp = entry - (sl-entry)*RR_Ratio;

   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;

   if(!trade.SellStop(lot,NormalizeDouble(entry,_Digits),_Symbol,NormalizeDouble(sl,_Digits),NormalizeDouble(tp,_Digits),
      ORDER_TIME_SPECIFIED,
      TimeCurrent()+ExpirationHours*3600,
      "Sell Breakout"))
   {
      Print("SellStop Error: ",trade.ResultRetcode(),
            " ",trade.ResultRetcodeDescription());
   }
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
   if(CachedATR <= 0) UpdateIndicators();

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic() != MagicNumber || pos.Symbol() != _Symbol) continue;

      bool isBuy = (pos.PositionType() == POSITION_TYPE_BUY);
      double price = isBuy ? bid : ask;

      double open = pos.PriceOpen();
      double sl   = pos.StopLoss();
      double tp   = pos.TakeProfit();

      double targetSL = sl;
      bool needsModify = false;

      // 1. Lógica de Break-even
      if(UseBreakEven)
      {
         if(MathAbs(price - open) >= CachedATR * BreakEvenTriggerATR)
         {
            if(isBuy && (targetSL < open || targetSL == 0)) { targetSL = open; needsModify = true; }
            if(!isBuy && (targetSL > open || targetSL == 0)) { targetSL = open; needsModify = true; }
         }
      }

      // 2. Lógica de Realização Parcial (Executada antes do trailing para travar o BE)
      if(UsePartialClose)
      {
         double profitPoints = isBuy ? (bid - open) : (open - ask);
         double initialRisk = CachedATR * ATR_Multiplier_SL;

         bool triggerPartial = (profitPoints >= initialRisk * PartialCloseRR);

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

         bool alreadyProtected = (pos.Volume() < initialVol - 0.00001);

         if(triggerPartial && !alreadyProtected && pos.Volume() > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
         {
            double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            int volDigits = (int)-MathLog10(step);
            if(volDigits<0) volDigits=0;

            double closeLot = NormalizeDouble(pos.Volume() * PartialClosePercent / 100.0, volDigits);
            closeLot = MathFloor(closeLot / step) * step;

            if(closeLot >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN) && (pos.Volume() - closeLot) >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            {
               if(trade.PositionClosePartial(pos.Ticket(), closeLot))
               {
                  targetSL = open;
                  needsModify = true;
               }
            }
         }
      }

      // 3. Lógica de Trailing Stop Consolidada (Resolve conflito ATR vs Estrutura)
      double tATR = 0, tDyn = 0;

      if(UseTrailingATR && CachedATR > 0)
         tATR = isBuy ? (bid - CachedATR * TrailingATRMultiplier) : (ask + CachedATR * TrailingATRMultiplier);

      if(UseDynamicTrailing)
      {
         int idx = isBuy ? iLowest(_Symbol, Timeframe, MODE_LOW, TrailingLookback, 1) : iHighest(_Symbol, Timeframe, MODE_HIGH, TrailingLookback, 1);
         tDyn = isBuy ? iLow(_Symbol, Timeframe, idx) : iHigh(_Symbol, Timeframe, idx);
      }

      // Escolhe o melhor Stop (que proteja o lucro e respeite o TrailingStep)
      double bestTrailing = 0;
      if(isBuy)
      {
         // Para compra, queremos o SL mais alto que respeite as regras
         bestTrailing = MathMax(tATR, tDyn);
         if(bestTrailing > targetSL + TrailingStepPoints * _Point) { targetSL = bestTrailing; needsModify = true; }
      }
      else
      {
         // Para venda, queremos o SL mais baixo que respeite as regras
         bestTrailing = (tATR > 0 && (tDyn == 0 || tATR < tDyn)) ? tATR : tDyn;
         if(bestTrailing > 0 && (targetSL == 0 || bestTrailing < targetSL - TrailingStepPoints * _Point)) { targetSL = bestTrailing; needsModify = true; }
      }

      if(needsModify)
      {
         trade.PositionModify(pos.Ticket(), NormalizeDouble(targetSL, _Digits), tp);
      }
   }
}

//==================== COUNTERS ====================//

int CountPositions()
{
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(pos.SelectByIndex(i))
         if(pos.Magic()==MagicNumber && pos.Symbol()==_Symbol)
            total++;
   return total;
}

int CountOrders()
{
   int total=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
      if(ord.SelectByIndex(i))
         if(ord.Magic()==MagicNumber && ord.Symbol()==_Symbol)
            total++;
   return total;
}
