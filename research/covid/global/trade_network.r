# Methods adapted from: https://gist.github.com/rafapereirabr/9a36c2e5ff04aa285fa3

# Load necessary libraries
library(foreign) # reading .dbf files
library(ggplot2) # create plot
library(rgdal) # reading and plotting shapefiles

# Define quantile number, to select only specific arcs (0 for all arcs, 1 for none)
quant <- 0.95

# Read data
data <- read.csv('ExportSeries.csv')
shp.df <- read.dbf('TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.dbf') # attribute table
shp <- readOGR('TM_WORLD_BORDERS-0.3','TM_WORLD_BORDERS-0.3')

# Fortify shapefile for plotting
map <- fortify(shp)

# Convert data to edgelist format
rownames(data) <- data[,1]
data <- data[-1]

# Function for selecting and reorganizing data
reorg <- function(df,y){
    df <- data[,grepl(y,names(data))]
    colnames(df) <- sub(sprintf('.%s',y),'',colnames(df))
    df <- data.frame(ori = rownames(df)[col(df)], des= colnames(df)[row(df)],val=c(t(df)),stringsAsFactors=F)
    df <- df[(df$ori != df$des),] # remove self-loops
}

### DIFFERENCE PLOT
df1 <- reorg(data,'1')
colnames(df1) <- c('ori','des','year1')
df5 <- reorg(data,'5')
colnames(df5) <- c('ori','des','year5')
df <- merge(df1,df5)
df$val <- df$year1 - df$year5 # positive means value actually decreased over time
df <- df[,c('ori','des','val')]

# Add spatial data (lat/lon) to tradeflow data
df <- merge(df,shp.df,by.x='des',by.y='ISO3') # destination
df <- df[,c(1:3,12:13)]
colnames(df) <- c('des','ori','val','des_lon','des_lat')
df <- merge(df,shp.df,by.x='ori',by.y='ISO3') # origin
df <- df[,c(1:5,14:15)]
colnames(df) <- c('ori','des','val','des_lon','des_lat','ori_lon','ori_lat')

# Organize smallest to largest for plotting
df <- df[order(df$val),]

# Limit which arcs to display
df <- df[df$val >= quantile(df$val,quant),]

# Create plot
ggplot() + 
    geom_polygon(data= map, aes(long,lat, group=group), fill='gray30') +
    geom_curve(data = df, aes(x = ori_lon, y = ori_lat, xend = des_lon, yend = des_lat, color=val, alpha=val),curvature = -0.2, arrow = arrow(length = unit(0.01, 'npc'))) +
    scale_colour_gradient(low='#fc9272',high='#de2d26') + # reds
    coord_equal()

ggsave(sprintf('trade_network_dif_year1-year5_quant%s.pdf',((1-quant)*100.)))

### YEAR PLOTS
for (y in unlist(1:5)){

    # Select data
    df <- reorg(data,y)

    # Add spatial data (lat/lon) to tradeflow data
    df <- merge(df,shp.df,by.x='des',by.y='ISO3') # destination
    df <- df[,c(1:3,12:13)]
    colnames(df) <- c('des','ori','val','des_lon','des_lat')
    df <- merge(df,shp.df,by.x='ori',by.y='ISO3') # origin
    df <- df[,c(1:5,14:15)]
    colnames(df) <- c('ori','des','val','des_lon','des_lat','ori_lon','ori_lat')

    # Organize smallest to largest for plotting
    df <- df[order(df$val),]
    
    # Limit which arcs to display
    df <- df[df$val >= quantile(df$val,quant),]

    # Create plot
    ggplot() + 
        geom_polygon(data= map, aes(long,lat, group=group), fill='gray30') +
        geom_curve(data = df, aes(x = ori_lon, y = ori_lat, xend = des_lon, yend = des_lat, color=val, alpha=val),curvature = -0.2, arrow = arrow(length = unit(0.01, 'npc'))) +
        scale_colour_gradient(low='#9ecae1',high='#3182bd') + # blues
        coord_equal()

    ggsave(sprintf('trade_network_year%s_quant%s.pdf',y,((1-quant)*100.)))

}
