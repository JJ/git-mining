
library(networkD3)
library(igraph)
library(plyr)
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
edges <- read.table("data/rakudo-commit-coo.csv",header=T,quote="\"")
colnames(edges) <- c("SourceName", "TargetName", "Weight")

#generate the full graph
#taken from http://www.vesnam.com/Rblog/viznets6/
gD <- simplify(graph.data.frame(edges,directed=F))
nodeList <- data.frame(ID = c(0:(vcount(gD) - 1)), # because networkD3 library requires IDs to start at 0
                       nName = V(gD)$name)

# Map node names from the edge list to node IDs
getNodeID <- function(x){
  which(x == V(gD)$name) - 1 # to ensure that IDs start at 0
}
# And add them to the edge list
edgeList <- ddply(edges, .variables = c("SourceName", "TargetName", "Weight"), 
                  function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                                          TargetID = getNodeID(x$TargetName)))

# Calculate degree for all nodes
nodeList <- cbind(nodeList, nodeDegree=degree(gD, v = V(gD), mode = "all"))

# Calculate betweenness for all nodes
betAll <- betweenness(gD, v = igraph::V(gD), directed = FALSE) / (((vcount(gD) - 1) * (vcount(gD)-2)) / 2)
betAll.norm <- (betAll - min(betAll))/(max(betAll) - min(betAll))
nodeList <- cbind(nodeList, nodeBetweenness=100*betAll.norm) # We are scaling the value by multiplying it by 100 for visualization purposes only (to create larger nodes)
rm(betAll, betAll.norm)

forceNetwork(Links = edgeList, Nodes = nodeList, 
             Source = 'SourceID', Target = 'TargetID', 
             NodeID = 'nName', Group = 'nodeDegree',
             Nodesize = "nodeBetweenness",
             zoom= T, 
             fontSize = 24, fontFamily = 'serif')
