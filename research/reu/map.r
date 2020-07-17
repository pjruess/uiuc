library(rgdal) # read and manage shapefiles
library(ggplot2) # plotting/mapping
library(plyr) # 'join' function
#library(sp)
#library(RColorBrewer)

#print(memory.limit(200000)) # resolves 'cannot allocate vector of size xxx' error

# Read in USA map for masking
states <- readOGR('cb_2018_us_state_500k','cb_2018_us_state_500k')

# Read data
df <- read.csv('corn_simplified_state.csv')
df <- df[(df$Year == 2018) & (df$Data.Item == 'ACRES HARVESTED') & (df$Commodity == 'CORN, GRAIN'),]

### Add spatial data for mapping
# Create temp df
data <- data.frame(id=rownames(states@data),
			State.ANSI=states@data$STATEFP) # GEOID for counties

# Convert from factor to character
data$id <- as.character(data$id)

# Merge databases
merged <- merge(data, df, by='State.ANSI')

# Fortify data to extract spatial information
fort <- fortify(states)
map.df <- join(fort, merged, by='id')
#write.csv(map.df,'map.csv',row.names=F)

### Function for plotting change over time 
# d: dataframe
# path: path to save file to
# label: plot label
ggPlot <- function(d,path,label) {

    # Plot data
	ggplot(d, aes(x=long,y=lat,group=group)) + 
        geom_polygon(aes(fill=d$Value)) + # sets variable to display
    	coord_map(xlim=c(-128, -66),ylim=c(22, 52)) + 
	    scale_fill_distiller(name='',
                    palette='YlGnBu', # this is the color palette; lots online (search R colors)
    			    #limits=c( -1800, 1800 ), # manually define upper and lower plotting limits
                    direction = 1,
    			    na.value='grey90') +
    	labs(title=label, # plot title
            x='', # x-axis
            y='') + # y-axis
        # below are a bunch of size settings; change to make more legible
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
    	width = 7, # if leave width and height blank, defaults to a square
    	height = 4) # can also adjust dpi: dpi = 1200)
    print(sprintf('Plot saved to %s',path))
}

ggPlot(map.df,'corn_area_state_2018.png','Corn, Harvested Area, States, 2018')
