# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)
library(stringr) # for str_replace_all

plot_vws <- function(states, vws, commodity, year, identifier, label, mmdata, ncats=8) {

	# Define path to save to
	path <- sprintf('state_plots/%s/%s_%s_%s.png', tolower(commodity), year, tolower(commodity), label)
	
	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		if (commodity != 'total'){ next }
		path <- sprintf('state_plots/%s/%s_%s_%s.png', tolower(commodity), year, tolower(commodity), label)
	}

	# If commodity is 'total', aggregate sum of vws df by GEOID 
	if (commodity == 'total') {
		vws <- setDT(vws)[, 
			.(Irrigated_Harvest_Acre = mean(Irrigated_Harvest_Acre,na.rm=TRUE), 
			Rainfed_Harvest_Acre = mean(Rainfed_Harvest_Acre,na.rm=TRUE), 
			Irrigated_Percent_Harvest = sum(Irrigated_Percent_Harvest,na.rm=TRUE), 
			Rainfed_Percent_Harvest = sum(Rainfed_Percent_Harvest,na.rm=TRUE), 
			#Yield_Bu_per_Acre = mean(Yield_Bu_per_Acre,na.rm=TRUE), 
			Production_Bu = sum(Production_Bu,na.rm=TRUE), 
			Storage_Bu = mean(Storage_Bu,na.rm=TRUE), 
			CWU_bl_m3ha = mean(CWU_bl_m3ha,na.rm=TRUE), 
			CWU_gn_ir_m3ha = mean(CWU_gn_ir_m3ha,na.rm=TRUE), 
			CWU_gn_rf_m3ha = mean(CWU_gn_rf_m3ha,na.rm=TRUE), 
			CWU_bl_and_gn_ir_m3ha = mean(CWU_bl_and_gn_ir_m3ha,na.rm=TRUE), 
			VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
			VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
			VWS_m3 = sum(VWS_m3,na.rm=TRUE), 
			Precipitation_mm = mean(Precipitation_mm,na.rm=TRUE), 
			Precipitation_Volume_km3 = mean(Precipitation_Volume_km3,na.rm=TRUE), 
			Capture_Efficiency = sum(Capture_Efficiency,na.rm=TRUE)), 
			by = State.ANSI  
		]
		#vws <- setDT(vws)[, lapply(.SD, sum, na.rm=TRUE), by=.(State.ANSI,Storage_Bu), .SDcols=c('Irrigated_Harvest_Acre','Rainfed_Harvest_Acre','Irrigated_Percent_Harvest','Rainfed_Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','CWU_bl_and_gn_ir_m3ha','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_km','Precipitation_Volume_km3','Capture_Efficiency')]
		#setDT(vws)
		vws$Yield_Bu_per_Acre <- vws$Production_Bu / ( vws$Irrigated_Harvest_Acre + vws$Rainfed_Harvest_Acre )
		vws <- data.frame(vws)
		write.csv(vws,sprintf('state_plot_aggregates/%s_aggregate_%s_data.csv',year,label),row.names=FALSE)
	} else {
		vws <- vws[ which( vws$Commodity == commodity ), ]
	}

	# Save min and max for manual assignment across years
	if (!file.exists(minmax.path)){
		vws[,identifier][vws[,identifier]<=0] <- NA #convert zeros to NA
		minima <- min(vws[,identifier],na.rm=T)
		maxima <- max(vws[,identifier],na.rm=T)
		tempdf <- data.frame(commodity, identifier, year, minima, maxima)
		names(tempdf) <- c('Commodity','Identifier','Year','Minima','Maxima')
		mmdata <- rbind(mmdata, tempdf)
		return(mmdata)
		next
	}

	cwu_ids <- c('CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha')
	if(identifier %in% cwu_ids){
		mmdata.sub <- mmdata[mmdata$Commodity == commodity & mmdata$Identifier %in% cwu_ids, ]
	} else {
		mmdata.sub <- mmdata[mmdata$Commodity == commodity & mmdata$Identifier == identifier, ]
	}

	if (file.exists(path)){
		next
	}
	
	# Determine minima and maxima for plotting limits
	minima <- min(mmdata.sub$Minima,na.rm=T)
	maxima <- max(mmdata.sub$Maxima,na.rm=T)

	if (minima == floor(minima)){
		minima <- minima - 1
		#if (minima < 0) {
		#	minima <- 0
		#}
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
	
	# Merge databases
	data <- merge(data, vws, by='State.ANSI')

	# Fortify data to extract spatial information
	states.fort <- fortify(states)
	map.df <- join(states.fort, data, by='id')
	map.df$plot_fill <- map.df[,identifier]
	map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA
	#write.csv(map.df,sprintf('state_plots/TEST_%s_aggregate_%s_data.csv',year,label),row.names=FALSE)

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
identifiers <- c('Storage_Bu','Irrigated_Harvest_Acre','Rainfed_Harvest_Acre','Irrigated_Percent_Harvest','Rainfed_Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','CWU_bl_and_gn_ir_m3ha','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency')
labels <- c('storage','irrigated_harvest','rainfed_harvest','irrigated_percent_harvest','rainfed_percent_harvest','yield','production','cwu_blue','cwu_green_irrigated','cwu_green_rainfed','cwu_blue_and_green_irrigated','vws_irrigated','vws_rainfed','vws','precip','precip_volume','capture_efficiency')

# Override to plot only what I want right now
#identifiers <- c('VWS_ir_m3','VWS_rf_m3','VWS_m3')
#labels <- c('vws_irrigated','vws_rainfed','vws')
#commodities <- c('total')

df <- data.frame(identifiers, labels)
print(df)

# Retrieve minima and maxima data
minmax.path <- 'state_plots/minmax_database.csv'

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
			vws_data <- read.csv( sprintf('state_outputs/final_data_%s.csv', y) )
			vws_data$State.ANSI <- sprintf('%02d',vws_data$State.ANSI)

			# Plot data
			print( sprintf('Plotting %s for commodity %s, year %s', id, c, y) )
			tryCatch({
			       	minmax.data <- plot_vws(states_data, vws_data, c, y, id, label, minmax.data, ncats=8)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}

if (!file.exists(minmax.path)){
	minmax.data <- data.table(minmax.data)
	minmax.data[ , list(Minima = min(Minima), Maxima = max(Maxima)), by=c('Commodity','Identifier') ]
	write.csv(minmax.data,minmax.path,row.names=FALSE)
}
