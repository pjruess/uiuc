# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)
library(stringr) # for str_replace_all

plot_vws <- function(states, vws_state, vws_county, commodity, year, identifier, label, mmdata, ncats=8) {
	# Define path to save to
	path <- sprintf('vws_plots/%s/%s_%s_%s.png', tolower(commodity), year, tolower(commodity), label)

	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		if (commodity != 'total'){ next }
		path <- sprintf('vws_plots/%s/%s_%s_%s.png', tolower(commodity), year, tolower(commodity), label)
	}

	# If vws_path exists, read. Else create. 
	vws <- data.frame()
	vws_path <- sprintf('vws_plot_aggregates/%s_aggregate_%s_data.csv',year,tolower(commodity))

	if (file.exists(vws_path)){
		print(vws_path)
		vws <- read.csv(vws_path)
	} else {
		# Convert to data tables
		vws_state <- data.table(vws_state)
		vws_county <- data.table(vws_county)

		# If commodity is 'total', aggregate sum of vws df by GEOID 
		if (commodity == 'total') {
			vws_county <- vws_county[, 
				.(Storage_Bu = mean(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = list(GEOID,State.ANSI)
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'GEOID'

			vws_county <- vws_county[, 
				.(Storage_Bu = sum(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = State.ANSI
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'State.ANSI'

		} else {
			vws_state <- vws_state[vws_state$Commodity == commodity,]
			vws_county <- vws_county[vws_county$Commodity == commodity,]
			vws_county <- vws_county[, 
				.(Storage_Bu = sum(Storage_Bu,na.rm=TRUE), 
				VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
				VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
				VWS_m3 = sum(VWS_m3,na.rm=TRUE)), 
				by = State.ANSI
			]
			colnames(vws_county)[colnames(vws_county) == 'by' ] <- 'State.ANSI'
		}
		vws <- merge(vws_state,vws_county,by='State.ANSI')
		vws <- data.frame(vws)
		vws$Storage_Bu <- rowSums(vws[,c('Storage_Bu.x','Storage_Bu.y')], na.rm=TRUE)
		vws$VWS_ir_m3 <- rowSums(vws[,c('VWS_ir_m3.x','VWS_ir_m3.y')], na.rm=TRUE)
		vws$VWS_rf_m3 <- rowSums(vws[,c('VWS_rf_m3.x','VWS_rf_m3.y')], na.rm=TRUE)
		vws$VWS_m3 <- rowSums(vws[,c('VWS_m3.x','VWS_m3.y')], na.rm=TRUE)
		vws$Capture_Efficiency <- 100. * vws$VWS_rf_m3 / ( vws$Precipitation_Volume_km3 * 1e9 )

		vws <- vws[,c('State.ANSI','Commodity','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Capture_Efficiency')]
		vws[vws <= 0] <- NA
		write.csv(vws,vws_path,row.names=FALSE)
	}

	# Save min and max for manual assignment across years
	if (!file.exists(minmax.path)){
		#vws[,identifier][vws[,identifier]<=0] <- NA #convert zeros to NA
		minima <- min(vws[,identifier],na.rm=T)
		maxima <- max(vws[,identifier],na.rm=T)
		tempdf <- data.frame(commodity, identifier, year, minima, maxima)
		names(tempdf) <- c('Commodity','Identifier','Year','Minima','Maxima')
		mmdata <- rbind(mmdata, tempdf)
		return(mmdata)
		next
	}

	mmdata.sub <- mmdata[mmdata$Commodity == commodity & mmdata$Identifier == identifier, ]

	if (file.exists(path)){
		next
	}
	
	# Determine minima and maxima for plotting limits
	minima <- min(mmdata.sub$Minima,na.rm=T)
	maxima <- max(mmdata.sub$Maxima,na.rm=T)

	if (minima == floor(minima)){
		minima <- minima - 1
	} else {
		minima <- floor(minima)
	}

	if (maxima == ceiling(maxima)){
		maxima <- maxima + 1
	} else {
		maxima <- ceiling(maxima)
	}

	# Create temp df
	data <- data.frame(id=rownames(states@data),
			   State.ANSI=states@data$STATEFP,
			   NAME=states@data$NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)

	# Correct formatting of vws data for proper merge
	vws$State.ANSI <- sprintf('%02d',vws$State.ANSI)
	
	# Merge databases
	data <- merge(data, vws, by='State.ANSI')

	# Fortify data to extract spatial information
	states.fort <- fortify(states)
	map.df <- join(states.fort, data, by='id')
	map.df$plot_fill <- map.df[,identifier]
	map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(palette='YlGnBu',
				    limits=c( minima, maxima ),
				    direction=1, 
				    na.value='grey90') +
		labs(title=sprintf('%s, %s, %s', str_replace_all(label,'_',' '), tolower(commodity), year),
		    subtitle=sprintf('Min: %s, Max: %s', min(map.df$plot_fill,na.rm=TRUE), max(map.df$plot_fill,na.rm=TRUE) ),
		    x='',
		    y='') +
		theme(panel.grid.major=element_blank(), 
		    panel.grid.minor=element_blank(), 
		    panel.background=element_blank(), 
		    axis.line=element_blank(), 
		    axis.text=element_blank(), 
		    axis.ticks=element_blank())
	
	# Save plot
	ggsave(path,
		width = 7,
		height = 4.25)#, dpi = 1200)
	print(sprintf('Plot saved to %s',path))
	return(mmdata)
}

# Import polygon shapefile
states_data <- readOGR('cb_2016_us_state_500k','cb_2016_us_state_500k')

# Select only by certain commodity
commodities <- c('BARLEY','BUCKWHEAT','CORN,GRAIN','CORN,SILAGE','MILLET,PROSO','OATS','RICE','RYE','SORGHUM,GRAIN','SORGHUM,SILAGE','TRITICALE','WHEAT','total')

# Select years to iterate over
years <- c('2002','2007','2012')

# List of identifiers and labels
#identifiers <- c('Storage_Bu','Irrigated_Harvest_Acre','Rainfed_Harvest_Acre','Irrigated_Percent_Harvest','Rainfed_Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','CWU_bl_and_gn_ir_m3ha','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency')
#labels <- c('storage','irrigated_harvest','rainfed_harvest','irrigated_percent_harvest','rainfed_percent_harvest','yield','production','cwu_blue','cwu_green_irrigated','cwu_green_rainfed','cwu_blue_and_green_irrigated','vws_irrigated','vws_rainfed','vws','precip','precip_volume','capture_efficiency')
identifiers <- c('Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Capture_Efficiency')
labels <- c('storage','vws_irrigated','vws_rainfed','vws','capture_efficiency')

#commodities <- c('total')
#identifiers <- c('Storage_Bu')
#labels <- c('storage')

df <- data.frame(identifiers, labels)
print(df)

# Retrieve minima and maxima data
minmax.path <- 'vws_plots/minmax_database.csv'

if (file.exists(minmax.path)){
	minmax.data <- read.csv(minmax.path)
} else {
	minmax.data <- data.frame(matrix(ncol=5,nrow=0))
	minmax.names <- c('Commodity','Identifier','Year','Minima','Maxima')
	colnames(minmax.data) <- minmax.names
}

# Create plots for all commodity-year-identifier pairs
for (c in commodities) {
	for (i in 1:nrow(df)) {
		for (y in years){
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])
			print(id)
			# Read in VWS data
			vws_state_data <- read.csv( sprintf('state_outputs/final_data_%s.csv', y) )[, c('State.ANSI','Commodity','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_Volume_km3')]
			vws_state_data$State.ANSI <- sprintf('%02d',vws_state_data$State.ANSI)

			vws_county_data <- read.csv( sprintf('county_outputs/final_data_%s.csv', y) )[, c('GEOID','Commodity','Storage_Bu','VWS_ir_m3','VWS_rf_m3','VWS_m3')]
			vws_county_data$GEOID <- sprintf('%05d',vws_county_data$GEOID)
			vws_county_data$State.ANSI <- substr(vws_county_data$GEOID,start=1,stop=2)
			vws_county_data$State.ANSI <- as.numeric(vws_county_data$State.ANSI)
			vws_county_data$State.ANSI <- sprintf('%02d',vws_county_data$State.ANSI)

			# Plot data
			print( sprintf('Plotting %s for commodity %s, year %s', id, c, y) )
			tryCatch({
			       	minmax.data <- plot_vws(states_data, vws_state_data, vws_county_data, c, y, id, label, minmax.data, ncats=8)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}

if (!file.exists(minmax.path)){
	minmax.data <- data.table(minmax.data)
	minmax.data[ , list(Minima = min(Minima), Maxima = max(Maxima)), by=c('Commodity','Identifier') ]
	write.csv(minmax.data,minmax.path,row.names=FALSE)
}
