## COVID-19: Where are we on the trajectories of Italy and Korea?
## 04/05/2020

add.col <- function(df, new.col) {
  df = cbind(df)
  n.row<-dim(df)[1]
  length(new.col)<-n.row
  #tmp <- cbind(rep(NA, n.row))
  #tmp[(n.row - length(new.col) + 1):n.row] <- new.col
  cbind(df, new.col)
}

myFilter <- function(x, mwSize, lastDay){
  y = x
  halfSize = (mwSize - 1) / 2
  for (i in 2:lastDay){
    sti = max(2, i - halfSize)
    endi = min(lastDay, i + halfSize)
    slc = x[sti:endi]
    y[i] = mean(slc, na.rm = T)
  }
  return(y)
} 

cvd_state_matchedProjected = function(curDate, stname, jhudat, covidtrackingDat, 
                                      populationData, stpopulationData){
  #
  # Look at us today, see yourself tomorrow - NY Governor Andrew Cuomo
  # Jungsik Noh, UTSW, Dallas, TX
  # 
  # Updates:
  # 04/07/2020, population adjusted.
  

  ## fetch Italy, Korea and US data
  
  outPath = file.path(getwd(), 'output', 'states', stname, curDate)
  if (!dir.exists(outPath)) dir.create(outPath, recursive = T)
  
  #
  head(jhudat) 
  class(jhudat)
  names(jhudat)
  
  countryName = jhudat$Country.Region
  head(countryName)
  ind = which(countryName == 'Korea, South')
  tmp = jhudat[ind,] 
  head(t(tmp))
  tmp2 = t(tmp[5:length(tmp)])
  #plot(tmp2)
  #describe(jhudat)
  KOts0 = tmp2
  
  tmp = jhudat[which(countryName == 'Italy'),]
  head(t(tmp))
  tmp2 = t(tmp[5:length(tmp)])
  #plot(tmp2)
  ITts0 = tmp2
  
  #
  head(covidtrackingDat) 
  class(covidtrackingDat)
  names(covidtrackingDat)
  head(covidtrackingDat$date)
  
  stdat1 = covidtrackingDat[covidtrackingDat$state == stname, ]
  stdat2 = stdat1[nrow(stdat1):1, ]
  stdat3 = data.frame(date = stdat2$date, val = stdat2$positive)
  colnames(stdat3) = c('date', stname)
  
  # align jhu and covidtracking data
  startDate0 = stdat3$date[1]
  
  st_y0 = startDate0 %% 10000
  st_mon0 = st_y0 %/% 100
  st_day0 = startDate0 %% 100 
  dateLab = paste0('X', st_mon0, '.',st_day0, '.', '20')
  print(dateLab)
  
  id1 = which(rownames(KOts0) == dateLab)
  state_date = c(rep(NA, id1 - 1),  stdat3$date)
  state_val = c(rep(NA, id1 - 1),  stdat3[, 2])
  
  # check today date on two datasets
  if (length(KOts0) != length(state_val)) stop('JHU date does not match to covidtracking.com data!')
  
  # start with 'datf'
  datf = cbind(KOts0, ITts0, state_val)
  
  ## manual curation, two zeros in Italy and Korea from Wikipedia
  datfrow = rownames(datf)
  id = which(datfrow == 'X3.12.20')     # Italy
  datf[id, 2] = 15113
  
  id = which(datfrow == 'X3.22.20')     # Korea
  datf[id, 1] = 8897
  
  ## export corrected 3 countries data
  datf = as.data.frame(datf)
  colnames(datf) = c('Korea', 'Italy', 'X')
  totalCases_3countries = datf
  #write.csv(totalCases_3countries, 'totalCases_3countries.csv', row.names = T)
  
  ## population size adjustment 
  #populationData = read.csv('usItalyKorea_Population2020UN.csv')
  KOpop = populationData$Population_2020_UN[(populationData$region == 'Korea')]
  ITpop = populationData$Population_2020_UN[(populationData$region == 'Italy')]
  
  ## X population: USstatesPopulation_USCensusBureau_simplified
  data(state)
  myStAbb = c(state.abb, 'DC')
  myStName = c(state.name, 'District of Columbia')
  
  stInd = which(myStAbb == stname)
  if (length(stInd) == 0){ return() }
  stfullname = myStName[stInd]
  stfullname2 = paste0('.', stfullname)
  
  #stpopulationData = read.csv('USstatesPopulation_USCensusBureau_simplified.csv')
  stInd2 = which(stpopulationData$States == stfullname2)
  Xpop = stpopulationData$Est2019_Population[stInd2]
  
  ## pop adjustment: datf -> datf_adj
  datf_adj = datf
  datf_adj$Korea = round(datf$Korea * (Xpop/KOpop))
  datf_adj$Italy = round(datf$Italy * (Xpop/ITpop))
  
  # totalCases_threshold_toSetStart
  
  d0 = apply(datf, 2, function(x) min(which(x > totalCases_threshold_toSetStart)))
  d0
  
  #
  numTS = dim(datf_adj)[2]
  lenTS = dim(datf_adj)[1]
  TSthresholded = list()
  datf2 = data.frame(Day = 1:lenTS - 1)
  for (j in 1:numTS){
    TSthresholded[[j]] = datf_adj[d0[j]:lenTS, j]
    datf2 = add.col(datf2, TSthresholded[[j]])
  }
  longestLen = max(as.numeric(lapply(TSthresholded, length)))
  datf2 = datf2[1:longestLen,]
  tail(datf2) 
  tmpNames = cbind('Day', rbind(regionOfInt))
  colnames(datf2) = tmpNames
  
  ## Daily new confirmed cases
  
  A1 = datf2[,1+1:numTS]
  A2 = rbind(rep(NA, numTS), A1[1:(longestLen-1),])
  A3 = A1 - A2
  A4 = (A3 / A2) * 100
  
  colnames(A3) = paste0('dif.', colnames(A1))
  colnames(A4) = paste0('growth.', colnames(A1))
  datf3 = cbind(datf2, A3, A4) 
  

  # find 'today'
  dLast = apply(A1, 2, function(x) max(which(!is.na(x))))
  datf3L = datf3
  datf3L1 = datf3
  for (j in 1:numTS){
    datf3L[1:(dLast[j]-1), j+4] = NA
    datf3L1[dLast[j], j+4] = NA
    datf3L[1:(dLast[j]-1), j+7] = NA
    datf3L1[dLast[j], j+7] = NA
  }
  
  # total cases
  Xtotal = rev(state_val)[1]
  XtotalforMsg = paste0(', No. of total cases: ', comma(Xtotal, 0))
  
  # modify df for ggplot
  tmp1 = data.frame(Day = datf3L$Day, Today = stname, val = datf3L$dif.X)
  tmp2 = data.frame(Day = datf3L$Day, Today = 'Korea.Adj', val = datf3L$dif.Korea)
  tmp3 = data.frame(Day = datf3L$Day, Today = 'Italy.Adj', val = datf3L$dif.Italy)
  ggp_datf3L = rbind(tmp1, tmp2, tmp3)
  
  fig1 <- ggplot(data = datf3) +
    geom_line(data = datf3, aes(Day, dif.X), size=2, alpha=0.8, color='black') +
    geom_line(data = datf3, aes(Day, dif.Korea), size=2, alpha=0.3, color='blue') +
    geom_line(data = datf3, aes(Day, dif.Italy), size=2, alpha=0.3, color='red') +
    geom_point(data = ggp_datf3L, aes(x=Day, y=val, color=Today), size=4, alpha=0.8) +
    scale_color_manual(values = c('black', 'blue', 'red')) +
    theme_bw() 
  #geom_point(data=datf3L, aes(Day, dif.Korea), size=4, alpha=0.8, color='blue') +
  #geom_point(data=datf3L, aes(Day, dif.Italy), size=4, alpha=0.8, color='red') +
  
  fig1out <- fig1 + labs(title = 'New Cases Per-day', 
                         x= paste0('Days since total cases became > ', totalCases_threshold_toSetStart), y='', 
                         subtitle = paste0('As of ', curDate, XtotalforMsg)) +
    theme(plot.title = element_text(hjust = 0.5, size=rel(2)), 
          axis.text = element_text(size = rel(2) ), 
          axis.title = element_text(size=rel(2)), 
          legend.position = 'top', legend.title = element_text(size= rel(1.5)), 
          legend.text = element_text(size = rel(1.5)))
  print(fig1out)
  
  f1name = paste0(stname, '_newCases.pdf')
  pdf(file.path(outPath, f1name), width=8, height=4)
  Sys.sleep(2)
  print(fig1out)
  Sys.sleep(2)
  dev.off()
  Sys.sleep(4)
  
  
  ##maGrowthX = filter(datf3$growth.X, filter=rep(1, 7)/7, sides = 2)
  #maGRX = datf3$growth.X
  ## - day ma sides=2 na.rm=T
  #for (i in 2:dLast[3]){
  #  sti = max(1, i - 3)
  #  endi = min(dLast[3], i + 3)
  #  slc = datf3$growth.X[sti:endi]
  #  maGRX[i] = mean(slc, na.rm = T)
  #}
  #datf3$maGRX = maGRX
  
  ## Daily Growth Rate Time Series
  tmp1 = data.frame(Day = datf3L$Day, Today = stname, val = datf3L$growth.X)
  tmp2 = data.frame(Day = datf3L$Day, Today = 'Korea.Adj', val = datf3L$growth.Korea)
  tmp3 = data.frame(Day = datf3L$Day, Today = 'Italy.Adj', val = datf3L$growth.Italy)
  ggp_datf3L = rbind(tmp1, tmp2, tmp3)
  
  fig2 <- ggplot() +
    #geom_line(data = datf3, aes(Day, maGRX), size=1, alpha=0.8, color='gray', 
    #          linetype = 'solid') +
    geom_line(data=datf3, aes(Day, growth.X), size=2, alpha=0.8, color='black') +
    geom_line(data=datf3, aes(Day, growth.Korea), size=2, alpha=0.3, color='blue') +
    geom_line(data=datf3, aes(Day, growth.Italy), size=2, alpha=0.3, color='red') +
    geom_point(data = ggp_datf3L, aes(x=Day, y=val, color=Today), size=4, alpha=0.8) +
    scale_color_manual(values = c('black', 'blue', 'red')) +
    theme_bw() 
  #geom_point(data=datf3L, aes(Day, growth.Korea), size=4, alpha=0.8, color='blue') +
  #geom_point(data=datf3L, aes(Day, growth.Italy), size=4, alpha=0.8, color='red') +
  
  fig2out <- fig2 + 
    coord_cartesian(ylim = c(0, 70)) +
    labs(title = 'Daily Growth Rate of Total Cases', 
         x= paste0('Days since total cases became > ', totalCases_threshold_toSetStart), 
         y='Percentage', 
         subtitle = paste0('As of ', curDate, XtotalforMsg)) +
    theme(plot.title = element_text(hjust = 0.5, size=rel(2)), 
          axis.text = element_text(size = rel(2) ), 
          axis.title = element_text(size=rel(2)), 
          legend.position = 'top', legend.title = element_text(size = rel(1.5)), 
          legend.text = element_text(size = rel(1.5)))
  print(fig2out)
  
  f2name = paste0(stname, '_growthRate.pdf')
  pdf(file.path(outPath, f2name), width=8, height=4)
  Sys.sleep(2)
  print(fig2out)
  Sys.sleep(2)
  dev.off()
  Sys.sleep(4)
  
  
  ### Moving Avg plot. Daily Growth Rate Time Series
  ### 04/10 (XXXX)
  datf3ma = datf3
  datf3ma$growth.Korea = myFilter(datf3$growth.Korea, 9, dLast[1])
  datf3ma$growth.Italy = myFilter(datf3$growth.Italy,  9, dLast[2])
  datf3ma$growth.X = myFilter(datf3$growth.X,  9, dLast[3])
  
  datf3maL = datf3ma
  for (j in 1:numTS){
    datf3maL[1:(dLast[j]-1), j+4] = NA
    datf3maL[1:(dLast[j]-1), j+7] = NA
  }
  refLineVal = datf3maL$growth.X[!is.na(datf3maL$growth.X)]
  
  ## myFilter, mov avg. Daily Growth Rate Time Series
  tmp1 = data.frame(Day = datf3maL$Day, Today = stname, val = datf3maL$growth.X)
  tmp2 = data.frame(Day = datf3maL$Day, Today = 'Korea.Adj', val = datf3maL$growth.Korea)
  tmp3 = data.frame(Day = datf3maL$Day, Today = 'Italy.Adj', val = datf3maL$growth.Italy)
  ggp_datf3maL = rbind(tmp1, tmp2, tmp3)
  
  fig21 <- ggplot() +
    #geom_line(data = datf3, aes(Day, maGRX), size=1, alpha=0.8, color='gray', 
    #          linetype = 'solid') +
    geom_line(data=datf3ma, aes(Day, growth.X), size=2, alpha=0.8, color='black') +
    geom_line(data=datf3ma, aes(Day, growth.Korea), size=2, alpha=0.3, color='blue') +
    geom_line(data=datf3ma, aes(Day, growth.Italy), size=2, alpha=0.3, color='red') +
    geom_point(data = ggp_datf3maL, aes(x=Day, y=val, color=Today), size=4, alpha=0.8) +
    scale_color_manual(values = c('black', 'blue', 'red')) +
    theme_bw()  +
    geom_hline(yintercept = refLineVal)
  #geom_point(data=datf3L, aes(Day, growth.Korea), size=4, alpha=0.8, color='blue') +
  #geom_point(data=datf3L, aes(Day, growth.Italy), size=4, alpha=0.8, color='red') +
  
  fig21out <- fig21 + 
    coord_cartesian(ylim = c(0, 70)) +
    labs(title = 'Trend Curve of the Daily Growth Rates', 
         x= paste0('Days since total cases became > ', totalCases_threshold_toSetStart), 
         y='Percentage', 
         subtitle = paste0('As of ', curDate, XtotalforMsg)) +
    theme(plot.title = element_text(hjust = 0.5, size=rel(2)), 
          axis.text = element_text(size = rel(2) ), 
          axis.title = element_text(size=rel(2)), 
          legend.position = 'top', legend.title = element_text(size = rel(1.5)), 
          legend.text = element_text(size = rel(1.5)))
  print(fig21out)
  
  f21name = paste0(stname, '_growthRate_trend.pdf')
  pdf(file.path(outPath, f21name), width=8, height=4)
  Sys.sleep(2)
  print(fig21out)
  Sys.sleep(2)
  dev.off()
  Sys.sleep(4)
  

  ## TS matching
  
  dX = rev(dLast)[1]
  lastGRs = datf3[(dX-2):dX, ncol(datf3)]
  RMSDmat = matrix(NA, longestLen, 2)
  for (i in (mvWin+1):longestLen){
    a1 = A4[(i-mvWin+1):i, 1]
    a1tmp = sqrt(mean((a1 - lastGRs)^2))
    RMSDmat[i, 1] = a1tmp
    a2 = A4[(i-mvWin+1):i, 2]
    a2tmp = sqrt(mean((a2 - lastGRs)^2))
    RMSDmat[i, 2] = a2tmp
  }
  
  dDelta = apply(RMSDmat, 2, which.min)
  datfAdd = matrix(NA, dim(datf3)[1], 3)
  colnames(datfAdd) = colnames(A4)
  datf4 = rbind(datfAdd, A4, datfAdd)
  ##
  ITtoKO = dDelta[2] - dDelta[1]
  ITaligned = shift(datf4[,2], n=ITtoKO, fill=NA, type="lead")
  datf5 = datf4
  datf5 = add.col(datf4, ITaligned)
  
  XtoKO = dX - dDelta[1]
  Xaligned = shift(datf4[,3], n = XtoKO, fill=NA, type='lead')
  datf5 = add.col(datf5, Xaligned)
  
  # Days (Today = 0)
  daysFromToday0 = 1:nrow(datf5)
  daysFromToday = daysFromToday0 - dDelta[1] - nrow(A4)
  datf6 = data.frame(daysFromToday = daysFromToday, 
                     growth.Korea = datf4[,1], growth.Italy = ITaligned, growth.X = Xaligned)
  
  idrow = (rowSums(is.na(datf6)) == 3)
  datf7 = datf6[!idrow,]
  
  # find 'today'
  A5 = datf7[, 1+1:numTS]
  dLastDf7 = apply(A5, 2, function(x) max(which(!is.na(x))))
  datf7L = datf7 
  for (j in 1:numTS){
    datf7L[1:(dLastDf7[j]-1), j+1] = NA
  }
  
  # projected Growth Rates
  datf7Prj = datf7
  datf7Prj[1:dLastDf7[3], ] = NA
  print('days since >100')
  print(dLast)
  print('day after >100 that matches XX today')
  print(dDelta)
  print('days that can be projected')
  daysProjected = dLast - c(dDelta, dLast[3])
  print(daysProjected)
  # pct
  grKOtoday = round(datf7L$growth.Korea[!is.na(datf7L$growth.Korea)], 1)
  grITtoday = round(datf7L$growth.Italy[!is.na(datf7L$growth.Italy)], 1)
  grXtoday = round(datf7L$growth.X[!is.na(datf7L$growth.X)], 1)
  
  
  ## The growth rate of X total cases today is similar to that of Italy (daysProjected) days before. 
  ## If X follows Italy, X daily growth rate would reach xx% in the xx days.
  
  # If xx is on the track of Korea/Italy, xx is estimated to be behind xx days,
  # in which daily growth rate will be xx%, 
  # and total confirmed cases will be xx.
  
  #myCaptn1 = 
  #  cat(paste0('The growth rate of ', countryOfInt[3], ' today is close to that of Korea ',
  #             daysProjected[1], ' days ago.', '\n', 
  #             'IF ', countryOfInt[3], ' follows Korea, ', countryOfInt[3], 
  #             ' daily growth rate would reach ', grKOtoday, '% in ', 
  #             daysProjected[1], ' days.'))
  #myCaptn1 = paste0('IF ', stname, ' follows Korea, ', stname, 
  #             ' daily growth rate would reach ', grKOtoday, '% in ', 
  #             daysProjected[1], ' days.')
  myCaptn1 = paste0('If ', stname, ' follows the track of Korea, ', 
                    'its daily growth rate of ', grXtoday, '% today would become ', 
                    grKOtoday, '% in ', 
                    daysProjected[1], ' days.')
  myCaptn2 = paste0('If ', stname, ' follows the track of Italy, ', 
                    'its daily growth rate of ', grXtoday, '% today would become ', 
                    grITtoday, '% in ', 
                    daysProjected[2], ' days.')
  
  
  tmp1 = data.frame(daysFromToday = datf7L$daysFromToday, Today = stname, val = datf7L$growth.X)
  tmp2 = data.frame(daysFromToday = datf7L$daysFromToday, Today = 'Korea.Adj', val = datf7L$growth.Korea)
  tmp3 = data.frame(daysFromToday = datf7L$daysFromToday, Today = 'Italy.Adj', val = datf7L$growth.Italy)
  ggp_datf7L = rbind(tmp1, tmp2, tmp3)
  
  fig3 <- ggplot(data=datf7) +
    geom_line(data=datf7, aes(daysFromToday, growth.X), size=2, alpha=0.8, color='black') +
    geom_line(data=datf7, aes(daysFromToday, growth.Korea), size=2, alpha=0.3, color='blue') +
    geom_line(data=datf7, aes(daysFromToday, growth.Italy), size=2, alpha=0.3, color='red') +
    geom_point(data = ggp_datf7L, aes(x=daysFromToday, y=val, color=Today), size=4, alpha=0.8) +
    scale_color_manual(values = c('black', 'blue', 'red')) +
    theme_bw() +
    #geom_point(data=datf7L, aes(daysFromToday, growth.Korea), size=4, alpha=0.8, color='blue') +
    #geom_point(data=datf7L, aes(daysFromToday, growth.Italy), size=4, alpha=0.8, color='red') +
    geom_line(data = datf7Prj, aes(daysFromToday, growth.Korea), 
              size=2, alpha=0.8, color='blue', linetype='dashed') +
    geom_line(data = datf7Prj, aes(daysFromToday, growth.Italy), 
              size=2, alpha=0.8, color='red', linetype='dashed') +
    geom_hline(yintercept = grXtoday)
  
  fig3out <- fig3 + coord_cartesian(ylim = c(0, 70)) +
    labs(title = 'Matched/Projected Daily Growth Rate of Total Cases', 
         x= paste0('Days from today of ', stname), y='Percentage', 
         subtitle = paste0('As of ', curDate, XtotalforMsg), 
         caption = paste0(myCaptn1, '\n', myCaptn2)) +
    theme(plot.title = element_text(hjust = 0.5, size=rel(2)), 
          axis.text = element_text(size = rel(2) ), 
          axis.title = element_text(size=rel(2)), 
          legend.position = 'top', legend.title = element_text(size = rel(1.5)), 
          legend.text = element_text(size = rel(1.5)), 
          plot.caption = element_text(hjust = 0, size = rel(1)))
  print(fig3out)
  
  f3name = paste0(stname, '_growthRate_matchedProjected.pdf')
  pdf(file.path(outPath, f3name), width=8, height=4.5)
  Sys.sleep(2)
  print(fig3out)
  Sys.sleep(2)
  dev.off()
  Sys.sleep(4)
  
  
  ## projection: see yourself tomorrow
  
  id1 = which(datf7$daysFromToday >= 1)
  prjGRfromDatf7 = datf7[id1, ]
  maxPrjPrd = dim(prjGRfromDatf7)[1]
  XprjLongestLen = dLast[3] + maxPrjPrd
  elongatedLen = max(0, XprjLongestLen - dim(datf3)[1])
  elongBlock = matrix(NA, elongatedLen, dim(datf3)[2])
  colnames(elongBlock) = colnames(datf3)
  datf3_prj = rbind(datf3, elongBlock)
  
  prjKO = c(rep(NA, dLast[3]), prjGRfromDatf7$growth.Korea)
  length(prjKO) = nrow(datf3_prj)
  prjIT = c(rep(NA, dLast[3]), prjGRfromDatf7$growth.Italy)
  length(prjIT) = nrow(datf3_prj)
  prj2 = data.frame(prj.grKO.X = prjKO, prj.grIT.X = prjIT)
  datf3_prj2 = cbind(datf3_prj, prj2)
  
  currTot = datf3_prj2[dLast[3], 4]
  prjTotKO = cbind(rep(NA, maxPrjPrd + 1))
  prjTotKO[1] = currTot
  for (i in 1:maxPrjPrd){
    prjTotKO[i+1] = prjTotKO[i] * (1 + prjGRfromDatf7$growth.Korea[i]/100)
  }
  
  prjTotIT = cbind(rep(NA, maxPrjPrd + 1))
  prjTotIT[1] = currTot
  for (i in 1:maxPrjPrd){
    prjTotIT[i+1] = prjTotIT[i] * (1 + prjGRfromDatf7$growth.Italy[i]/100)
  }
  
  prjKO2 = c(rep(NA, dLast[3] - 1), prjTotKO)
  prjIT2 = c(rep(NA, dLast[3] - 1), prjTotIT)
  length(prjKO2) = nrow(datf3_prj)
  length(prjIT2) = nrow(datf3_prj)
  
  datf3_prj2$grKO.prj.tot.X = prjKO2
  datf3_prj2$grIT.prj.tot.X = prjIT2
  
  # Daily new confirmed cases
  # KO, IT
  B1 = datf3_prj2[, 13:14]
  B2 = rbind(rep(NA, 2), B1[1:(nrow(B1) - 1),])
  B3 = B1 - B2
  B4 = (B3 / B2) * 100
  
  colnames(B3) = paste0('dif.', colnames(B1))
  colnames(B4) = paste0('growth.', colnames(B1))
  datf3_prj3 = cbind(datf3_prj2, B3, B4) 
  
  # shift (anchor X to KO) since-dataset to dayFrToday-dataset
  
  lenHeadToadd = max(ITtoKO, XtoKO)
  headNA = matrix(NA, lenHeadToadd, dim(datf3_prj3)[2])
  colnames(headNA) = colnames(datf3_prj3)
  datf3_prj3_algn0 = rbind(headNA, datf3_prj3)
  
  datf3_prj3_algn1 = datf3_prj3_algn0
  datf3_prj3_algn1[, 3] = shift(datf3_prj3_algn0[, 3], n=ITtoKO, fill=NA, type="lead")
  datf3_prj3_algn1[, 4] = shift(datf3_prj3_algn0[, 4], n=XtoKO, fill=NA, type="lead")
  datf3_prj3_algn1[, 6] = shift(datf3_prj3_algn0[, 6], n=ITtoKO, fill=NA, type="lead")
  datf3_prj3_algn1[, 7] = shift(datf3_prj3_algn0[, 7], n=XtoKO, fill=NA, type="lead")
  datf3_prj3_algn1[, 9] = shift(datf3_prj3_algn0[, 9], n=ITtoKO, fill=NA, type="lead")
  datf3_prj3_algn1[, 10] = shift(datf3_prj3_algn0[, 10], n=XtoKO, fill=NA, type="lead")
  
  for (j in 11:18){
    datf3_prj3_algn1[, j] = shift(datf3_prj3_algn0[, j], n=XtoKO, fill=NA, type="lead")
    
  }
  idna = (rowSums(is.na(datf3_prj3_algn1)) == ncol(datf3_prj3_algn1))
  datf3_prj3_algn2 = datf3_prj3_algn1[!idna, ]
  
  dayfrtoday_algn2 = apply(datf3_prj3_algn2[, 2:4], 2, function(x) max(which(!is.na(x))))
  daysFromToday_0 = 1:nrow(datf3_prj3_algn2)
  daysFromToday_2 = daysFromToday_0 - dayfrtoday_algn2[3]
  
  datf3_prj3_algn3 = data.frame(daysFromToday = daysFromToday_2, datf3_prj3_algn2)
  prjStart = datf3_prj3_algn3$dif.X[dayfrtoday_algn2[3]]
  datf3_prj3_algn3$dif.grKO.prj.tot.X[dayfrtoday_algn2[3]] = prjStart
  datf3_prj3_algn3$dif.grIT.prj.tot.X[dayfrtoday_algn2[3]] = prjStart
  
  datf3_prj3_algn3L = datf3_prj3_algn3 
  for (j in 1:numTS){
    datf3_prj3_algn3L[1:(dayfrtoday_algn2[j]-1), j+5] = NA  
  }
  
  
  # plot
  difprjKO0 = datf3_prj3_algn3$dif.grKO.prj.tot.X
  idKO = max(which(!is.na(difprjKO0)))
  difprjKO = round(difprjKO0[idKO])
  
  difprjIT0 = datf3_prj3_algn3$dif.grIT.prj.tot.X
  idIT = max(which(!is.na(difprjIT0)))
  difprjIT = round(difprjIT0[idIT])
  
  #  prjStart = difX
  difX0 = datf3_prj3_algn3$dif.X
  idX = max(which(!is.na(difX0)))
  difX = round(difX0[idX])      
  
  
  myCaptn3 = paste0('If ', stname, ' follows the track of Korea, ', 
                    'its new cases of ', difX, ' today would become ', 
                    difprjKO, ' in ', 
                    daysProjected[1], ' days.')
  myCaptn4 = paste0('If ', stname, ' follows the track of Italy, ', 
                    'its new cases of ', difX, ' today would become ', 
                    difprjIT, ' in ', 
                    daysProjected[2], ' days.')
  
  tmp1 = data.frame(daysFromToday = datf3_prj3_algn3L$daysFromToday, Today = stname, val = datf3_prj3_algn3L$dif.X)
  tmp2 = data.frame(daysFromToday = datf3_prj3_algn3L$daysFromToday, Today = 'Korea.Adj', val = datf3_prj3_algn3L$dif.Korea)
  tmp3 = data.frame(daysFromToday = datf3_prj3_algn3L$daysFromToday, Today = 'Italy.Adj', val = datf3_prj3_algn3L$dif.Italy)
  ggp_datf3_prj3_algn3L = rbind(tmp1, tmp2, tmp3)
  
  fig4 <- ggplot() +
    geom_line(data=datf3_prj3_algn3, aes(daysFromToday, dif.X), size=2, alpha=0.8, color='black') +
    geom_line(data=datf3_prj3_algn3, aes(daysFromToday, dif.Korea), size=2, alpha=0.3, color='blue') +
    geom_line(data=datf3_prj3_algn3, aes(daysFromToday, dif.Italy), size=2, alpha=0.3, color='red') +
    geom_point(data = ggp_datf3_prj3_algn3L, aes(x=daysFromToday, y=val, color=Today), size=4, alpha=1) +
    scale_color_manual(values = c('black', 'blue', 'red')) +
    theme_bw() +
    theme_bw() +
    geom_line(data = datf3_prj3_algn3, aes(daysFromToday, dif.grKO.prj.tot.X), 
              size=2, alpha=0.8, color='blue', linetype='F1') +
    geom_line(data = datf3_prj3_algn3, aes(daysFromToday, dif.grIT.prj.tot.X), 
              size=2, alpha=0.8, color='red', linetype='F1')  
  
  
  fig4out <- fig4 + 
    labs(title = 'Matched/Projected New Cases Per-day', 
         x= paste0('Days from today of ', stname), y='', 
         subtitle = paste0('As of ', curDate, XtotalforMsg), 
         caption = paste0(myCaptn3, '\n', myCaptn4)) +
    theme(plot.title = element_text(hjust = 0.5, size=rel(2)), 
          axis.text = element_text(size = rel(2) ), 
          axis.title = element_text(size=rel(2)), 
          legend.position = 'top', legend.title = element_text(size = rel(1.5)), 
          legend.text = element_text(size = rel(1.5)), 
          plot.caption = element_text(hjust = 0, size = rel(1)))
  print(fig4out)
  
  f4name = paste0(stname, '_newCases_matchedProjected.pdf')
  pdf(file.path(outPath, f4name), width=8, height=4.5)
  Sys.sleep(2)
  print(fig4out)
  Sys.sleep(2)
  dev.off()
  Sys.sleep(4)
  
  
  ##
  ## output
  ##
  
  outname1 = paste0(stname, '_projected_daily_data.csv')
  fname1 = file.path(outPath, outname1)
  outname2 = paste0(stname, '_totalCases_3countries.csv')
  fname2 = file.path(outPath, outname2)
  
  projected_daily_data = datf3_prj3_algn3
  write.csv(projected_daily_data, fname1, row.names = FALSE)
  write.csv(totalCases_3countries, fname2, row.names = T)

  result = list(StateAbb = stname, myCaptn1=myCaptn1, myCaptn2=myCaptn2, 
                myCaptn3=myCaptn3, myCaptn4=myCaptn4)
  return(result)
}

## 
## EOF