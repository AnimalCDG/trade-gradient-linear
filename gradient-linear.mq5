//+------------------------------------------------------------------+
//|                                              gradient-linear.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("Expert initialized.");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Expert deinitialized.");
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // Get the current price data
   double priceArray[];
   int bars = iBars(_Symbol, _Period);
   ArraySetAsSeries(priceArray, true);
   CopyClose(_Symbol, _Period, 0, bars, priceArray);

   // Calculate linear regression
   double slope, intercept;
   LinearRegression(priceArray, bars, slope, intercept);

   // Trading logic
   static bool positionOpened = false;
   if(slope > 0 && !positionOpened) // Uptrend
     {
      if(CheckOpenOrders() == 0)
        {
         // Buy logic
         Print("Opening Buy position.");
         trade.Buy(0.1, _Symbol);
         positionOpened = true;
        }
     }
   else if(slope < 0 && positionOpened) // Downtrend
     {
      if(CheckOpenOrders() > 0)
        {
         // Close Buy position
         Print("Closing Buy position.");
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
              {
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                  trade.PositionClose(ticket);
                  positionOpened = false;
                 }
              }
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Linear Regression function                                       |
//+------------------------------------------------------------------+
void LinearRegression(double &priceArray[], int bars, double &slope, double &intercept)
  {
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   for(int i = 0; i < bars; i++)
     {
      sumX += i;
      sumY += priceArray[i];
      sumXY += i * priceArray[i];
      sumX2 += i * i;
     }
   slope = (bars * sumXY - sumX * sumY) / (bars * sumX2 - sumX * sumX);
   intercept = (sumY - slope * sumX) / bars;
  }
//+------------------------------------------------------------------+
//| Check Open Orders function                                       |
//+------------------------------------------------------------------+
int CheckOpenOrders()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         count++;
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
