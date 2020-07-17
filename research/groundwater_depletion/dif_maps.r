library(raster) # for reading and processing rasters
library(ncdf4) # for reading and processing NetCDF files
library(glue) # for formatting strings 
library(rgdal) # for spatial analysis (masking with US map)

library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)

# Read in NetCDF with GWD data
nc.path <- '../tradeopenness_groundwater/waterdemand_30min_groundwaterdepletion_yearly_1960-2010.nc'

# Read in USA map for masking
usa <- readOGR('../iiasa_yssp/cb_2016_us_state_500k','cb_2016_us_state_500k')

# Read modeled GWD data from CWatM
nc <- nc_open(nc.path)
print(nc)

# Get lat/lon coords
lon <- ncvar_get(nc,'longitude')
lat <- ncvar_get(nc,'latitude')

# Get time variable
time <- ncvar_get(nc,'time')
tunits <- ncatt_get(nc,'time','units')

# Get GWD variable
gwd <- ncvar_get(nc,'anrg')
dlname <- ncatt_get(nc,'anrg','long_name')
dunits <- ncatt_get(nc,'anrg','units')
fillvalue <- ncatt_get(nc,'anrg','_FillValue')

# Get global attributes
description <- ncatt_get(nc,0,'description')
title <- ncatt_get(nc,0,'title')
sources <- ncatt_get(nc,0,'source')
references <- ncatt_get(nc,0,'references')
history <- ncatt_get(nc,0,'history')
institution <- ncatt_get(nc,0,'institution')
disclaimer <- ncatt_get(nc,0,'disclaimer')

# Fill zeroes
gwd[gwd==fillvalue$value] <- NA

# Select rasters to compare
gwd.y1 <- gwd[,,41] #2000
gwd.y2 <- gwd[,,43] #2002
r.y1 <- raster(t(gwd.y1),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS(proj4string(usa)))
r.y2 <- raster(t(gwd.y2),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS(proj4string(usa)))

# Clip to USA
r.y1 <- mask(r.y1,usa) # select only relevant cells
r.y2 <- mask(r.y2,usa) # select only relevant cells

#extent(r.y1) <- extent(usa)#extent(-180,180,-15,72)
#extent(r.y2) <- extent(usa)#extent(-180,180,-15,72)

# Save raster as new file
#writeRaster(r, filename=r.path, format='ascii', overwrite=TRUE)
#print(paste('File saved at ',r.path,sep=''))

# Subtract rasters
r.dif <- r.y2 - r.y1 #2002-2000
#extent(r.dif) <- extent(-180,180,-15,72)

# Crop extent
#new.ext <- extent(-180,180,-15,72)
#r.dif <- crop(r.dif,new.ext)
#r.dif <- zoom(r.dif,new.ext)

# Get min and max values
minima <- minValue(r.dif)
maxima <- maxValue(r.dif)

max <- max(abs(minima),abs(maxima))
m <- 11
breakSeq <- lapply(seq(-max-1,max+1,by=(max*2/(m-1))),round,0)
#breakSeq <- append(breakSeq,0,after=m/2)

# Function for plotting raster differences
plot(r.dif,xlim=c(-128,-66),ylim=c(22,52),col=brewer.pal(n=m,name='BrBG'),breaks=breakSeq,main='Difference in Groundwater Depletion, 2002-2000 [million cubic meters]')
#library(rasterVis)
#levelplot(r.dif,margin=F)

dev.off()
break
# Plot rasters
#2002-2000
#2012-2010

### Function for plotting change over time 
# df: dataframe
# path: path to save file to
# limit: larger of max and min
# label: plot label
# yr1: first year (for title)
# yr2: second year (for title)
ggPlot <- function(r,path,ext,label,yr1,yr2) {
    # Plot data`
    ggplot() + 
    	geom_raster(data=r, 
                    geom_polygon(aes(fill=plot_fill)) + # sets what to display: VWS_m3_prod/yield, Storage_Bu, ...
    	coord_map(xlim=c(-125, -66),ylim=c(24, 50)) + 
	    scale_fill_distiller(name='',
                    palette='RdBu',
    			    limits=c( -limit-1, limit+1 ),
                    direction = 1,
    			    na.value='grey90') +
    	#labs(title=sprintf('%s Difference\n%s, %s to %s', label, simpleCap(tolower(commoditylab)), yr1, yr2),
	        #subtitle=sprintf('Min: %s, Max: %s', formatC( min(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ), formatC( max(map.df$plot_fill,na.rm=TRUE), format='e', digits=2 ) ),
    	labs(x='',
    	    y='') +
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
    	height = 4)#, dpi = 1200)
    print(sprintf('Plot saved to %s',path))
}

