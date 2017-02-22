
library(ggplot2)
library("ggfortify")
library(dplyr)
library(TTR)

files <-  read.csv("data/Moose-files-per-commit.csv")

files$SMA10 <- SMA(files$Number.of.files,n=10)
files$SMA20 <- SMA(files$Number.of.files,n=20)

files$x = as.numeric(row.names(files))
ggplot(files) +geom_line(aes(x=x,y=SMA10,color='SMA10'))+geom_line(aes(x=x,y=SMA20,color='SMA20'))+scale_y_log10()


by.lines <- group_by(files,Number.of.files)
lines.count <- summarize(by.lines, count=n())
sizes.fit <- lm(log(1+lines.count$Number.of.files) ~ log(lines.count$count))
repo <- strsplit(paste(summary[[1]][i],""),"_",fixed=T)
ggplot(lines.count, aes(x=Number.of.files, y=count))+geom_point()+scale_x_log10()+scale_y_log10()+stat_smooth()


sorted.lines <- data.frame(x=1:length(files$Number.of.files),Number.of.files=as.numeric(files[order(-files$Number.of.files),]$Number.of.files))
ggplot()+geom_point(data=sorted.lines,aes(x=x,y=Number.of.files))+scale_y_log10()
sorted.lines.no0 <- sorted.lines[sorted.lines$Number.of.files>0,]
zipf.fit <- lm(log(sorted.lines.no0$Number.of.files) ~ sorted.lines.no0$x)


autoplot(pacf(files$Number.of.files, plot=FALSE) )


this.spectrum <- spectrum(files$Number.of.files, plot=FALSE)
autoplot( this.spectrum ) + scale_x_log10() 
spec.fit <- lm(log(this.spectrum$spec) ~ log(this.spectrum$freq))



