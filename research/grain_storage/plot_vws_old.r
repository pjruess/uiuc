# For vector work; sp package loads with rgdal packages
library(rgdal)

# For metadata/attributes in vector or raster format
library(raster)

# For plotting
library(ggplot2)
library(maptools)
library(plyr)
library(sp)
library(RColorBrewer)
library(latticeExtra)

# Import polygon shapefile: readOGR('path','filename')
# No extension necessary (this function ONLY imports shapefiles)
counties <- readOGR('cb_2016_us_county_500k/','cb_2016_us_county_500k')
# counties@data$id <- rownames(counties@data)
# counties.coords <- fortify(counties, region='id')
# counties.df <- join(counties.coords, counties@data, by='id')

# Read in VWS data
vws <- read.csv('vws_final_data.csv')

# Select only by certain commodity
commodities = c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT')
vws <- vws[ which( vws$Commodity == 'CORN' ), ]

# Create temp df
data <- data.frame(id=rownames(counties@data),
		   GEOID=counties@data$GEOID,
		   NAME=counties@data$NAME)

# Convert from factor to character
data$id <- as.character(data$id)

# Merge databases
data <- merge(data,vws,by='GEOID')

# Fortify data to extract spatial information
counties.fort <- fortify(counties)
map.df <- join(counties.fort, data, by='id')

# Plot data
ggplot(map.df, aes(x=long,y=lat,group=group)) + 
	geom_polygon(aes(fill=VWS_m3)) + 
	coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
	scale_fill_distiller(palette='Blues', na.value='grey80') +
	# scale_fill_gradient(low = '#ffffcc', high = '#ff4444', 
	# 		    space = 'Lab', na.value = 'grey80',
	# 		    guide = 'colourbar') +
	labs(title='VWS Plot',x='',y='') +
	theme(panel.grid.major=element_blank(), 
	      panel.grid.minor=element_blank(), 
	      panel.background=element_blank(), 
	      axis.line=element_blank(), 
	      axis.text=element_blank(), 
	      axis.ticks=element_blank())

# Save plot
ggsave('vws_test_ggsave.pdf')

break
# counties_vws <- merge(counties,vws,by='GEOID',duplicateGeoms=TRUE)
# counties_vws.coords <- fortify(counties_vws, region='GEOID')
# counties_vws.df <- join(counties_vws.coords, counties_vws@data, by='GEOID')
# counties_vws.df <- as(counties_vws, 'data.frame')

# Start plotting device
pdf('vws_test_plot.pdf')

# counties_vws.df
ncats = 8 # number of color categories

# counties_vws.coords <- fortify(counties_vws, region='GEOID')
# counties_vws.df = join(counties_vws.coords, counties_vws@data, by='GEOID')

head(counties_vws.df)

ggplot(data=counties_vws.df, aes(x=long,y=lat,group=group,fill=VWS_m3))

# spplot(counties_vws, # data to plot
#        main = 'Virtual Water Storage of US Counties - ',
#        zcol='VWS_m3', # attribute to plot
#        # xlim=c(-124.848974, -66.885444),ylim=c(24.396308, 49.384358), # spatial extent
#        xlim=c(-125, -66),ylim=c(24, 50), # spatial extent 
#        col.regions = brewer.pal(n=ncats,name='Blues'),
#        cuts=(ncats-1),
#        lwd=0.5
#        # col = 'transparent' # no borders
#        ) + layer_(sp.polygons(counties_vws, fill='grey99',lwd=0.5))#,col='transparent'))
       

# plot(counties_vws,col=counties_vws$VWS_m3, border=NA)
# ggplot(counties_vws,xlim=c(-125, -66.885444),ylim=c(24.396308, 49.384358))

# Aggregate to include data for one commodity only
# counties <- aggregate(VWS_m3~Commodity, counties, sum) # Sum of VWS_m3 

dev.off()
