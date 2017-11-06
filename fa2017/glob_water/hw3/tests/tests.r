# Load libraries
library(igraph)

# Read in data
df <- read.csv('data.csv',header=TRUE)
el <- as.matrix(df) # edge list
el[,1] <- as.character(el[,1])
el[,2] <- as.character(el[,2])


el

# Create network of data
g <- graph.edgelist(el[,1:2])
E(g)$weight <- as.numeric(el[,3])
g2 <- graph.data.frame(el)

pdf('food_aid_network_plot.pdf')
plot(g,layout=layout.fruchterman.reingold, edge.width=E(g)$weight/2)
dev.off()
