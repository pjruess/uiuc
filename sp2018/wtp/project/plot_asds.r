# For vector work; sp package loads with rgdal packages
library(rgdal)

# For plotting
library(ggplot2)
library(RColorBrewer)

list.files('asds/')

# Import fafzones shapefile
shapefile <- readOGR('asds/','ASD_2012_5m.shp')

# Define path to save to
path <- sprintf('faf_figures/plot_%s_%s.png', flowtype, label)

# Fortify data to extract spatial information
shapefile.df <- fortify(shapefile)

map <- ggplot() +
geom_path(data = shapefile.df, 
          aes(x = long, y = lat, group = group),
          color = 'gray', fill = 'white', size = .2)

print(map)

# Using the ggplot2 function coord_map will make things look better and it will also let you change
# the projection. But sometimes with large shapefiles it makes everything blow up.
map_projected <- map +
  coord_map()
  
print(map_projected)

# map.df <- join(asds.fort, data, by='id')
# map.df$plot_fill <- map.df[,label]
# map.df$plot_fill[map.df$plot_fill<0] <- NA #convert zeros to NA
# write.csv(map.df,sprintf('faf_figures/data_%s_%s.csv',flowtype,label))

# # Plot data
# prettyLabs <- function(x) format(x,scientific=TRUE,digits=2)#scales::comma(sprintf('%.2f',x))

# ggplot(map.df, aes(x=long,y=lat,group=group)) + 
# 	geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
# 	coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
# 	scale_fill_distiller(palette=colors,
# 			     #limits=c( min(map.df$plot_fill,na.rm=T), max(map.df$plot_fill,na.rm=T) ),
# 			     direction=1, 
# 			     na.value='grey90',
# 			     labels=prettyLabs) + 
# 	labs(#title=sprintf('%s for %s',flowtype,label),
# 	     #subtitle=sprintf('Min: %s, Max: %s',min(map.df$plot_fill,na.rm=T),max(map.df$plot_fill,na.rm=T)),
# 	     x='',
# 	     y='') +
# 	theme(panel.grid.major=element_blank(), 
# 	      panel.grid.minor=element_blank(), 
# 	      panel.background=element_blank(), 
# 	      axis.line=element_blank(), 
# 	      axis.text=element_blank(), 
# 	      axis.ticks=element_blank())

# Save plot
ggsave(path,width=7,height=4,dpi=600)
print(sprintf('Plot saved to %s',path))