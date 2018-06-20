library(igraph)
library(data.table)
library(ggplot2)

pdf('test_network_metrics.pdf')

faf <- data.frame(fread('results/faf_edgelist_clean.csv'))

g <- graph.edgelist(as.matrix(faf[2:3]))#,directed=TRUE) # second and third columns are origins and destinations

#plot(degree.distribution(g,cumulative=T),pch=20,main='Cumulative Degree Distribution',xlab='',ylab='')

E(g)$weight <- as.numeric(faf[,1]) # first column is weights
#plot(degree.distribution(g,cumulative=T),pch=20,main='Cumulative Strength Distribution',xlab='',ylab='')
#plot(g,layout=layout.fruchterman.reingold,edge.width=E(g)$weight)


#plot(degree.distribution(g,cumulative=T,mode='total'),pch=20,main='Cumul Deg Dist',xlab='',ylab='')

deg.dist <- function (g,type='degree',cumulative=TRUE,mode='total') {
	if (type == 'strength') {
		cs <- strength(g,mode=mode)
	} else {
		cs <- degree(g,mode=mode)
	}
	hi <- hist(cs, -1:max(cs), plot=FALSE)$density
	if (!cumulative) {
		res <- hi
	}
	else {
		res <- rev(cumsum(rev(hi)))
	}
	res
}


plot(deg.dist(g,cumulative=T,mode='total'),pch=20,main='Cumul Deg Dist',xlab='',ylab='')
plot(deg.dist(g,type='strength',cumulative=T,mode='total'),pch=20,main='Cumul Str Dist',xlab='',ylab='')




strength.distribution <- function (graph, cumulative=FALSE, ...){
	if (!is.igraph(graph)) {
		stop("Not a graph object")
	}
	# graph.strength() instead of degree()
	cs <- graph.strength(graph, ...)
	hi <- hist(cs, -1:max(cs), plot = FALSE)$density
	if (!cumulative) {
	       	res <- hi
	}
	else {
		res <- rev(cumsum(rev(hi)))
        }
	res
}

plot(strength.distribution(g,cumulative=T,mode='total'),pch=20,main='Cumul Str Dist',xlab='',ylab='')

#degs <- degree(g)
#hist <- as.data.frame(table(degs))

#ggplot(hist,aes=(x=g.degs,y=Freq)) + 
#	geom_point() + 
#	scale_x_continuous('Degree') + 
#	scale_y_continuous('Frequency') + 
#	ggtitle('Degree Distribution') + 
#	theme_bw()

strength(g)

hist(degree(g),main='Degree Distribution',col='grey',xlab='',ylab='')
hist(strength(g),main='Strength Distribution',col='grey',xlab='',ylab='')
hist(closeness(g),main='Closeness Distribution',col='grey',xlab='',ylab='')
#hist(betweenness(g),main='Betweenness Centrality Distribution',col='grey',xlab='',ylab='')
hist(eigen_centrality(g)$vector,main='Eigenvector Centrality Distribution',col='grey',xlab='',ylab='')


dev.off()

#pdf('county_network_metrics.pdf')
#
#cnty <- data.frame(fread('results/county_edgelist_clean.csv'))
#
#c <- graph.edgelist(as.matrix(cnty[2:3]))#,directed=TRUE) # second and third columns are origins and destinations
#
#E(c)$weight <- as.numeric(cnty[,1]) # first column is weights
#
##plot(c,layout=layout.fruchterman.reingold,edge.width=E(c)$weight)
#
#hist(degree(c),main='Degree Distribution',col='grey',xlab='',ylab='')
#hist(strength(c),main='Strength Distribution',col='grey',xlab='',ylab='')
#hist(closeness(c),main='Closeness Distribution',col='grey',xlab='',ylab='')
##hist(betweenness(c),main='Betweenness Centrality Distribution',col='grey',xlab='',ylab='')
#hist(eigen_centrality(c)$vector,main='Eigenvector Centrality Distribution',col='grey',xlab='',ylab='')
#
#dev.off()
#
