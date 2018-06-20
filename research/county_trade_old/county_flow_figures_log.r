# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)

plot_vws <- function(counties, flowdata) {

	flowtype <- ''
	colors <- ''

	if (colnames(flowdata)[1] == 'ori'){
		# Define GEOID
		flowdata$GEOID <- sprintf('%05d',flowdata$ori)
		flowtype <- 'outflows'
		colors <- 'Reds'
	} else if (colnames(flowdata)[1] == 'des'){
		# Define GEOID
		flowdata$GEOID <- sprintf('%05d',flowdata$des)
		flowtype <- 'inflows'
		colors <- 'Blues'
	} else if (colnames(flowdata)[1] == 'loc'){
		# Define GEOID
		flowdata$GEOID <- sprintf('%05d',flowdata$loc)
		flowtype <- 'ratio'
		colors <- 'Greens'
	}

	label <- colnames(flowdata)[2]

	# Define path to save to
	path <- sprintf('county_log_figures/plot_%s_%s.png', flowtype, label)
	
	# Only create files not currently in directory
	if (file.exists(path)){
		next
	}
	
	# Create temp df
	data <- data.frame(id=rownames(counties@data),
			   GEOID=counties@data$GEOID,
			   NAME=counties@data$NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)
	
	# Merge databases
	data <- merge(data, flowdata, by='GEOID')
		
	# Fortify data to extract spatial information
	counties.fort <- fortify(counties)
	map.df <- join(counties.fort, data, by='id')
	map.df$plot_fill <- map.df[,label]
	map.df$plot_fill[map.df$plot_fill<=0] <- NA #convert zeros to NA
	write.csv(map.df,sprintf('county_log_figures/data_%s_%s.csv',flowtype,label))

	# Plot data
	prettyLabs <- function(x) format(x,scientific=TRUE,digits=2)#scales::comma(sprintf('%.2f',x))

	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(palette=colors,
				     #limits=c( (min(map.df$plot_fill,na.rm=T)), (max(map.df$plot_fill,na.rm=T)) ),
				     direction=1, 
				     na.value='grey90',
				     labels=prettyLabs,
				     trans='log') +
		labs(#title=sprintf('%s for %s',flowtype,label),
		     #subtitle=sprintf('Min: %s, Max: %s',min(map.df$plot_fill,na.rm=T),max(map.df$plot_fill,na.rm=T)),
		     x='',
		     y='') +
		theme(panel.grid.major=element_blank(), 
		      panel.grid.minor=element_blank(), 
		      panel.background=element_blank(), 
		      plot.margin=grid::unit(c(0,0,0,0),'mm'),
		      legend.title=element_blank(),
		      axis.line=element_blank(), 
		      axis.text=element_blank(), 
		      axis.ticks=element_blank())
	
	# Save plot
	ggsave(path,width=4,height=2,dpi=600)
	print(sprintf('Plot saved to %s',path))
}

# Import counties shapefile
counties <- readOGR('../grain_storage/cb_2016_us_county_500k/','cb_2016_us_county_500k')

# List of files to plot
files <- list.files('county_clean/')

for (f in files){

	path <- sprintf('county_clean/%s',f)

	flowdata <- read.csv( path )
	
	# Sum common GEOIDs together (example: if one GEOID exports to multiple destinations, sum all outflows)
	#ddply(flowdata,'GEOID',numcolwise(sum))
	
	# Plot data
	tryCatch({
       		plot_vws(counties, flowdata)
	}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
}
