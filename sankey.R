
library(networkD3)
library(igraph)
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
data <- read.graph("data/extensions-pandoc.net",format='pajek')
data.D3 <- igraph_to_networkD3( data )
