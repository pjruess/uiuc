# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)
library(stringr) # for str_replace_all

# Helper function for plot labels: uppercase first letter in string
simpleCap <- function(x) {
    s <- strsplit(x, ' ')[[1]]
    paste(toupper(substring(s,1,1)),substring(s,2),sep='',collapse=' ')
}

# Plotting function
plot_vws <- function(states, vws, commodity, year, identifier, label, mmdata) {

    ### RETRIEVE AND CLEAN DATA BEFORE PLOTTING

	# Define path to save to
	path <- sprintf('state_plots/%s_%s_%s.png', year, tolower(commodity), label)
	
	if (file.exists(path)) next # If plot already exists, skip to next plot
	
	# If not 'total', skip storage
	if (identifier == 'Storage_Bu' && commodity != 'total') next

	# If commodity is 'total', aggregate sum by State ANSI (can also take 'mean' and other functions)
	if (commodity == 'total') {
		vws <- setDT(vws)[, 
			.(Harvest_Ac = sum(Harvest_Ac,na.rm=TRUE), 
			Production_Bu = sum(Production_Bu,na.rm=TRUE)), 
			by = State.ANSI
		]
		vws$Yield_Bu_per_Ac <- vws$Production_Bu / vws$Harvest_Ac # recalculate after aggregation
		vws <- data.frame(vws)
        # Write aggregated data to check
		#write.csv(vws,sprintf('%s_aggregate_%s_data.csv',year,label),row.names=FALSE)

    # If specific commodity (not 'total'), select that commodity instead of aggregating
	} else {
		vws <- vws[ which( vws$Commodity == commodity ), ] 
	}

    # Calculate minmax for specified commodity and year, then zip together with other minmax values
	if (!file.exists(minmax.path)){
        print(sprintf('Creating minmax database for commodity %s, year %s',commodity, year))
		vws[,identifier][vws[,identifier]<=0] <- NA #convert zeros to NA
		minima <- min(vws[,identifier],na.rm=T)
		maxima <- max(vws[,identifier],na.rm=T)
		tempdf <- data.frame(commodity, identifier, year, minima, maxima)
		names(tempdf) <- c('Commodity','Identifier','Year','Minima','Maxima')
		mmdata <- rbind(mmdata, tempdf)
		return(mmdata) # return value for try/catch in initial function call
        next # exit function call to save minmax value with other minmax values
	}

    # Select only data for current commodity
    mmdata.sub <- mmdata[mmdata$Commodity == commodity & mmdata$Identifier == identifier, ]

	# Determine minima and maxima for plotting limits
	minima <- min(mmdata.sub$Minima,na.rm=T)
	maxima <- max(mmdata.sub$Maxima,na.rm=T)

    # If min/max are min/max of all commodities, redefine for extreme values to be visible
	if (minima == floor(minima)){
		minima <- minima - 1 # if global minima, subtract 1 to plot limits so values actually show up
	} else {
		minima <- floor(minima)
	}

	if (maxima == ceiling(maxima)){
		maxima <- maxima + 1 # if global maxima, add 1 to plot limits so values actually show up
	} else {
		maxima <- ceiling(maxima)
	}

    # CREATE PLOT
    print( sprintf('Plotting %s for commodity %s, year %s', identifier, commodity, year) )

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
        # Plot labels
		labs(title=sprintf('%s\n%s, %s', str_replace_all(identifier,'_',' '), simpleCap(tolower(commodity)), year),
		subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
		x='', # x-axis label
		    y='') + # y-axis label
		theme(plot.title=element_text(size=24),
            plot.subtitle=element_text(size=20),
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
# 'total' is aggregate of all grains in database
commodities <- c('WHEAT','total')

# Select years to iterate over
years <- c('2012')

# List of identifiers and labels
identifiers <- c('Harvest_Ac','Production_Bu','Yield_Bu_per_Ac') # variables to plot
labels <- c('harvest','production','yield') # labels for output filenames

# Zip data together to simplify for loops later
df <- data.frame(identifiers, labels)

# Retrieve minima and maxima data
minmax.path <- 'minmax_database.csv'

if (file.exists(minmax.path)){
	minmax.data <- read.csv(minmax.path)
} else {
    # Create empty minmax database to be generated within function
	minmax.data <- data.frame(matrix(ncol=5,nrow=0))
	minmax.names <- c('Commodity','Identifier','Year','Minima','Maxima')
	colnames(minmax.data) <- minmax.names
}

# Create plots for all commodity-year-identifier pairs
for (c in commodities) {
	for (i in 1:nrow(df)) {
		for (y in years){

            # Retrieve ID and label
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])

			# Read in VWS data
			vws_data <- read.csv( sprintf('final_state_%s.csv', y) )
			vws_data$State.ANSI <- sprintf('%02d',vws_data$State.ANSI)

			# Plot data
            # Use try-catch to check if minmax data exists. If not, exit loop and create it (below)
			tryCatch({
			       	minmax.data <- plot_vws(states_data, vws_data, c, y, id, label, minmax.data)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})

		}
	}
}

# Compile minmax for all commodities and years and save in one file
# After minmax data exists, run script again and it will work properly
if (!file.exists(minmax.path)){
    print('Compiling minmax data. Run script again to create plots.')
	minmax.data <- data.table(minmax.data)
	minmax.data[ , list(Minima = min(Minima), Maxima = max(Maxima)), by=c('Commodity','Identifier') ]
	write.csv(minmax.data,minmax.path,row.names=FALSE)
}
