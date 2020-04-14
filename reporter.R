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

# manual curation
cname = countryNamePop$Region
levels(cname)[levels(cname) == 'Korea, South'] <- 'Korea,-South' 
levels(cname)[levels(cname) == 'United Kingdom'] <- 'United-Kingdom' 
cnamePop = cbind(cname, countryNamePop[,2:3])

outPath3 = file.path(getwd(), 'output', 'countries_uptodate')
if (file.exists(file.path(outPath3, 'Korea, South_3plot_combined.png'))) {
  file.copy(file.path(outPath3, 'Korea, South_3plot_combined.png'), 
            file.path(outPath3, 'Korea,-South_3plot_combined.png'))
}
if (file.exists(file.path(outPath3, 'United Kingdom_3plot_combined.png'))) {
  file.copy(file.path(outPath3, 'United Kingdom_3plot_combined.png'), 
            file.path(outPath3, 'United-Kingdom_3plot_combined.png'))
}


repname1 = 'DAILY_REPORT_COUNTRY.md'

sink(file.path(getwd(), repname1))
cat('<img align="right"  height="100" src="/doc/utsw-master-logo-cmyk+BI.png">')
cat('\n\n', '<p>&nbsp;</p>', '\n\n', '<p>&nbsp;</p>', '\n\n')
cat(paste0('## ', curDate, ', COVID-19 Time Series', '\n'))
cat('# Countries (top 25)\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:nrow(countryNamePop)){
  getImg = paste0('>![img](/output/countries_uptodate/',
                  cname[i], '_3plot_combined.png)')
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
cat(paste0('## ', curDate, ', COVID-19 Time Series', '\n'))
cat('# States in the U.S.\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:length(sortedStates)){
  fnametmp = paste0(sortedStates[i], '_3plot_combined.png')
  if (file.exists(file.path(getwd(), 'output', 'states_uptodate', fnametmp))) {
    getImg = paste0('>![img](/output/states_uptodate/', fnametmp, ')')
    cat(getImg)
    cat('\n\n', '<p>&nbsp;</p>', '\n\n')
  }
}
sink()


##
##  county report
##

head(sortedCounties)

# manual curation
Ctname = sortedCounties
Ctname[which(Ctname == "Fort Bend")] <- 'Fort-Bend' 
Ctname[which(Ctname == "El Paso")] <- 'El-Paso' 

outPath4 = file.path(getwd(), 'output', 'TX_counties_uptodate')
if (file.exists(file.path(outPath4, 'Fort Bend_3plot_combined.png'))) {
  file.copy(file.path(outPath4, 'Fort Bend_3plot_combined.png'), 
            file.path(outPath4, 'Fort-Bend_3plot_combined.png'))
}
if (file.exists(file.path(outPath4, 'El Paso_3plot_combined.png'))) {
  file.copy(file.path(outPath4, 'El Paso_3plot_combined.png'), 
            file.path(outPath4, 'El-Paso_3plot_combined.png'))
}


repname3 = 'DAILY_REPORT_TX_COUNTY.md'

sink(file.path(getwd(), repname3))
cat('<img align="right"  height="100" src="/doc/utsw-master-logo-cmyk+BI.png">')
cat('\n\n', '<p>&nbsp;</p>', '\n\n', '<p>&nbsp;</p>', '\n\n')
cat(paste0('## ', curDate, ', COVID-19 Time Series', '\n'))
cat('# TX counties with cumulative confirmed cases > 200\n')
cat('\n\n', '<p>&nbsp;</p>', '\n\n')
for (i in 1:length(Ctname)){
  getImg = paste0('>![img](/output/TX_counties_uptodate/',
                  Ctname[i], '_3plot_combined.png)')
  cat(getImg)
  cat('\n\n', '<p>&nbsp;</p>', '\n\n')
}
sink()







