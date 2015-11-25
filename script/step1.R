fun_1_control <- function() {
  gc()
starttime <- Sys.time()

###########################################
stocklist <- read.csv("stocklist.txt", header=T, colClasses=c("character","character"), col.names=c("code","name"))
stocklist <- stocklist[substr(stocklist$code,1,1)!=3,]
stocklist <- stocklist[order(stocklist$code),]
checkmarket <- function(stock) {
  ifelse(substr(stock, 1, 1)==6, "sh", "sz")
}
stocklist$market <- apply(stocklist[,1,drop=F], 1, checkmarket)
stocklist$market <- paste(stocklist$code, stocklist$market, sep=".")

getmaincost <- function(stock, i) {
  library(RCurl)
  library(XML)  
  d <- debugGatherer()
  html.url <- paste("http://stockdata.stock.hexun.com/zlkp/s", stock[i, "code"], ".shtml", sep="")
  html.page <- htmlTreeParse(getURL(html.url, .encoding="utf-8", .opts = list(debugfunction=d$update,verbose = TRUE)), useInternalNode=T)
  html.content.1 <- getNodeSet(doc=html.page, path = "//div[@class='s_box']//p[@class='text_01']")
  s <- sapply(html.content.1, xmlValue, encoding="utf-8")
  #yyyymmdd
  start <- regexpr("������" , s[1])
  end <- gregexpr("��" , s[1])  
  stock[i, "������������"] <- substr(s[1], start+3, end[[1]][2]) 
  stock[i, "������������"]  <- gsub("��", "-", stock[i, "������������"])
  stock[i, "������������"]  <- gsub("��", "-", stock[i, "������������"])
  stock[i, "������������"]  <- gsub("��", "", stock[i, "������������"])
    
  # main control level
  start <- regexpr("�ù�Ϊ" , s[1])
  end <- regexpr("��" , s[1])
  stock[i, "���̶̳�"] <- substr(s[1], start+3, end) 
    
  # main cost value
  start <- regexpr("�����ɱ�" , s[1])
  end <- regexpr("Ԫ" , s[1])
  stock[i, "main_cost_value"]<- as.numeric(substr(s[1], start+4, end-1))

  html.content.2 <- getNodeSet(doc=html.page, path = "//div[@class='s_box']/h3[@class='title_01']")
  s <- sapply(html.content.2, xmlValue, encoding="utf-8")
  #��Ʊ����
  start <- 1
  end <- regexpr("����" , s[1])
  stock[i, "name"] <- substr(s[1], start, end-1) 
  
  stock[i,]
}


  ################������ȡ�����ɱ�###########################
  library(foreach)
  library(doParallel)
  n <- nrow(stocklist)
  
  cl <- makeCluster(5)
  registerDoParallel(cl)
  stock.main.cost <- foreach(j=1:n, .combine="rbind", .errorhandling="remove") %dopar% getmaincost(stocklist, j)
  stopCluster(cl)
  print(Sys.time()-starttime)
  stock.main.cost
}