# Define quantile number, to select only specific arcs (0 if all arcs desired)
quant <- 0.995

# Define output figure destination
pdf(sprintf('figures/fig4_county_%s.pdf',(1-quant)))

# Read edgelist data
df <- read.csv('results/county_edgelist_clean.csv')
nrow(df)

# Remove HI, AK, and PR
df$ori <- sprintf('%05d',as.numeric(df$ori))
df$des <- sprintf('%05d',as.numeric(df$des))

df$ori_st <- substr(df$ori,start=1,stop=2)
df$des_st <- substr(df$des,start=1,stop=2)

df <- df[!grepl(c('02|15|72'),df$ori_st),]
df <- df[!grepl(c('02|15|72'),df$des_st),]

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
counties <- readOGR('cb_2016_us_county_500k','cb_2016_us_county_500k')
plot(counties,col='white',fill=TRUE,bg='white',border='black',lwd=0.1,xlim=c(-125.0208333,-66.4791667),ylim=c(24.0625000,49.9375000))

# Limit which arcs to display
df <- df[df$total >= quantile(df$total,quant),]
nrow(df)

# Points weighted by total incoming flows
points(x=df$ori_lon,y=df$ori_lat,pch=16,cex=df$ori_sum/max_sum,col='dodgerblue3')

# Color and weighting for arcs
col.1 <- adjustcolor('dodgerblue3',alpha=0.3)
col.2 <- adjustcolor('dodgerblue3',alpha=0.7)
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
