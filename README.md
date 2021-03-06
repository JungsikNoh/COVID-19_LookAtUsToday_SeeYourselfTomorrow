## This pipeline was upgraded.

- Please visit [a new repository](https://github.com/JungsikNoh/COVID19_Estimated-Size-of-Infectious-Population) for new COVID-19 reports. 

<p>&nbsp;</p> 


# COVID-19 Time Series: Look at Us Today, See Yourself Tomorrow


>*Look at us today, see yourself tomorrow.*  
>*- NY, Governor Andrew Cuomo*

The COVID-19 pandemic hit our entire planet hard, taking lots of lives. Most of us are under physical distancing to fight the virus together and to flatten the curve. 

A progression of pandemic outbreak can be visualized by the curve of total confirmed cases or daily new cases over time.
Such curves for COVID-19 show us that some countries like China, Korea and Italy are at the later stage of the virus spreading, while others might be at the beginning.

Showing the ever-increasing number of new cases every day, New York Governor Andrew Cuomo sent the message on April 1, 2020. 
A data science pipeline presented here tries to implement exactly what Governor Cuomo said in a quantitative manner. 
By looking at the preceding pandemic trajectories in Italy and Korea, 
we seek to answer how much the U.S. or a region is behind Italy or Korea on the pandemic progression, 
so that we can picture how many new confirmed cases in the region could be projected in the near future.

To monitor the progression of COVID-19 spreading, an informative statistic is the daily growth rate of total cases.
The time courses of the growth rates in many countries showed a pattern. 
The daily growth rates were roughly around 40% with large variability at the beginning, and the rates began to fall toward zero after our strong counter-attack with physical distancing and wearing face masks.
As of April 14, 2020, the daily growth rate in the U.S. is [4.4%](https://en.wikipedia.org/wiki/Template:2019%E2%80%9320_coronavirus_pandemic_data/United_States_medical_cases_chart), which accounts for 25,327 newly infected and confirmed people, and the growth rate in Italy is [1.9%](https://en.wikipedia.org/wiki/Template:2019%E2%80%9320_coronavirus_pandemic_data/Italy_medical_cases_chart), according to Wikipedia. It took 13-14 days for Italy’s rates to decrease from ~4.4% to 1.9%, while the deaths toll increased from 13,155 to 21,067 during the period in Italy. 

The current level of daily growth rate is an informative indicator of the progression stage of COVID-19 pandemic events. 
To monitor the pandemic progression and project the numbers in the coming weeks, it is better to watch the time course of daily growth rates, of which data visualization was not easily available on the web.

*This data science pipeline and its COVID-19 data visualization will help us monitor the number of confirmed cases and the growth rates every day.* It provides straightforward visualization to see where we are in view of the past of Italy and Korea. Since the analysis compares population-normalized numbers of daily new cases, it also allows us to compare the sizes of the infection in different countries or regions in the U.S. 


## Daily Report of COVID-19 Time Series

1. [Countries](DAILY_REPORT_COUNTRY.md)    
2. [States in the U.S.](DAILY_REPORT_STATE.md)    
3. [TX counties](DAILY_REPORT_TX_COUNTY.md)

A daily report lists three plots of COVID-19 time series across countries, states or TX counties. For example, the three summary plots for the U.S. is as follows:

![img](/output/countries_uptodate/US_3plot_combined.png)

**Plot details**

- (**Left**): Daily new confirmed cases in the U.S., Korea and Italy, after adjusting the population size of Korea and Italy to the one of the U.S. Each time series starts since total confirmed cases became more than 100 before population adjustment.
- (**Middle**): Trend curves of the daily growth rates of total cases for the U.S., Korea and Italy. The value at each day on the trend curves is the average of 9 daily rates around each day, and the most recent value is the average of recent five daily growth rates.
- (**Right**): Daily new confirmed cases in the U.S., Korea and Italy, after adjusting the population size of Korea and Italy to the one of the U.S. Here, the three trajectories are shifted in time, so that the daily growth rates of the three countries are close to each other near day = 0. Blue or red dashed lines denote two possible projections for the new cases of the U.S. acquired from the growth rates of Korea or Italy, respectively.



## Links

- Please find detailed explanation for all output plots and data visualization at [an article at medium.com](https://medium.com/@nohjssunny/covid-19-look-at-us-today-see-yourself-tomorrow-965201ff61a4).



## Output

For each region, the pipeline generates five plots for new cases per-day, daily growth rates, trend of the daily growth rates, time-shifted curve of growth rates, and time-shifted curve of new cases in comparison with the curves for Italy and Korea.

For example, daily output plots for the U.S. can be found in [/output/countries/US](/output/countries/US). Up-to-date output for the states in the U.S. can be found in [/output/states_uptodate](/output/states_uptodate).


## Data sources

- The number of confirmed cases for countries and Texas counties are from COVID-19 data repository of Johns Hopkins CSSE (https://github.com/CSSEGISandData/COVID-19). Updated around 11pm CT.
- Data at the state level are from the covidtracking project (https://covidtracking.com/). Updated around 4pm CT.
- Until 07/19/2020, data at the county level were from The New York Times, based on reports from state and local health agencies (https://github.com/nytimes/covid-19-data). Updated around 10am CT the next day.

## Contact

Jungsik Noh (jungsik.noh@utsouthwestern.edu)











