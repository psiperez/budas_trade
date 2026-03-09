//+------------------------------------------------------------------+
//| MAR1_AGRESSIVO_PRO - Institutional Version 5.10                 |
//+------------------------------------------------------------------+
#property strict
#property version   "5.10"

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
input int      ATR_MA_Period          = 50;     // Média do ATR
input double   ATR_Multiplier_SL      = 2.0;
input double   RR_Ratio               = 2.5;

input int      EMA_Period             = 200;

input double   ATR_Minimum_Points     = 150;
input double   ATR_Strength_Factor    = 0.7;    // ATR atual >= 50% da média

input double   BreakoutBufferPoints   = 50;
input int      SpreadMaxPoints        = 80;     

input bool     UseBreakEven           = true;
input double   BreakEvenTriggerATR    = 1.0;

input bool     UseTrailingATR         = true;
input double   TrailingATRMultiplier  = 1.5;
input int      TrailingStepPoints     = 50;     // Passo mínimo para modificar Trailing

input bool     UseDynamicTrailing     = true;   // Trailing pelas máximas/mínimas anteriores
input int      TrailingLookback       = 2;      // Quantas barras atrás para o Stop

input bool     UseVolumeFilter        = true;   // Filtro de Volume Real/Tick
input double   VolumeRatio            = 1.2;    // Volume atual deve ser 20% maior que a média

input bool     UseRSIExhaustion       = true;   // Filtro de Exaustão RSI
input int      RSI_Period             = 14;
input double   RSI_Overbought         = 65.0;
input double   RSI_Oversold           = 35.0;

input bool     UsePartialClose        = true;   // Realização Parcial
input double   PartialClosePercent    = 50.0;   // % do lote a fechar
input double   PartialCloseRR         = 1.0;    // Fechar ao atingir 1:1

input ENUM_TIMEFRAMES Timeframe       = PERIOD_H1;
input int      ExpirationHours        = 4;
input int      MagicNumber            = 20250223;

//==================== GLOBAL ====================//

double PeakEquity = 0.0;

int ATR_Handle      = INVALID_HANDLE;
int ATR_M15_Handle  = INVALID_HANDLE;
int EMA_Handle      = INVALID_HANDLE;
int RSI_Handle      = INVALID_HANDLE;

double CachedATR     = 0.0;
double CachedATR_M15 = 0.0;
double CachedEMA     = 0.0;
double CachedRSI     = 0.0;

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);

   ATR_Handle = iATR(_Symbol, Timeframe, ATR_Period);
   if(ATR_Handle == INVALID_HANDLE) return(INIT_FAILED);

   // ATR de 15 minutos para filtro de volatilidade
   ATR_M15_Handle = iATR(_Symbol, PERIOD_M15, ATR_Period);
   if(ATR_M15_Handle == INVALID_HANDLE) return(INIT_FAILED);

   EMA_Handle = iMA(_Symbol, Timeframe, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   if(EMA_Handle == INVALID_HANDLE) return(INIT_FAILED);

   RSI_Handle = iRSI(_Symbol, Timeframe, RSI_Period, PRICE_CLOSE);
   if(RSI_Handle == INVALID_HANDLE) return(INIT_FAILED);

   PeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ATR_Handle != INVALID_HANDLE) IndicatorRelease(ATR_Handle);
   if(ATR_M15_Handle != INVALID_HANDLE) IndicatorRelease(ATR_M15_Handle);
   if(EMA_Handle != INVALID_HANDLE) IndicatorRelease(EMA_Handle);
   if(RSI_Handle != INVALID_HANDLE) IndicatorRelease(RSI_Handle);
}
//+------------------------------------------------------------------+
void OnTick()
{
   // Gestão de posições em cada tick para precisão no trailing
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
   double atr_m15[];
   double ema[];
   double rsi[];

   ArraySetAsSeries(atr,true);
   ArraySetAsSeries(atr_m15,true);
   ArraySetAsSeries(ema,true);
   ArraySetAsSeries(rsi,true);

   if(CopyBuffer(ATR_Handle,0,1,1,atr)<=0) return false;
   if(CopyBuffer(ATR_M15_Handle,0,1,1,atr_m15)<=0) return false;
   if(CopyBuffer(EMA_Handle,0,1,1,ema)<=0) return false;
   if(CopyBuffer(RSI_Handle,0,1,1,rsi)<=0) return false;

   CachedATR     = atr[0];
   CachedATR_M15 = atr_m15[0];
   CachedEMA     = ema[0];
   CachedRSI     = rsi[0];

   return true;
}

//==================== VOLATILITY FILTER PRO ====================//

