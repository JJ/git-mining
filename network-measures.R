#!/usr/bin/env Rscript

# use with ./network-evolution.R filename 
# Don't use any extension

args = commandArgs(trailingOnly=TRUE)

                                        #this version of the script has been tested on igraph 1.0.1
                                        #load libraries
require(igraph)
require(tools)

#load the edges with time stamp
#there are three columns in edges: id1,id2,time
edges <- read.table(paste0(args[1], ".csv"),header=T)

                                        #generate the full graph
measures <- data.frame(extension=character(),
                       degree= character(),
                       betweenness=character()
                       )

g <- graph.data.frame(edges,directed=F)
extensions <-  unique(file_ext(V(g)$name))
gt <- simplify(as.undirected(g, mode='each'), edge.attr.comb=list(weight="sum"))
betweenness.gt <- betweenness( gt )
degree.gt <- degree( gt )
for( ext in extensions ){
    with.this.ext <- file_ext( names(betweenness.gt) ) == ext

    measures <- rbind( measures,
                      data.frame(extension = ext,
                                 betweenness = mean(unlist(betweenness.gt[  with.this.ext ])),
                                 degree = mean(unlist(degree.gt[  with.this.ext ]))
                                 )
                      )
}
save(measures,file=paste0(args[1],"-ext-data.Rda"))
write.table(measures,file=paste0(args[1],"-ext-data.csv"))


