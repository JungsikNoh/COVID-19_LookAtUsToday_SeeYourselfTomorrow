# COVID-19 Time Series: Look At Us Today, See Yourself Tomorrow

>*Look at us today, see yourself tomorrow.*  
>*- NY, Governor Andrew Cuomo*

The COVID-19 pandemic hit our entire planet hard, taking lots of lives. Most of us are under physical distancing to fight the virus together and to flatten the curve. 

A progression of pandemic outbreak can be visualized by the curve of total confirmed cases or daily new cases over time.
Such curves for COVID-19 show us that some countries like China, Korea and Italy are at the later stage of the virus spreading, while others might be at the beginning.

Showing the ever-increasing number of new cases every day, New York Governor Andrew Cuomo sent the message on April 1, 2020. 
A data science pipeline presented here tries to implement exactly what Governor Cuomo said in a quantitative manner. 
By looking at the preceding pandemic time courses in Italy and Korea, we seek to answer how many new confirmed cases in a country or a region could occur in the near future. 

To monitor the progression of COVID-19 spreading, an informative statistic is the daily growth rate of total cases.
The time courses of the growth rates in many countries showed a pattern. 
The daily growth rates were roughly around 40% with large variability at the beginning, and the rates began to fall toward zero after our strong counter-attack with physical distancing and wearing face masks.
As of April 13, 2020, the daily growth rate in the U.S. is 4.4%, which accounts for 24,685 newly infected and confirmed people,
and the growth rate in Italy is 2.0%, 
according to [Wikipedia](https://en.wikipedia.org/wiki/Template:2019%E2%80%9320_coronavirus_pandemic_data/United_States_medical_cases_chart).

The current level of daily growth rate is a good indicator of the progression of the COVID-19 pandemic.
The progression can be well monitored by looking at the time course of daily growth rates, of which data visualization was not easily available on the web.

*This data science pipeline and its COVID-19 data visualization will help us monitor the number of confirmed cases and growth rates every day.* It provides straightforward visualization to see where we are in view of the past of Italy and Korea. Since the analysis compares population-normalized numbers of daily new cases, it also allows us to compare the sizes of the infection in different countries or regions in the U.S. 
