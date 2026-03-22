//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   9
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
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Fibo 38.2%"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Fibo 50.0%"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Fibo 61.8%"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSilver
#property indicator_style6  STYLE_DOT
#property indicator_label7  "Fibo 76.4%"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrSilver
#property indicator_style7  STYLE_DOT
#property indicator_label8  "Trend envelope up trend start"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrDodgerBlue
#property indicator_width8  2
#property indicator_label9  "Trend envelope down trend start"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrCrimson
#property indicator_width9  2

//
//--- input parameters
//

input int     inpAtrPeriod = 14;   // ATR period
input double  inpDeviation = 1.5;  // ATR multilication factor


//
//--- indicator buffers
//

double lineup[],linedn[],fibo236[],fibo382[],fibo500[],fibo618[],fibo764[],arrowup[],arrowdn[],smin_buf[],smax_buf[];

//
//--- custom structures
//

struct sTrendEnvelope
{
   double upline;
   double downline;
   double f236, f382, f500, f618, f764;
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
   SetIndexBuffer(3,fibo382,INDICATOR_DATA);
   SetIndexBuffer(4,fibo500,INDICATOR_DATA);
   SetIndexBuffer(5,fibo618,INDICATOR_DATA);
   SetIndexBuffer(6,fibo764,INDICATOR_DATA);
   SetIndexBuffer(7,arrowup,INDICATOR_DATA); PlotIndexSetInteger(7,PLOT_ARROW,159);
   SetIndexBuffer(8,arrowdn,INDICATOR_DATA); PlotIndexSetInteger(8,PLOT_ARROW,159);
   SetIndexBuffer(9,smin_buf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,smax_buf,INDICATOR_CALCULATIONS);
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
         fibo382[i] = _result.f382;
         fibo500[i] = _result.f500;
         fibo618[i] = _result.f618;
         fibo764[i] = _result.f764;
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
   _result.f382        = smin + range * 0.382;
   _result.f500        = smin + range * 0.500;
   _result.f618        = smin + range * 0.618;
   _result.f764        = smin + range * 0.764;

   smin_buf[i] = smin;
   smax_buf[i] = smax;

   return(_result);
}
