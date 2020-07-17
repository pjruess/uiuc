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
map <- function(geo, df, c, y, i, p, minima, maxima) {
	
    # Define label
    ilab <- tolower(gsub('\\.','_',i))

    # Define label
    plab <- tolower(gsub(', ','-',gsub('\\.','_',p)))

	# Define path to save to
	path <- sprintf('../maps/census_survey_compare/%s_%s_%s_%s.png', plab, y, c, ilab)
    print(path)
	
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
				    limits=c( minima-1, maxima+1 ),
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
}

# Import polygon shapefile
geo <- readOGR('../../always_data/cb_2018_us_county_500k','cb_2018_us_county_500k')

# Read in data
df <- read.csv('../data/compare_census_survey/output/combined_census_survey_soybeans.csv')

# Edit formatting of Crop column: (ie. 'Corn, Grain' --> 'Corn.Grain')
df$Crop <- tolower(gsub(', ','_',df$Crop))

# Fix formatting of GEOID column
df$GEOID <- sprintf('%05d',df$GEOID)

# Convert data columns to factors
df[,c(5:7)] <- lapply(df[,c(5:7)], function(x) as.numeric(as.character(x)))

# If minmax data doesn't exist, create; otherwise read
mm.path <- '../maps/census_survey_compare/minmax.csv'

if (!file.exists(mm.path)) {

    # Create minmax dataframe
    mm <- data.frame()
    
    # Collect minmax values
    for (y in unique(df$Year)) {
        
    	for (i in colnames(df)[5:7]) {
    
            for (p in unique(as.character(df$Program))){
    
                # Select specific year, program, and id
                df.i <- df[df$Year == y & df$Program == p,][,c('GEOID','Crop',i)]
    
                for (c in unique(as.character(df$Crop))){#append( unique(as.character(df$Crop)), 'all_crops' )){
    
                    # Print update
    			    print( sprintf('Collecting minmax for id %s for crop %s, program %s, year %s', i, c, p, y) )
    
    	            # If crop is 'all_crops', aggregate sum of id by GEOID 
    	            if (c == 'all_crops') {
    
                        # Skip yield of all crops because summing doesn't make sense
                        if (i == 'Yield.BuAc') next
    
                        # Select specific columns for aggregation
                        df.c <- df.i[,c('GEOID',i)]
    
                        # Aggregate sum of Id by GEOID
                        df.c <- aggregate(.~GEOID, data=df.c, FUN=sum, na.rm=T, na.action=na.omit)
    
                    } else {
    
                        # Subset with specific crop
                        df.c <- subset(df.i, Crop == c)
    
                        # Keep only necessary columns
                        df.c <- df.c[,c('GEOID',i)]
                    }

                    # Retrieve minmax and append to csv
    	            mm.temp <- data.frame(y,c,i,p,min(df.c[,i],na.rm=T),max(df.c[,i],na.rm=T))
                    colnames(mm.temp) <- c('Year','Crop','Item','Program','Min','Max')
                    mm <- rbind(mm,mm.temp)

                } # crop
    		} # program
    	} # item
    } # year
    
    write.csv(mm,mm.path,row.names=F)

} else {
    mm <- read.csv(mm.path)
}

# Create plots for all crop-year-identifier pairs
for (y in c(1997,2002,2007,2012,2017)){#unique(df$Year)) {
    
	for (i in colnames(df)[5:7]) {

        for (p in unique(as.character(df$Program))){

            # Select specific year, program, and id
            df.i <- df[df$Year == y & df$Program == p,][,c('GEOID','Crop',i)]

            for (c in unique(as.character(df$Crop))){#append( unique(as.character(df$Crop)), 'all_crops' )){
    
                # Print update
			    print( sprintf('Plotting id %s for crop %s, program %s, year %s', i, c, p, y) )

	            # If crop is 'all_crops', aggregate sum of id by GEOID 
	            if (c == 'all_crops') {

                    # Skip yield of all crops because summing doesn't make sense
                    if (i == 'Yield.BuAc') next

                    # Select specific columns for aggregation
                    df.c <- df.i[,c('GEOID',i)]

                    # Aggregate sum of Id by GEOID
                    df.c <- aggregate(.~GEOID, data=df.c, FUN=sum, na.rm=T, na.action=na.omit)

                } else {

                    # Subset with specific crop
                    df.c <- subset(df.i, Crop == c)

                    # Keep only necessary columns
                    df.c <- df.c[,c('GEOID',i)]
                }

                # Select specific year, program, and id
                if ( y %in% c(1997,2002,2007,2012,2017) ) {
                    minmax <- mm[mm$Year == y & mm$Crop == c & mm$Item == i,]
                } else {
                    minmax <- mm[mm$Year == y & mm$Crop == c & mm$Item == i & mm$Program %in% c('SURVEY, FILL','SURVEY, RAW'),]
                }

                # Define minima and maxima
                minima <- min(minmax$Min,na.rm=T)
                maxima <- min(minmax$Max,na.rm=T)

			    # Plot data
			    tryCatch({
			        map(geo, df.c, c, y, i, p, minima, maxima)
			    }, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
            } # crop
		} # program
	} # item
} # year
