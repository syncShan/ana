source("r/metrics.R")
source("r/turtleFunc.R")

idList = unique(allStock$id)
dayList = list(5,10,20,30,60,350)

calc = function(i,count){
  calTrueFluc(i)
  #20 low
  calAvgTFFluc(i,count)
  lapply(dayList, calAvgTypeDays,i=i,count=count,type="Close")
  lapply(dayList, calAvgTypeDays,i=i,count=count,type="High")
  lapply(dayList, calAvgTypeDays,i=i,count=count,type="Low")
}


stocks = list()

#for( index in 1:6){
for( index in 1:length(idList)){
  print(paste("handling stock: ",idList[index]))
  for(type in c("Close","High","Low")){
    for(day in dayList){
      assign(paste("sum",type,day,sep=""),0)
    }
  }
  assign("single",subset(allStock,allStock$id == idList[index]),envir =.GlobalEnv)
  if(nrow(single) < 360) {
    print("data not enough continue...")
    next
  }
  count = 0
  for(i in  3:(nrow(single)-1)){
    count = count + 1
    calc(i,count)
    single[i,"twoDayAgoClose"] = single[i-2,"Close"]
  }
  stocks[[index]] = single
}
select = (sapply(lapply(stocks,colnames),length) == 28)
allData = do.call(rbind, stocks[select])
write.csv(allData,file = "allData.csv")
