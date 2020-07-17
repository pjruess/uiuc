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

# List for sums
sums <- c()

# Select rasters to compare
for (i in 41:51){
    gwd.r <- gwd[,,i] 
    r <- raster(t(gwd.r),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS(proj4string(usa)))
    r.sum <- cellStats(r,stat='sum',na.rm=TRUE)
    sums <- c(sums,r.sum)
}

print(sums,names.arg=sprintf('%s',seq(2000:2010)))
barplot(sums,names.arg=2000:2010,main='Total annual groundwater depletion in USA [million cubic meters]')
dev.off()

