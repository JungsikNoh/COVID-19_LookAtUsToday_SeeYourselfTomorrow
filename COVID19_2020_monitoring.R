## COVID-19: Look at us today, see yourself tomorrow
## Look at us today, see yourself tomorrow - NY Governor Andrew Cuomo
## Jungsik Noh, UTSW, Dallas, TX
## 
# Updates:
# 04/13/2020, Noh. Add 3-plot output. Add -uptodate output folder.
# 04/12/2020, Noh. X lab changed. No. of total cases added.
# 04/11/2020, Noh. Add ref line. Add TX county analysis.
# 04/10/2020, Noh. Starting day is adjusted. 
# 04/07/2020, Noh. population adjusted.

## source functions 
t1 = Sys.time()
#curDate = Sys.Date(); print(curDate)
curDate = '2020-05-21'

#setwd('C:/githubClone/COVID-19_LookAtUsToday_SeeYourselfTomorrow')
print(getwd())

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

## fetch states data from covidtracking.com
url2 = 'https://covidtracking.com/api/v1/states/daily.csv'
covidtrackingDat = read.csv(url2, head=T)
# daily input dataset
write.csv(covidtrackingDat, file.path(getwd(), 'covidtracking_dot_com.csv'))
head(covidtrackingDat[, 1:7])


# csv input files
basicDatasetsDir = file.path(getwd(), 'basicDatasets')
populationData = read.csv(file.path(basicDatasetsDir, 'usItalyKorea_Population2020UN.csv'))
stpopulationData =
  read.csv(file.path(basicDatasetsDir, 'USstatesPopulation_USCensusBureau_simplified.csv'))


## Global parameters

#stname = 'TX'
totalCases_threshold_toSetStart = 100
regionOfInt = c('Korea', 'Italy', 'X')
mvWin = 3


######################
##  top 25 countries
######################

numCntr = 25
UNpop2019Dat = read.csv(file.path(basicDatasetsDir, 'UN_WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES_2019.csv'))

jhudatL = jhudat[, c(2, ncol(jhudat))]
head(jhudatL)
scases = sort(jhudatL[, 2], index.return = T, decreasing = T)
jhudatL2 = jhudatL[scases$ix, ]
print(jhudatL2[1:numCntr, ])
namesTop20 = as.character(jhudatL2$Country.Region[1:numCntr])

# Korea is not in top 25 (04/21 revised)
namesTop20 = c(namesTop20, 'Korea, South')

# name curation -.-;; good job jhu
namesTop20_1 = namesTop20
namesTop20_1[(namesTop20 == 'US')] = 'United States of America'
namesTop20_1[(namesTop20 == 'Korea, South')] = 'Republic of Korea'
namesTop20_1[(namesTop20 == 'Iran')] = 'Iran (Islamic Republic of)'
namesTop20_1[(namesTop20 == 'Russia')] = 'Russian Federation'



# fetch pop
countryNamePop = data.frame(Region = namesTop20, namesTop20_1, pop2019 = 1:length(namesTop20))
for (i in 1:nrow(countryNamePop)){
  pop0 = UNpop2019Dat$X2019[which(UNpop2019Dat$Region == namesTop20_1[i])]
  countryNamePop$pop2019[i] = pop0
}

# run countries
numState = numCntr
myCaptnLst_country = list()
for (i in 1:numState){
  stname = as.character(countryNamePop$Region[i])
  tmp = cvd_country_matchedProjected(curDate, stname, jhudat, countryNamePop)
  myCaptnLst_country[[i]] = tmp
  print(tmp)
}



############
##  States
############

# total 56 states
curPos = covidtrackingDat$positive[1:56]
scases = sort(curPos, index.return = T, decreasing = T)
sortedStates = as.character(covidtrackingDat$state[scases$ix[1:56]])
print(sortedStates)


# run states
numState = length(sortedStates)
StateAbb = sortedStates
myCaptnLst = list()
for (i in 1:numState){
  tmp = cvd_state_matchedProjected(curDate, StateAbb[i], jhudat, covidtrackingDat, 
                                    populationData, stpopulationData)
  myCaptnLst[[i]] = tmp
  print(tmp)
}


t2=Sys.time(); t2 - t1
## EOF
