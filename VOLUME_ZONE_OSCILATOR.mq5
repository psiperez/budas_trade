//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Volume zone oscillator"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrCrimson
#property indicator_width2  2
//
//---
//
input  int    inpPeriod       = 14;    // Period
input  int    inpFlLookBack   = 12;    // Floating levels look back period
input  double inpFlLevelUp    = 50;    // Floating levels up level %
input  double inpFlLevelDown  = 50;    // Floating levels down level %
//
//---
//
double vzo[],vzoc[],levup[],levdn[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,vzo,INDICATOR_DATA);
   SetIndexBuffer(3,vzoc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Volume zone oscillator - fl ("+(string)inpPeriod+","+(string)inpFlLookBack+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][2];
#define _vp 0
#define _tv 1
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
   if (ArrayRange(work,0)!=rates_total) ArrayResize(work,rates_total);
   double alpha = 2.0 / (1.0 + inpPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double sign = (i>0) ? (close[i]>close[i-1]) ? 1 : (close[i]<close[i-1]) ? -1 : 0 : 0; 
      double R = sign * tick_volume[i];
         work[i][_vp] = (i==0) ? R                      : work[i-1][_vp]+alpha*(R             -work[i-1][_vp]);
         work[i][_tv] = (i==0) ? (double)tick_volume[i] : work[i-1][_tv]+alpha*(tick_volume[i]-work[i-1][_tv]);
         vzo[i] = (work[i][_tv]!=0) ? 100.0*work[i][_vp]/work[i][_tv] : 0;
      int _start = MathMax(i-inpFlLookBack,0);
      double min = vzo[ArrayMinimum(vzo,_start,inpFlLookBack)];
      double max = vzo[ArrayMaximum(vzo,_start,inpFlLookBack)];
      double range = max-min;
      levup[i] = min+inpFlLevelUp*range/100.0;
      levdn[i] = min+inpFlLevelDown*range/100.0;
      vzoc[i]  = (vzo[i]>levup[i]) ? 1 : (vzo[i]<levdn[i]) ? 2 : 0;
   }      
   return(i);
}
