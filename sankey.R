
library(networkD3)
library(igraph)
library(readgdf)

library(plyr)
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
data <- read_gdf("data/extensions-pandoc.gdf")
data.D3 <- igraph_to_networkD3( data )
