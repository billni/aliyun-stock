#############
### Merge all files
#############
fun_merge_main_cost <- function() {
    
    #### read data to plot ####
    stock.main.cost <- read.table("/var/R/aliyun-stock/mergeddata/data.txt", header=T, blank.lines.skip = TRUE, stringsAsFactors=F,  colClasses=c("character","character","character"))      
    
    #### specify pdf file ####
    pdf("/var/R/aliyun-stock/output/main_cost.pdf")    
    
    opar <- par(no.readonly=T)
    par(lty=2, pch=19, mfrow=c(1,1))
    
    stockcode <- levels(as.factor(stock.main.cost[,1]))
    loopnum <-  length(stockcode)
    for(i in 1:loopnum) {
      target <- stock.main.cost[which(stock.main.cost$code==stockcode[i]),]
      plot(target[,4], type="b", xlab=paste(min(target[,3]), "to", max(target[,3])), ylab="Price", xlim=c(1,nrow(target)), xaxt="n")
      #text(x=target[,4], labels=target[,3], pos=2, col="red", cex = 0.5)
      text(x=target[,4], labels=target[,4], pos=3, col="blue",  cex=0.7)      
      title(main=target[1,c(1,2)])
    }
    
    par(opar)
    dev.list()
    dev.off(dev.cur())
    print("Please to see main_cost.pdf")
}