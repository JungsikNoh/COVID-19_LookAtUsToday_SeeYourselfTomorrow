## COVID-19: Look at us today, see yourself tomorrow
## Look at us today, see yourself tomorrow - NY Governor Andrew Cuomo
## Jungsik Noh, UTSW, Dallas, TX
## 
# Updates:


## source functions 
t1 = Sys.time()
#curDate = Sys.Date(); print(curDate)
curDate = '2020-06-06'

#setwd('C:/githubClone/COVID-19_LookAtUsToday_SeeYourselfTomorrow')
getwd()

source(file.path(getwd(), 'cvd_state_matchedProjected.R'))
source(file.path(getwd(), 'cvd_country_matchedProjected.R'))
source(file.path(getwd(), 'cvd_county_matchedProjected.R'))

library(ggplot2)
library(data.table)
library(formattable)
library(ggpubr)

# fetch JHU
urlJhu = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
jhudat = read.csv(urlJhu, head=T)

# china curation
idPrv = which(jhudat$Country.Region=='China')
chinaPrv = jhudat[idPrv, ]
chinaPrvTS = chinaPrv[, 5:ncol(jhudat)]
chinaTS = colSums(chinaPrvTS)
chinaHead = data.frame(Province.State='', 'Country.Region'='China', Lat=NA, Long=NA)
chinaDP = cbind(chinaHead, rbind(chinaTS))
jhudat = rbind(chinaDP, jhudat[-idPrv, ])
head(jhudat)
# canada curation
idPrv = which(jhudat$Country.Region=='Canada')
chinaPrv = jhudat[idPrv, ]
chinaPrvTS = chinaPrv[, 5:ncol(jhudat)]
chinaTS = colSums(chinaPrvTS)
chinaHead = data.frame(Province.State='', 'Country.Region'='Canada', Lat=NA, Long=NA)
chinaDP = cbind(chinaHead, rbind(chinaTS))
jhudat = rbind(chinaDP, jhudat[-idPrv, ])
head(jhudat)

write.csv(jhudat, file.path(getwd(), 'JHU_CSSE_covid19_confirmed_global.csv'))

### fetch states data from covidtracking.com
#url2 = 'https://covidtracking.com/api/v1/states/daily.csv'
#covidtrackingDat = read.csv(url2, head=T)
## daily input dataset
#write.csv(covidtrackingDat, file.path(getwd(), 'covidtracking_dot_com.csv'))
#head(covidtrackingDat[, 1:7])


# csv input files
basicDatasetsDir = file.path(getwd(), 'basicDatasets')
populationData = read.csv(file.path(basicDatasetsDir, 'usItalyKorea_Population2020UN.csv'))
stpopulationData =
  read.csv(file.path(basicDatasetsDir, 'USstatesPopulation_USCensusBureau_simplified.csv'))


## Global parameters

#stname = 'TX'
#totalCases_threshold_toSetStart = 100
regionOfInt = c('Korea', 'Italy', 'X')
mvWin = 3


########################
##  TX counties
########################

totalCases_threshold_toSetStart = 50
totCases_thrshld_toSelectCnt = 600

## fetch TX county data from nytimes
url_nutimesCounty = 
  'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv'
NYTcountyDat = read.csv(url_nutimesCounty, head=T)

# counties in Texas
ind = (NYTcountyDat$state == 'Texas')
TXcountyDat = NYTcountyDat[ind, ]

# daily input dataset
write.csv(TXcountyDat, file.path(getwd(), 'TXcounty_nytimes.csv'))
tail(TXcountyDat)

# read TX county population 
#numCnt = 10
popTXcounty= read.csv(file.path(basicDatasetsDir, 'worldpopulationReviewdotcom_2020_TexasCounty.csv'))

# county sorting
ind = (TXcountyDat$date == curDate)
txcntToday = TXcountyDat[ind, ]
txcntToday_morethan200 = txcntToday[txcntToday$cases > totCases_thrshld_toSelectCnt, ]
curCases = txcntToday_morethan200$cases
scases = sort(curCases, index.return = T, decreasing = T)
txcntToday_sorted = txcntToday_morethan200[scases$ix, ]

numCnt = nrow(txcntToday_sorted)
print(paste0('number of Counties: ', numCnt))
print(txcntToday_sorted)
sortedCounties = as.character(txcntToday_sorted$county)
print(sortedCounties)

# run counties 
myCaptnLst_county = list()
for (i in 1:numCnt){
  tmp = cvd_county_matchedProjected(curDate, sortedCounties[i], jhudat, TXcountyDat, 
                                    populationData, popTXcounty)
  myCaptnLst_county[[i]] = tmp
  print(tmp)
}



t2=Sys.time(); t2 - t1
## EOF
