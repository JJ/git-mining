#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

                                        #this version of the script has been tested on igraph 1.0.1
                                        #load libraries
# from http://estebanmoro.org/2015/12/temporal-networks-with-r-and-igraph-updated/
require(igraph)
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
edges <- read.table(paste0(args[1], ".csv"),header=T)
 
#generate the full graph
g <- graph.data.frame(edges,directed=F)
 

#time in the edges goes from 1 to 300. We kick off at time 3
ti <- 3
#remove edges which are not present
gt <- delete_edges(g,which(E(g)$time > ti))

                                        #total time of the dynamics
total_time <- max(E(g)$time)

                                        #Time loop starts

measures <- data.frame(commit=character(),
                       degree= character(),
                       betweenness=character(),
                       network.size = character(),
                       connected.size = character(),
                       cc.size = character(),
                       transitivity = character())

for(time in seq(3,total_time)){
                                        #remove edges which are not present
    gt <- delete_edges(g,which(E(g)$time > time))
    betweenness <- betweenness( gt )
    transitivity <- transitivity( gt )

    measures <- rbind( measures,
                      data.frame( commit = time,
                                 degree = mean( degree( gt )),
                                 betweenness = mean(betweenness),
                                 network.size = vcount( gt ),
                                 connected.rate =  components(gt)$csize[[1]]/vcount( gt ),
                                 cc.size = components(gt)$csize[[1]],
                                 transitivity = transitivity ))
    
    
}
save(measures,file=paste0(args[1],"-data.Rda"))
write.table(measures,file=paste0(args[1],"-data.csv"))

