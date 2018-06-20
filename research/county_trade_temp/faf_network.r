# Define quantile number, to select only specific arcs (0 if all arcs desired)
quant <- 0 #0.9

# Define output figure destination
pdf(sprintf('figures/fig4_faf_white_%s.pdf',(1-quant)))

# Read edgelist data
df <- read.csv('results/faf_edgelist_clean.csv')
nrow(df)

# Define origin sums to weight by outgoing flows
ori_sum <- aggregate(total~ori,df,sum)
names(ori_sum)[2] <- 'ori_sum'
df <- merge(df,ori_sum)
max_sum <- max(df$ori_sum)

# Define destination sums to weight by incoming flows
#des_sum <- aggregate(total~des,df,sum)
#names(des_sum)[2] <- 'des_sum'
#df <- merge(df,des_sum)
#max_sum <- max(df$des_sum)

# Map basemap and points
library(rgdal)
fafzones <- readOGR('data/CFS_dissolved_Great_Lakes','CFSArea_DissoCounty_GreatLakes')
plot(fafzones,col='white',fill=TRUE,bg='white',border='black',lwd=0.1,xlim=c(-125,-66),ylim=c(24,50))

# Limit which arcs to display
df <- df[df$total >= quantile(df$total,quant),]
nrow(df)

# Points weighted by total flows
points(x=df$ori_lon,y=df$ori_lat,pch=16,cex=df$ori_sum/max_sum,col='dodgerblue3')

# Color and weighting for arcs
col.1 <- adjustcolor('dodgerblue3',alpha=0.4)
col.2 <- adjustcolor('dodgerblue3',alpha=0.8)
edge.pal <- colorRampPalette(c(col.1,col.2),alpha=TRUE)
edge.col <- edge.pal(100)

# Define and plot arcs
library('geosphere')
for(i in 1:nrow(df)){
	arc <- gcIntermediate( c(df[i,]$ori_lon,df[i,]$ori_lat), c(df[i,]$des_lon,df[i,]$des_lat), n=10000, addStartEnd=TRUE )
	edge.ind <- round( 100*df[i,]$total / max(df$total) )

	lines(arc,col=edge.col[edge.ind],lwd=edge.ind/30)
}

dev.off()
