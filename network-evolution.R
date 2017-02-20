#this version of the script has been tested on igraph 1.0.1
                                        #load libraries
# from http://estebanmoro.org/2015/12/temporal-networks-with-r-and-igraph-updated/
require(igraph)
require("RColorBrewer")
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
edges <- read.table("vue-edges.csv",header=T)
 
#generate the full graph
g <- graph.data.frame(edges,directed=F)
 

#time in the edges goes from 1 to 300. We kick off at time 3
ti <- 3
#remove edges which are not present
gt <- delete_edges(g,which(E(g)$time > ti))

                                        #total time of the dynamics
total_time <- max(E(g)$time)

                                        #Time loop starts

for(time in seq(3,total_time)){
  #remove edges which are not present
  gt <- delete_edges(g,which(E(g)$time > time))
  #with the new graph, we update the layout a little bit
    
}
dev.off()

