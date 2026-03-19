//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "ATR Trend env_fibo with Fibonacci Retracement"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9

#property indicator_label1  "Trend envelope up trend line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "Trend envelope down trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  2

#property indicator_label3  "Trend envelope up trend start"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_width3  2

#property indicator_label4  "Trend envelope down trend start"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrCrimson
#property indicator_width4  2

// Fibonacci Levels
#property indicator_label5  "Fibo 23.6%"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_DOT

#property indicator_label6  "Fibo 38.2%"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSilver
#property indicator_style6  STYLE_DOT

#property indicator_label7  "Fibo 50.0%"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGray
#property indicator_style7  STYLE_DOT

#property indicator_label8  "Fibo 61.8%"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrSilver
#property indicator_style8  STYLE_DOT

#property indicator_label9  "Fibo 76.4%"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrSilver
#property indicator_style9  STYLE_DOT

//
//--- input parameters
//

input int     inpAtrPeriod = 14;   // ATR period
input double  inpDeviation = 1.5;  // ATR multilication factor


//
//--- indicator buffers
//

double lineup[],linedn[],arrowup[],arrowdn[];
double fibo236[], fibo382[], fibo500[], fibo618[], fibo764[];

//
//--- custom structures
//

struct sTrendEnvelope
{
   double upline;
   double downline;
   double smin;
   double smax;
   int    trend;
   bool   trendChange;
};

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,lineup,INDICATOR_DATA);
   SetIndexBuffer(1,linedn,INDICATOR_DATA);
   SetIndexBuffer(2,arrowup,INDICATOR_DATA); PlotIndexSetInteger(2,PLOT_ARROW,159);
   SetIndexBuffer(3,arrowdn,INDICATOR_DATA); PlotIndexSetInteger(3,PLOT_ARROW,159);

   SetIndexBuffer(4,fibo236,INDICATOR_DATA);
   SetIndexBuffer(5,fibo382,INDICATOR_DATA);
   SetIndexBuffer(6,fibo500,INDICATOR_DATA);
   SetIndexBuffer(7,fibo618,INDICATOR_DATA);
   SetIndexBuffer(8,fibo764,INDICATOR_DATA);

   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);

   //
   //---
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _atr = 0; for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) _atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); _atr /= inpAtrPeriod;
      sTrendEnvelope _result = iTrendEnvelope(high[i],low[i],close[i],_atr*inpDeviation,i,rates_total);
         lineup[i]  = _result.upline;
         linedn[i]  = _result.downline;
         arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
         arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;

         // Fibonacci Calculation
         double smin = _result.smin;
         double smax = _result.smax;
         double range = smax - smin;

         if(range > 0)
         {
            fibo236[i] = smax - 0.236 * range;
            fibo382[i] = smax - 0.382 * range;
            fibo500[i] = smax - 0.500 * range;
            fibo618[i] = smax - 0.618 * range;
            fibo764[i] = smax - 0.764 * range;
         }
         else
         {
            fibo236[i] = EMPTY_VALUE;
            fibo382[i] = EMPTY_VALUE;
            fibo500[i] = EMPTY_VALUE;
            fibo618[i] = EMPTY_VALUE;
            fibo764[i] = EMPTY_VALUE;
         }
   }
   return(rates_total);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 5
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1
#define _teTrend 2
#define _teSminRaw 3
#define _teSmaxRaw 4

//
//---
//

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars); instanceNo*=_trendEnvelopesInstancesSize;

   //
   //---
   //

   workTrendEnvelopes[i][instanceNo+_teSmaxRaw]  = valueh+deviation;
   workTrendEnvelopes[i][instanceNo+_teSminRaw]  = valuel-deviation;

   workTrendEnvelopes[i][instanceNo+_teSmax]  = valueh+deviation;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = valuel-deviation;

	workTrendEnvelopes[i][instanceNo+_teTrend] = (i>0) ? (value>workTrendEnvelopes[i-1][instanceNo+_teSmax]) ? 1 : (value<workTrendEnvelopes[i-1][instanceNo+_teSmin]) ? -1 : workTrendEnvelopes[i-1][instanceNo+_teTrend] : 0;

      if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]>0 && (workTrendEnvelopes[i][instanceNo+_teSmin]<workTrendEnvelopes[i-1][instanceNo+_teSmin] || workTrendEnvelopes[i-1][instanceNo+_teSmin] == 0))
         if(workTrendEnvelopes[i-1][instanceNo+_teSmin] > 0) workTrendEnvelopes[i][instanceNo+_teSmin] = workTrendEnvelopes[i-1][instanceNo+_teSmin];

	   if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]<0 && (workTrendEnvelopes[i][instanceNo+_teSmax]>workTrendEnvelopes[i-1][instanceNo+_teSmax] || workTrendEnvelopes[i-1][instanceNo+_teSmax] == 0))
         if(workTrendEnvelopes[i-1][instanceNo+_teSmax] > 0) workTrendEnvelopes[i][instanceNo+_teSmax] = workTrendEnvelopes[i-1][instanceNo+_teSmax];

      //
      //---
      //

      sTrendEnvelope _result;
	                  _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
                     _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
                     _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? workTrendEnvelopes[i][instanceNo+_teSmin] : EMPTY_VALUE;
                     _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? workTrendEnvelopes[i][instanceNo+_teSmax] : EMPTY_VALUE;
                     // We need the boundaries regardless of trend for Fibonacci
                     // But Fibo logic usually uses the trailing lines
                     _result.smin        = workTrendEnvelopes[i][instanceNo+_teSmin];
                     _result.smax        = workTrendEnvelopes[i][instanceNo+_teSmax];
      return(_result);
}
