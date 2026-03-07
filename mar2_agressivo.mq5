//+------------------------------------------------------------------+
//| MAR1_AGRESSIVO_PRO - Institutional Version 5.00                 |
//+------------------------------------------------------------------+
#property strict
#property version   "5.00"

#include <Trade/Trade.mqh>

CTrade         trade;
CPositionInfo  pos;
COrderInfo     ord;

//==================== INPUTS ====================//

input double   RiskPercent            = 1.0;
input double   MaxDrawdownPercent     = 20.0;
input int      MaxConsecutiveLoss     = 3;

input int      BarsLookback           = 20;
input int      ATR_Period             = 14;
input int      ATR_MA_Period          = 50;     // Média do ATR (novo)
input double   ATR_Multiplier_SL      = 2.0;
input double   RR_Ratio               = 2.5;

input int      EMA_Period             = 200;

input double   ATR_Minimum_Points     = 150;    // Reduzido
input double   ATR_Strength_Factor    = 0.7;    // ATR atual >= 70% da média

input double   BreakoutBufferPoints   = 50;
input int      SpreadMaxPoints        = 80;     // Aumentado

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      ExpirationHours        = 4;
input int      MagicNumber            = 20250223;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
int EMA_Handle      = INVALID_HANDLE;

double CachedATR    = 0.0;
double CachedEMA    = 0.0;

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
   if(!IsNewBar())
   {
      ManagePosition();
      return;
   }

   if(!UpdateIndicators()) return;
   if(!CheckSpread()) return;
   if(!CheckDrawdown()) return;
   if(!VolatilityFilter()) return;

   ManagePosition();

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

   CachedATR = atr[0];
   CachedEMA = ema[0];

   return true;
}

//==================== VOLATILITY FILTER PRO ====================//

bool VolatilityFilter()
{
   if(CachedATR<=0) return false;

   double atrPoints = CachedATR/_Point;

   // Filtro mínimo absoluto
   if(atrPoints < ATR_Minimum_Points)
      return false;

   // ATR médio histórico
   double atrHistory[];
   ArraySetAsSeries(atrHistory,true);

   if(CopyBuffer(ATR_Handle,0,1,ATR_MA_Period,atrHistory)<=0)
      return false;

   double sum=0;
   for(int i=0;i<ATR_MA_Period;i++)
      sum+=atrHistory[i];

   double atrAverage=sum/ATR_MA_Period;

   // ATR atual deve ser >= 70% da média histórica
   if(CachedATR < atrAverage*ATR_Strength_Factor)
      return false;

   // Verificar StopLevel do broker
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

double GetHighestHigh()
{
   int idx=iHighest(_Symbol,Timeframe,MODE_HIGH,BarsLookback,1);
   if(idx<0) return -1;
   return iHigh(_Symbol,Timeframe,idx);
}

double GetLowestLow()
{
   int idx=iLowest(_Symbol,Timeframe,MODE_LOW,BarsLookback,1);
   if(idx<0) return -1;
   return iLow(_Symbol,Timeframe,idx);
}

//==================== ORDERS ====================//

void PlaceOrders(double high,double low)
{
   double buyEntry  = high + BreakoutBufferPoints*_Point;
   double sellEntry = low  - BreakoutBufferPoints*_Point;

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(bid > CachedEMA)
      PlaceBuy(buyEntry);

   if(bid < CachedEMA)
      PlaceSell(sellEntry);
}

void PlaceBuy(double entry)
{
   double sl = entry - CachedATR*ATR_Multiplier_SL;
   double tp = entry + (entry-sl)*RR_Ratio;

   double lot = CalculateLot(entry,sl);
   if(lot<=0) return;

   if(!trade.BuyStop(lot,entry,_Symbol,sl,tp,
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

   if(!trade.SellStop(lot,entry,_Symbol,sl,tp,
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

   if(tickSize<=0 || tickValue<=0) return 0;

   double costPerLot = stopDist/tickSize*tickValue;
   if(costPerLot<=0) return 0;

   double lot = riskMoney/costPerLot;

   double step   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);

   lot = MathFloor(lot/step)*step;
   lot = MathMax(minLot,MathMin(maxLot,lot));

   return NormalizeDouble(lot,2);
}

//==================== POSITION MANAGEMENT ====================//

void ManagePosition()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic()!=MagicNumber || pos.Symbol()!=_Symbol) continue;

      double price=(pos.PositionType()==POSITION_TYPE_BUY)
                   ? SymbolInfoDouble(_Symbol,SYMBOL_BID)
                   : SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      double open=pos.PriceOpen();
      double sl=pos.StopLoss();
      double tp=pos.TakeProfit();

      if(UseBreakEven)
      {
         if(MathAbs(price-open)>=CachedATR*BreakEvenTriggerATR)
            trade.PositionModify(pos.Ticket(),open,tp);
      }

      if(UseTrailingATR)
      {
         double newSL;

         if(pos.PositionType()==POSITION_TYPE_BUY)
         {
            newSL=price-CachedATR*TrailingATRMultiplier;
            if(newSL>sl)
               trade.PositionModify(pos.Ticket(),newSL,tp);
         }
         else
         {
            newSL=price+CachedATR*TrailingATRMultiplier;
            if(newSL<sl || sl==0)
               trade.PositionModify(pos.Ticket(),newSL,tp);
         }
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