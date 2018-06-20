# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
# library(colorspace)
library(data.table)
# library(latticeExtra)

plot_vws <- function(counties, vws, commodity, year, identifier, label, ncats=8) {

	# Define path to save to
	path <- sprintf('plots/%s_%s_plot_%s.pdf', year, label, tolower(commodity))
	
	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		# if (commodity != 'ALL'){ next }
		path <- sprintf('plots/%s_%s_plot.pdf', year, label)
		if (file.exists(path)){
			next
		}
	}


	if (commodity == 'ALL') {
		# vws <- aggregate(cbind(Percent_Harvest,Yield_Bu_per_Acre,VWC_m3ha,Storage_Bu,VWS_m3)~GEOID, 
		# 		 data = vws, 
		# 		 sum, 
		# 		 na.rm = TRUE
		# 		 )
		vws <- setDT(vws)[, lapply(.SD, sum, na.rm=TRUE), by=.(GEOID,Storage_Bu), .SDcols=c('Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')]
		setDT(vws)
		write.csv(vws,sprintf('plots/%s_aggregate_%s_data.csv',year,label))
	# 	vws <- as.data.table(vws)
	# 	vws <- vws[ , .(Total_Percent_Harvest=sum(Percent_Harvest),
	# 			Total_Yield_Bu_per_Acre=sum(Yield_Bu_per_Acre),
	# 			Total_VWC_m3ha=sum(VWC_m3ha),
	# 			Total_Storage_Bu=sum(Storage_Bu),
	# 			Total_VWS_m3=sum(VWS_m3),by=GEOID)]
	} else {
		vws <- vws[ which( vws$Commodity == commodity ), ]
	}
	# Create temp df
	data <- data.frame(id=rownames(counties@data),
			   GEOID=counties@data$GEOID,
			   NAME=counties@data$NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)
	
	# Merge databases
	data <- merge(data, vws, by='GEOID')
	# print(head(data))
	# Fortify data to extract spatial information
	counties.fort <- fortify(counties)
	# print(head(counties.fort))
	map.df <- join(counties.fort, data, by='id')
	# map.df <- as.data.frame(map.df)
	# print(identifier)
	map.df$plot_fill <- map.df[,identifier]
	# map.df$plot_fill_zeros <- map.df[,identifier]
	# print( map.df[93700,] )
	# map.df$plot_fill[map.df$plot_fill == 0] <- NA

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		# geom_polygon(data=subset(map.df, plot_fill_zeros == 0), aes(group=group), fill='black') +
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(palette='YlGnBu',
				     limits=c( min(map.df$plot_fill,na.rm=T), max(map.df$plot_fill,na.rm=T) ),
				     direction=1, 
				     na.value='grey90') +
		# scale_fill_gradient(low = '#ffffcc', high = '#ff4444', 
		# 		    space = 'Lab', na.value = 'grey80',
		# 		    guide = 'colourbar') +
		labs(title=sprintf('%s for %s, %s', identifier, commodity, year),
		     subtitle=sprintf('Min: %s, Max: %s',min(map.df$plot_fill,na.rm=T),max(map.df$plot_fill,na.rm=T)),
		     x='',
		     y='') +
		theme(panel.grid.major=element_blank(), 
		      panel.grid.minor=element_blank(), 
		      panel.background=element_blank(), 
		      axis.line=element_blank(), 
		      axis.text=element_blank(), 
		      axis.ticks=element_blank())
	
	# Save plot
	ggsave(path)
	print(sprintf('Plot saved to %s',path))
	
	# # Create plot
	# result <- spplot(counties_vws, # data to plot
	#        main = sprintf('Virtual Water Storage of US Counties - %s', commodity),
	#        zcol='VWS_m3', # attribute to plot
	#        xlim=c(-125, -66),ylim=c(24, 50), # spatial extent 
	#        col.regions = brewer.pal(n=ncats,name='Blues'),
	#        cuts=(ncats-1),
	#        lwd=0.5
	#        # col = 'transparent' # no borders
	#        ) + layer_(sp.polygons(counties_vws, fill='grey99',lwd=0.5),data=list(counties_vws$VWS_m3))#,col='transparent'))

	# # Start plotting device
	# path <- sprintf('plots/vws_plot_%s.pdf', tolower(commodity))
	# print(path)
	# pdf(path)

	# print(result)
	# # system(paste0('open "', path, '"'))	
	# dev.off()
}

# Import polygon shapefile: readOGR('path','filename')
# No extension necessary (this function ONLY imports shapefiles)
counties_data <- readOGR('cb_2016_us_county_500k/','cb_2016_us_county_500k')


# Select only by certain commodity
commodities <- c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT','ALL')

# Select years to iterate over
years <- c('2002','2007','2012')

# List of identifiers and labels
identifiers <- c('Storage_Bu','Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')
labels <- c('storage','percent_harvest','yield','production','vwc','vws_yield','vws_production')
df <- data.frame(identifiers, labels)
print(df)
for (c in commodities) {
	for (y in years) {
		for (i in 1:nrow(df)){
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])
			print(id)
			# Read in VWS data
			vws_data <- read.csv( sprintf('county_outputs/final_data_%s.csv', y) )
			vws_data$GEOID <- sprintf('%05d',vws_data$GEOID)

			# Plot data
			print( sprintf('Plotting %s for commodity %s, year %s', id, c, y) )
			tryCatch({
			       	plot_vws(counties_data, vws_data, c, y, id, label, ncats=8)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}
       

# plot(counties_vws,col=counties_vws$VWS_m3, border=NA)
# ggplot(counties_vws,xlim=c(-125, -66.885444),ylim=c(24.396308, 49.384358))

# Aggregate to include data for one commodity only
# counties <- aggregate(VWS_m3~Commodity, counties, sum) # Sum of VWS_m3 

# counties_vws.df <- as(counties_vws, 'data.frame')

