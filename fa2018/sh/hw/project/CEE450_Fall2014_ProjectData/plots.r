# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
#library(data.table)
#library(stringr) # for str_replace_all

plot <- function(catchments, bg, catch_data, label) {
	
	# Define path to save to
	path <- sprintf('plots/%s.png', tolower(label))
	
	# Create temp catch_data
	data <- data.frame(id=rownames(catchments@data),
			   SiteID=catchments@data$SiteID,
			   NAME=catchments@data$SiteName)

	# Convert from factor to character
	data$id <- as.character(data$id)
	
	# Merge databases
	data <- merge(data, catch_data, by='SiteID')

    # Match spatial projections to WSG84
    bg.trans <- spTransform(bg,proj4string(catchments))

	# Fortify data to extract spatial information
	catchments.fort <- fortify(catchments)
	bg.fort <- fortify(bg.trans)
	map.df <- join(catchments.fort, data, by='id')
	map.df$plot_fill <- map.df[,label]
	map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA
    
    # Remove catchments with NA for current label to avoid plotting
    map.df <- map.df[complete.cases(map.df[,label]),]

    print(proj4string(catchments))
    print(proj4string(bg.trans))

	# Plot data
	ggplot() + 
        geom_polygon(data=bg.fort, aes(x=long,y=lat,group=group),colour='black',fill=NA,size=0.2) +#,color='black')) + 
        geom_polygon(data=map.df, aes(x=long,y=lat,group=group,fill=plot_fill),colour='black',size=0.2) + 
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(name='',
                    palette='YlGnBu',
				    #limits=c( minima, maxima ),
				    direction=1, 
				    na.value=NA) + #grey90
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
catchments <- readOGR('GIS_Layers/MOPEX431_basins','MOPEX431_basins')

# Background
bg <- readOGR('GIS_Layers/USA_states','ContinentalUSA')

# Read in data
catch_data <- read.csv('catchment_data_2.csv')
#catch_data$SiteID <- sprintf('%08d',catch_data$)SiteID
#print(catch_data)

# Select labels
labels <- c('MeanAnnualP','MeanAnnualEp','MeanAnnualQ','MeanAnnualQs','MeanAnnualQu','MeanAnnualE','AridityIndex','EvaporationCoefficient','RunoffCoefficient','BaseflowIndex')#'SeasonalityIndex'

# Create plots for all commodity-year-identifier pairs
for (l in labels) {
    # Plot data
    print( sprintf('Plotting %s', l) )
    tryCatch({
	   	plot(catchments, bg, catch_data, l)
	}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
}
