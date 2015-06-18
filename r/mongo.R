library(rmongodb)
library(rjson)
mg2 <- mongo.create()

print(mongo.get.databases(mg2))
namespace <- "database.stocks"
print(mongo.get.database.collections(mg2, namespace))

insertHistory = function(id,mongoConnection,tableName){
  if(!mongo.is.connected(mongoConnection)){
    print("mongo connection is already closed!")
    return
  }
  input = read.table(paste("data/history/",id,".csv",sep=""),sep=",",header = TRUE)
  id = uniType(id)
  print(paste("start to insert ",id," with ", nrow(input), sep =""))
  input$id=id
  for( i in seq(1,nrow(input))){
    json = toJSON(input[i,])
    bson = mongo.bson.from.JSON(json)
    if(!mongo.insert(mongoConnection,tableName,bson)){
      print(paste("failed to insert:",json))
    }
  }
}
historyFiles = as.list(str_replace(list.files("data/history/"),".csv",""))

lapply(historyFiles,insertHistory, mongoConnection=mg2,tableName = namespace)
json = toJSON(unname(split(test, 1:nrow(test))))
bson = mongo.bson.from.JSON(json)
mongo.insert(mg2,ns,bson)

buf <- mongo.bson.buffer.create()
mongo.bson.buffer.start.object(buf, 'AGE')
mongo.bson.buffer.append(buf, '$lt', 10)
mongo.bson.buffer.finish.object(buf)
mongo.bson.buffer.start.object(buf, 'LIQ')
mongo.bson.buffer.append(buf, '$gte', 0.1)
mongo.bson.buffer.finish.object(buf)
mongo.bson.buffer.start.object(buf, 'IND5A')
mongo.bson.buffer.append(buf, '$ne', 1)
mongo.bson.buffer.finish.object(buf)
query <- mongo.bson.from.buffer(buf)
cur <- mongo.find(mg2, 'db.test', query = query)
age <- liq <- ind5a <- NULL
while (mongo.cursor.next(cur)) {
  value <- mongo.cursor.value(cur)
  age   <- rbind(age, mongo.bson.value(value, 'AGE'))
  liq   <- rbind(liq, mongo.bson.value(value, 'LIQ'))
  ind5a <- rbind(ind5a, mongo.bson.value(value, 'IND5A'))
}
mongo.destroy(mg2)
data2 <- data.frame(AGE = age, LIQ = liq, IND5A = ind5a)
summary(data2)