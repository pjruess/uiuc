# Load libraries
library(igraph)

# Read in data
df <- read.csv('food_aid_matrix_stacked.csv',header=TRUE)
el <- as.matrix(df) # edge list
el[,1] <- as.character(el[,1])
el[,2] <- as.character(el[,2])

# Create network of data
g <- graph.edgelist(el[,1:2],directed=T)
E(g)$weight <- as.numeric(el[,3])
g2 <- graph.data.frame(el,directed=T)

# pdf('food_aid_network_plot.pdf')
# plot(g2,layout=layout.fruchterman.reingold, vertex.size=2, vertex.frame.color=NULL, vertex.label.dist=0.5, vertex.label.cex=0.7, edge.width=0.5)#, edge.width=E(g)$weight/2)
# dev.off()

t <- transitivity(g,type='global')
