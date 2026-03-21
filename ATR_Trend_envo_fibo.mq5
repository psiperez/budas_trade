//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   6
#property indicator_label1  "Trend envelope up trend line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Trend envelope down trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  2
#property indicator_label3  "Fibo 23.6%"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Fibo 61.8%"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Trend envelope up trend start"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrDodgerBlue
#property indicator_width5  2
#property indicator_label6  "Trend envelope down trend start"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrCrimson
#property indicator_width6  2

//
//--- input parameters
//

input int     inpAtrPeriod = 14;   // ATR period
input double  inpDeviation = 1.5;  // ATR multilication factor


//
//--- indicator buffers
//

double lineup[],linedn[],fibo236[],fibo618[],arrowup[],arrowdn[],smin_buf[],smax_buf[];

//
//--- custom structures
//

struct sTrendEnvelope
{
   double upline;
   double downline;
   double f236;
   double f618;
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
   SetIndexBuffer(2,fibo236,INDICATOR_DATA);
   SetIndexBuffer(3,fibo618,INDICATOR_DATA);
   SetIndexBuffer(4,arrowup,INDICATOR_DATA); PlotIndexSetInteger(4,PLOT_ARROW,159);
   SetIndexBuffer(5,arrowdn,INDICATOR_DATA); PlotIndexSetInteger(5,PLOT_ARROW,159);
   SetIndexBuffer(6,smin_buf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,smax_buf,INDICATOR_CALCULATIONS);
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

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _atr = 0;
      for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++)
         _atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]);
      _atr /= inpAtrPeriod;

      sTrendEnvelope _result = iTrendEnvelope(high[i],low[i],close[i],_atr*inpDeviation,i,rates_total);
         lineup[i]  = _result.upline;
         linedn[i]  = _result.downline;
         fibo236[i] = _result.f236;
         fibo618[i] = _result.f618;
         arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
         arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
   }
   return(rates_total);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1
#define _teTrend 2

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars); instanceNo*=_trendEnvelopesInstancesSize;

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

   double smin = workTrendEnvelopes[i][instanceNo+_teSmin];
   double smax = workTrendEnvelopes[i][instanceNo+_teSmax];
   double range = smax - smin;

   sTrendEnvelope _result;
   _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
   _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
   _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? smin : EMPTY_VALUE;
   _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? smax : EMPTY_VALUE;
   _result.f236        = smin + range * 0.236;
   _result.f618        = smin + range * 0.618;

   smin_buf[i] = smin;
   smax_buf[i] = smax;

   return(_result);
}
