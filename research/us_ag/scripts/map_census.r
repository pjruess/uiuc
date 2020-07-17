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
map <- function(geo, df, c, y, i, mm) {
	
    # Define label
    l <- tolower(gsub('\\.','_',i))

	# Define path to save to
	path <- sprintf('../maps/census_conus/%s_%s_%s.png', y, c, l)
    print(path)
	
    # Select specific year
    df <- subset(df, Year == y)[,c('GEOID','Crop',i)]

	# If crop is 'all_crops', aggregate sum of id by GEOID 
	if (c == 'all_crops') {

        # Skip yield of all crops because summing doesn't make sense
        if (i == 'Yield.BuAc') next

        # Select specific columns for aggregation
        df <- df[,c('GEOID',i)]

        # Aggregate sum of Id by GEOID
        df <- aggregate(.~GEOID, data=df, FUN=sum, na.rm=T, na.action=na.omit)

    } else {

        # Subset with specific crop
        df <- subset(df, Crop == c)

        # Keep only necessary columns
        df <- df[,c('GEOID',i)]
    }

	# Save min and max for manual assignment across years
	if (!file.exists(minmax.path)){
		#df[,i] [ df[,i] <= 0 ] <- NA #convert zeros to NA
		minima <- min(df[,i],na.rm=T)
		maxima <- max(df[,i],na.rm=T)
		tempdf <- data.frame(c, i, y, minima, maxima)
		names(tempdf) <- c('Crop','Id','Year','Minima','Maxima')
		mm <- rbind(mm, tempdf)
		return(mm)
		next
	}

	if (file.exists(path)){
		next
	}

	# Determine minima and maxima for plotting limits
    mm.sub <- subset(mm, Crop == c & Id == i & Year == y) 
    print(head(mm.sub))

	minima <- min(mm.sub$Minima,na.rm=T)
	maxima <- max(mm.sub$Maxima,na.rm=T)

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
	data <- data.frame(id=rownames(geo@data),
			   GEOID=geo@data$GEOID,
			   NAME=geo@data$NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)
	
	# Merge databases
	data <- merge(data, df, by='GEOID')

	# Fortify data to extract spatial information
	counties.fort <- fortify(geo)
	map.df <- join(counties.fort, data, by='id')
	map.df$plot_fill <- map.df[,i]
	#map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA

	# Plot data
	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display based on previous plot_fill definition
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + # without AK 
		#coord_map(xlim=c(-180, -66),ylim=c(24, 72)) + # with AK
		scale_fill_distiller(name='',
                    palette='YlGnBu',
				    limits=c( minima, maxima ),
				    direction=1, 
				    na.value='grey90') +
		#labs(title=sprintf('%s\n%s, %s', str_replace_all(i,'_',' '), simpleCap(c), year),
		##labs(title=sprintf('%s\n%s, 1996-2005', str_replace_all(i,'_',' '), simpleCap(c),
		#    #subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
		labs(x='',
		    y='') +
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
	return(mm)
}

# Import polygon shapefile
geo <- readOGR('../../always_data/cb_2018_us_county_500k','cb_2018_us_county_500k')

# Retrieve minima and maxima data
minmax.path <- '../maps/census_conus/minmax_census.csv'

if (file.exists(minmax.path)){
	minmax <- read.csv(minmax.path)
} else {
	minmax <- data.frame(matrix(ncol=5,nrow=0))
	minmax.names <- c('Commodity','Identifier','Year','Minima','Maxima')
	colnames(minmax) <- minmax.names
}

# Read in data
df <- read.csv('../data/clean/allcrops_county_census_clean.csv')

# Edit formatting of Crop column: (ie. 'Corn, Grain' --> 'Corn.Grain')
df$Crop <- tolower(gsub(', ','_',df$Crop))

# Fix formatting of GEOID column
df$GEOID <- sprintf('%05d',df$GEOID)

# Convert data columns to factors
df[,c(4:6)] <- lapply(df[,c(4:6)], function(x) as.numeric(as.character(x)))

# Create plots for all crop-year-identifier pairs
for (y in unique(df$Year)) {
    
	for (i in colnames(df)[4:6]) {

        for (c in append( unique(as.character(df$Crop)), 'all_crops' )){

            # Print update
			print( sprintf('Plotting id %s for crop %s, year %s', i, c, y) )

			# Plot data
			tryCatch({
			       	minmax <- map(geo, df, c, y, i, minmax)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})

		} # commodities
	} # identifiers & labels
} # years

if (!file.exists(minmax.path)){
	minmax <- data.table(minmax)
	minmax[ , list(Minima = min(Minima), Maxima = max(Maxima)), by=c('Crop','Id') ]
	write.csv(minmax,minmax.path,row.names=FALSE)
}