bool VolatilityFilter()
{
   if(CachedATR_M15<=0) return false;

   // Verificações baseadas no timeframe de 15 minutos (M15)
   double atrPoints = CachedATR_M15/_Point;

   if(atrPoints < ATR_Minimum_Points)
      return false;

   double atrHistory[];
   ArraySetAsSeries(atrHistory,true);

   // Histórico também obtido do handle de 15 minutos
   if(CopyBuffer(ATR_M15_Handle,0,1,ATR_MA_Period,atrHistory)<=0)
      return false;

   double sum=0;
   for(int i=0;i<ATR_MA_Period;i++)
      sum+=atrHistory[i];

   double atrAverage=sum/ATR_MA_Period;

   if(CachedATR_M15 < atrAverage*ATR_Strength_Factor)
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

bool CheckVolumeConfirmation()
{
   if(!UseVolumeFilter) return true;

   long volume[];
   ArraySetAsSeries(volume, true);

   // Compara o volume da barra anterior (fechada) com a média
   if(CopyTickVolume(_Symbol, Timeframe, 1, 20, volume) < 20) return true;

   double sum = 0;
   for(int i = 1; i < 20; i++) sum += (double)volume[i];
   double avg = sum / 19.0;

   return ((double)volume[0] > avg * VolumeRatio);
}

bool CheckExhaustion(int type)
{
   if(!UseRSIExhaustion) return true;

   if(type == POSITION_TYPE_BUY)
      return (CachedRSI < RSI_Overbought); // Não compra se estiver sobrecomprado

   if(type == POSITION_TYPE_SELL)
      return (CachedRSI > RSI_Oversold); // Não vende se estiver sobrevendido

   return true;
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
   if(!CheckVolumeConfirmation()) return;

   double buyEntry  = high + BreakoutBufferPoints*_Point;
   double sellEntry = low  - BreakoutBufferPoints*_Point;

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(bid > CachedEMA && CheckExhaustion(POSITION_TYPE_BUY))
      PlaceBuy(buyEntry);

   if(bid < CachedEMA && CheckExhaustion(POSITION_TYPE_SELL))
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

   return NormalizeDouble(lot, 2);
}

//==================== POSITION MANAGEMENT ====================//

void ManagePosition()
{
   if(CachedATR <= 0) UpdateIndicators();

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!pos.SelectByIndex(i)) continue;
      if(pos.Magic()!=MagicNumber || pos.Symbol()!=_Symbol) continue;

      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      
      double price = (pos.PositionType()==POSITION_TYPE_BUY) ? bid : ask;

      double open = pos.PriceOpen();
      double sl   = pos.StopLoss();
      double tp   = pos.TakeProfit();
      
      double targetSL = sl;
      bool needsModify = false;

      // 1. Lógica de Break-even
      if(UseBreakEven)
      {
         if(MathAbs(price-open) >= CachedATR*BreakEvenTriggerATR)
         {
            if(pos.PositionType()==POSITION_TYPE_BUY && (sl < open || sl == 0))
            {
               targetSL = open;
               needsModify = true;
            }
            if(pos.PositionType()==POSITION_TYPE_SELL && (sl > open || sl == 0))
            {
               targetSL = open;
               needsModify = true;
            }
         }
      }

      // 2. Lógica de Trailing Stop
      if(UseTrailingATR && CachedATR > 0)
      {
         double trailingSL;
         if(pos.PositionType()==POSITION_TYPE_BUY)
         {
            trailingSL = bid - CachedATR*TrailingATRMultiplier;
            if(trailingSL > targetSL + TrailingStepPoints*_Point)
            {
               targetSL = trailingSL;
               needsModify = true;
            }
         }
         else
         {
            trailingSL = ask + CachedATR*TrailingATRMultiplier;
            if(sl == 0 || trailingSL < targetSL - TrailingStepPoints*_Point)
            {
               targetSL = trailingSL;
               needsModify = true;
            }
         }
      }
      
      // 3. Realização Parcial
      if(UsePartialClose)
      {
         double profitPoints = (pos.PositionType() == POSITION_TYPE_BUY) ? (bid - open) : (open - ask);
         double riskPoints = MathAbs(open - sl);

         // Se atingiu o RR e ainda não foi feita a parcial (comentário de controle ou volume)
         if(profitPoints >= riskPoints * PartialCloseRR && pos.Volume() > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
         {
            double closeLot = NormalizeDouble(pos.Volume() * PartialClosePercent / 100.0, 2);
            double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            closeLot = MathFloor(closeLot / step) * step;

            if(closeLot >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            {
               trade.PositionClosePartial(pos.Ticket(), closeLot);
               // Após parcial, move obrigatoriamente para o zero a zero
               targetSL = open;
               needsModify = true;
            }
         }
      }

      // 4. Trailing Dinâmico (Máximas/Mínimas)
      if(UseDynamicTrailing)
      {
         double dynSL;
         if(pos.PositionType() == POSITION_TYPE_BUY)
         {
            int idx = iLowest(_Symbol, Timeframe, MODE_LOW, TrailingLookback, 1);
            dynSL = iLow(_Symbol, Timeframe, idx);
            if(dynSL > targetSL + TrailingStepPoints * _Point)
            {
               targetSL = dynSL;
               needsModify = true;
            }
         }
         else
         {
            int idx = iHighest(_Symbol, Timeframe, MODE_HIGH, TrailingLookback, 1);
            dynSL = iHigh(_Symbol, Timeframe, idx);
            if(targetSL == 0 || dynSL < targetSL - TrailingStepPoints * _Point)
            {
               targetSL = dynSL;
               needsModify = true;
            }
         }
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
