# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)
library(data.table)

plot_vws <- function(fafzones, flowdata) {

	flowtype <- ''
	colors <- ''

	if (colnames(flowdata)[1] == 'ori'){
		# Define CFS12_NAME
		flowdata$CFS12_NAME <- flowdata$ori
		flowtype <- 'outflows'
		colors <- 'Reds'
	} else if (colnames(flowdata)[1] == 'des'){
		# Define CFS12_NAME
		flowdata$CFS12_NAME <- flowdata$des
		flowtype <- 'inflows'
		colors <- 'Blues'
	} else if (colnames(flowdata)[1] == 'loc'){
		# Define CFS12_NAME
		flowdata$CFS12_NAME <- flowdata$loc
		flowtype <- 'ratio'
		colors <- 'Greens'
	}

	label <- colnames(flowdata)[2]

	# Define path to save to
	path <- sprintf('faf_figures/plot_%s_%s.png', flowtype, label)
	
	# Only create files not currently in directory
	if (file.exists(path)){
		next
	}
	
	# Create temp df
	data <- data.frame(id=rownames(fafzones@data),
			   CFS12_NAME=fafzones@data$CFS12_NAME)

	# Convert from factor to character
	data$id <- as.character(data$id)

	# Merge databases
	data <- merge(data, flowdata, by='CFS12_NAME')
	
	# Fortify data to extract spatial information
	counties.fort <- fortify(fafzones)
	map.df <- join(counties.fort, data, by='id')
	map.df$plot_fill <- map.df[,label]
	map.df$plot_fill[map.df$plot_fill<0] <- NA #convert zeros to NA
	write.csv(map.df,sprintf('faf_figures/data_%s_%s.csv',flowtype,label))

	# Plot data
	prettyLabs <- function(x) format(x,scientific=TRUE,digits=2)#scales::comma(sprintf('%.2f',x))

	ggplot(map.df, aes(x=long,y=lat,group=group)) + 
		geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
		coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
		scale_fill_distiller(palette=colors,
				     #limits=c( min(map.df$plot_fill,na.rm=T), max(map.df$plot_fill,na.rm=T) ),
				     direction=1, 
				     na.value='grey90',
				     labels=prettyLabs) + 
		labs(#title=sprintf('%s for %s',flowtype,label),
		     #subtitle=sprintf('Min: %s, Max: %s',min(map.df$plot_fill,na.rm=T),max(map.df$plot_fill,na.rm=T)),
		     x='',
		     y='') +
		theme(panel.grid.major=element_blank(), 
		      panel.grid.minor=element_blank(), 
		      panel.background=element_blank(), 
		      axis.line=element_blank(), 
		      axis.text=element_blank(), 
		      axis.ticks=element_blank())
	
	# Save plot
	ggsave(path,width=7,height=4,dpi=600)
	print(sprintf('Plot saved to %s',path))
}

# Import fafzones shapefile
fafzones <- readOGR('data/CFS_dissolved_Great_Lakes/','CFSArea_DissoCounty_GreatLakes')

# List of files to plot
files <- list.files('faf_clean/')

for (f in files){

	path <- sprintf('faf_clean/%s',f)

	flowdata <- read.csv( path )
	
	# Plot data
	tryCatch({
       		plot_vws(fafzones, flowdata)
	}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
}
