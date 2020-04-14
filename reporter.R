## COVID-19: Look at us today, see yourself tomorrow
## Jungsik Noh, UTSW, Dallas, TX
## 
# Updates:

# assume input datasets are already loaded to workspace
print(getwd())

##
##  country report
##

head(countryNamePop)

repname1 = 'DAILY_REPORT_COUNTRY.md'

sink(file.path(getwd(), repname1))
cat('<img align="right"  height="100" src="/doc/utsw-master-logo-cmyk+BI.png">')
cat('\n\n', '<p>&nbsp;</p>', '\n\n', '<p>&nbsp;</p>', '\n\n')
cat('## Daily Report of Confirmed Cases\n')
cat('# Countries (top 25)\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:nrow(countryNamePop)){
  getImg = paste0('>![img](/output/countries_uptodate/',
                  countryNamePop$Region[i], '_3plot_combined.png)')
  cat(getImg)
  cat('\n\n', '<p>&nbsp;</p>', '\n\n')
}
sink()


##
##  states report
##

head(sortedStates)

repname2 = 'DAILY_REPORT_STATE.md'

sink(file.path(getwd(), repname2))
cat('<img align="right"  height="100" src="/doc/utsw-master-logo-cmyk+BI.png">')
cat('\n\n', '<p>&nbsp;</p>', '\n\n', '<p>&nbsp;</p>', '\n\n')
cat('## Daily Report of Confirmed Cases\n')
cat('# States in the U.S.\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:length(sortedStates)){
  fnametmp = paste0(sortedStates[i], '_3plot_combined.png')
  if (file.exists(file.path(getwd(), 'output', 'states_uptodate', fnametmp))) {
    getImg = paste0('>![img](/output/states_uptodate/', fnametmp)
    cat(getImg)
    cat('\n\n', '<p>&nbsp;</p>', '\n\n')
  }
}
sink()


##
##  county report
##

head(sortedCounties)

repname3 = 'DAILY_REPORT_TX_COUNTY.md'

sink(file.path(getwd(), repname3))
cat('<img align="right"  height="100" src="/doc/utsw-master-logo-cmyk+BI.png">')
cat('\n\n', '<p>&nbsp;</p>', '\n\n', '<p>&nbsp;</p>', '\n\n')
cat('## Daily Report of Confirmed Cases\n')
cat('# TX counties with cumulative confirmed cases > 200\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:length(sortedCounties)){
  getImg = paste0('>![img](/output/TX_counties_uptodate/',
                  sortedCounties[i], '_3plot_combined.png)')
  cat(getImg)
  cat('\n\n', '<p>&nbsp;</p>', '\n\n')
}
sink()







