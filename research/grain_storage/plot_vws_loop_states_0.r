# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)

plot_vws <- function(states, vws, commodity, year, identifier, label, ncats=8) {

	# Define path to save to
	path <- sprintf('state_plots/%s_%s_plot_%s.png', year, label, tolower(commodity))
	
	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		if (commodity != 'ALL'){ next }
		path <- sprintf('state_plots/%s_%s_plot.png', year, label)
		if (file.exists(path)){
			next
		}
	}

	# If commodity is ALL, aggregate sum of vws df by State.ANSI 
	if (commodity == 'ALL') {
		vws <- setDT(vws)[, lapply(.SD, sum, na.rm=TRUE), by=.(State.ANSI,Storage_Bu), .SDcols=c('Harvest_Acre','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')]
		setDT(vws)
		vws[vws == 0] <- NA
		write.csv(vws,sprintf('state_plots/%s_aggregate_%s_data.csv',year,label))
	} else {
		vws <- vws[ which( vws$Commodity == commodity ), ]
	}

	# Create temp df
	data <- data.frame(id=rownames(states@data),
			   State.ANSI=states@data$STATEFP,
			   NAME=states@data$NAME)
	# Convert from factor to character
	data$id <- as.character(data$id)

	# Merge databases
	data <- merge(data, vws, by='State.ANSI')

	# Fortify data to extract spatial information
	counties.fort <- fortify(states)
	map.df <- join(counties.fort, data, by='id')
	map.df$plot_fill <- map.df[,identifier]

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(palette='YlGnBu',
				     limits=c( min(map.df$plot_fill,na.rm=T), max(map.df$plot_fill,na.rm=T) ),
				     direction=1, 
				     na.value='grey90') +
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
}

# Import polygon shapefile
states_data <- readOGR('cb_2016_us_state_500k/','cb_2016_us_state_500k')

# Select only by certain commodity
commodities <- c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT','ALL')

# Select years to iterate over
years <- c('2002','2007','2012')

# List of identifiers and labels
identifiers <- c('Storage_Bu','Harvest_Acre','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')
labels <- c('storage','harvest','yield','production','vwc','vws_yield','vws_production')
df <- data.frame(identifiers, labels)
print(df)

# Create plots for all commodity-year-identifier pairs
for (c in commodities) {
	for (y in years) {
		for (i in 1:nrow(df)){
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])
			print(id)
			# Read in VWS data
			vws_data <- read.csv( sprintf('state_outputs/final_data_%s.csv', y) )
			vws_data$State.ANSI <- sprintf('%02d',vws_data$State.ANSI)

			# Plot data
			print( sprintf('Plotting %s for commodity %s, year %s', id, c, y) )
			tryCatch({
			       	plot_vws(states_data, vws_data, c, y, id, label, ncats=8)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}
