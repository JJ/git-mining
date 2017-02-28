library(jsonlite)
library(networkD3)
 
#load the edges with time stamp
#there are three columns in edges: id1,id2,time
fcmn <- fromJSON("data/extensions-pandoc.json")

sankeyNetwork(Links = fcmn$links, Nodes = fcmn$nodes, Source = "source",
              Target = "target", Value = "weight", NodeID = "name",
              fontSize = 12, nodeWidth = 30, sinksRight=T)
