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

    ### Pre-process data and define useful functions

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
			.(Harvest_Ac = sum(Harvest_Ac,na.rm=TRUE), 
			Percent_Harvest = sum(Percent_Harvest,na.rm=TRUE), 
			Production_Bu = sum(Production_Bu,na.rm=TRUE), 
			Storage_Bu = mean(Storage_Bu,na.rm=TRUE), 
			CWU_bl_m3yr = sum(CWU_bl_m3yr,na.rm=TRUE), 
			CWU_gn_m3yr = sum(CWU_gn_m3yr,na.rm=TRUE), 
			CWU_m3yr = sum(CWU_m3yr,na.rm=TRUE), 
			VWS_ir_m3 = sum(VWS_ir_m3,na.rm=TRUE), 
			VWS_rf_m3 = sum(VWS_rf_m3,na.rm=TRUE), 
			VWS_m3 = sum(VWS_m3,na.rm=TRUE), 
			Precipitation_mm = mean(Precipitation_mm,na.rm=TRUE), 
			Precipitation_Volume_km3 = sum(Precipitation_Volume_km3,na.rm=TRUE), 
			Capture_Efficiency = sum(Capture_Efficiency,na.rm=TRUE)), 
			by = State.ANSI  
		]
		#setDT(vws)
		vws$Yield_Bu_per_Ac <- vws$Production_Bu / vws$Harvest_Ac
		vws <- data.frame(vws)
		#write.csv(vws,sprintf('state_plot_aggregates/%s_aggregate_%s_data.csv',year,label),row.names=FALSE)
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

    # Take min/max for all CWU data for consistent plotting (with same scales)
	cwu_ids <- c('CWU_bl_m3yr','CWU_gn_m3yr','CWU_m3yr')
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
		minima <- minima - 1 # subtract 1 to ensure minima is within plot limits
	} else {
		minima <- floor(minima)
	}

	if (maxima == ceiling(maxima)){
		maxima <- maxima + 1 # add 1 to ensure maxima is within plot limits
	} else {
		maxima <- ceiling(maxima)
	}

    # Uppercase first letter in string
    simpleCap <- function(x) {
        s <- strsplit(x, ' ')[[1]]
        paste(toupper(substring(s,1,1)),substring(s,2),sep='',collapse=' ')
    }

    ### Create plot

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

    # Rename commodity name for plots
    if (commodity == 'total') {
        commodity = 'All Commodities'
    } else {
        commodity = simpleCap(tolower(str_replace_all(commodity,',',' - ')))
    }

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(name='',
                    palette='YlGnBu',
				    limits=c( minima, maxima ),
				    direction=1, 
				    na.value='grey90') +
        # Define title label, etc
		#labs(title=sprintf('%s\n%s, %s', str_replace_all(identifier,'_',' '), simpleCap(tolower(commodity)), year),
		##labs(title=sprintf('%s\n%s, 1996-2005', str_replace_all(identifier,'_',' '), simpleCap(tolower(commodity))),
		#    #subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
		labs(x='', # x axis label
		    y='') + # y axis label
		theme(#plot.title=element_text(size=24),
            #plot.subtitle=element_text(size=20),
            legend.title=element_text(size=24),
            legend.text=element_text(size=20),
            panel.grid.major=element_blank(), 
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
commodities <- c('BARLEY','CORN,GRAIN','CORN,SILAGE','OATS','PEAS,DRYEDIBLE','RYE','SORGHUM,GRAIN','SORGHUM,SILAGE','SOYBEANS','SUNFLOWER','WHEAT','SAFFLOWER','CANOLA','MUSTARD,SEED','FLAXSEED','LENTILS','PEAS,AUSTRIANWINTER','RAPESEED','total')

# Select years to iterate over
years <- c('2002','2007','2012')

# List of identifiers and labels
identifiers <- c('Storage_Bu','Harvest_Ac','Percent_Harvest','Production_Bu','CWU_bl_m3yr','CWU_gn_m3yr','CWU_m3yr','VWS_ir_m3','VWS_rf_m3','VWS_m3','Precipitation_mm','Precipitation_Volume_km3','Capture_Efficiency')
labels <- c('storage','harvest','percent_harvest','production','cwu_irrigated','cwu_rainfed','cwu','vws_irrigated','vws_rainfed','vws','precip','precip_volume','capture_efficiency')

# Override to plot only what I want right now
#identifiers <- c('Capture_Efficiency')
#labels <- c('capture_efficiency')
commodities <- c('total')

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
			vws_data <- read.csv( sprintf('final_results/final_state_%s.csv', y) )
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
