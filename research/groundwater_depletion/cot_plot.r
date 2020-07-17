library(raster) # for reading and processing rasters
library(ncdf4) # for reading and processing NetCDF files
library(glue) # for formatting strings 
library(rgdal) # for spatial analysis (masking with US map)

library(ggplot2)
library(plyr)
library(sp)
library(RColorBrewer)

# Read in USA map for masking
usa <- readOGR('irra_states/cb_2016_us_state_500k','cb_2016_us_state_500k')

### GWW from USGS ###

gww2000 <- read.csv('usco2000.csv')
gww2005 <- read.csv('usco2005.csv')
gww2010 <- read.csv('usco2010.csv')

gww2000.sum <- sum(gww2000$TO.WGWTo,na.rm=T) * 366 * 0.00378541 # day/year * m3/gal = Mm3/yr
gww2005.sum <- sum(gww2005$TO.WGWTo,na.rm=T) * 365 * 0.00378541 # day/year * m3/gal = Mm3/yr
gww2010.sum <- sum(gww2010$TO.WGWTo,na.rm=T) * 365 * 0.00378541 # day/year * m3/gal = Mm3/yr

gww <- c(gww2000.sum,gww2005.sum,gww2010.sum)

### GWD from USGS ###

usgs.gwd.2000 <- read.csv('sir2013-5079_Groundwater_Depletion_Study_Files/spreadsheets/depletion_vol(1900-2000).csv')
usgs.gwd.2008 <- read.csv('sir2013-5079_Groundwater_Depletion_Study_Files/spreadsheets/depletion_vol(1900-2008).csv')

usgs.gwd.2000.sum <- sum(usgs.gwd.2000$GW.Depl.Vol..km.3..1900.2000,na.rm=T) * 1e3 # 1e9 m3/km3 * 1e-6 = Mm3
usgs.gwd.2008.sum <- sum(usgs.gwd.2008$GW.Depl.Vol..km.3..1900.2008,na.rm=T) * 1e3 # 1e9 m3/km3 * 1e-6 = Mm3

usgs.gwd.dif <- usgs.gwd.2008.sum - usgs.gwd.2000.sum

usgs.gwd <- rep(usgs.gwd.dif / length(2000:2008), length(2000:2008))

### GWD from PCR ###

# Read in NetCDF with GWD data
gwd.path <- '../tradeopenness_groundwater/waterdemand_30min_groundwaterdepletion_yearly_1960-2010.nc'

# Read modeled GWD data from PCR
gwd.data <- nc_open(gwd.path)
print(gwd.data)

# Get lat/lon coords
gwd.lon <- ncvar_get(gwd.data,'longitude')
gwd.lat <- ncvar_get(gwd.data,'latitude')

# Get GWD variable
gwd <- ncvar_get(gwd.data,'anrg')
gwd.fill <- ncatt_get(gwd.data,'anrg','_FillValue')

# Fill zeroes
gwd[gwd==gwd.fill$value] <- NA

# List for sums
gwd.sums <- c()

# Select rasters to compare
for (i in 41:51){
    gwd.r <- gwd[,,i] 
    r <- raster(t(gwd.r),xmn=min(gwd.lon),xmx=max(gwd.lon),ymn=min(gwd.lat),ymx=max(gwd.lat),crs=CRS(proj4string(usa)))
    r <- mask(r,usa) # select only relevant cells
    writeRaster(r,glue('cotplot_rasters/gwd.{i}.tif'),format='GTiff',overwrite=TRUE)
    r.sum <- cellStats(r,stat='sum',na.rm=TRUE)
    gwd.sums <- c(gwd.sums,r.sum)
}

### GWA from PCR ###

# Read in NetCDF with GWA data
gwa.path <- 'waterdemand_30min_groundwaterabstraction_annual.nc'

# Read modeled GWA data from PCR
gwa.data <- nc_open(gwa.path)
print(gwa.data)

# Get lat/lon coords
gwa.lon <- ncvar_get(gwa.data,'longitude')
gwa.lat <- ncvar_get(gwa.data,'latitude')

# Get GWA variable
gwa <- ncvar_get(gwa.data,'gwab')
gwa.fill <- ncatt_get(gwa.data,'gwab','_FillValue')

# Fill zeroes
gwa[gwa==gwa.fill$value] <- NA

# List for sums
gwa.sums <- c()

# Select rasters to compare
for (i in 41:51){
    gwa.r <- gwa[,,i] 
    r <- raster(t(gwa.r),xmn=min(gwa.lon),xmx=max(gwa.lon),ymn=min(gwa.lat),ymx=max(gwa.lat),crs=CRS(proj4string(usa)))
    r <- mask(r,usa) # select only relevant cells
    writeRaster(r,glue('cotplot_rasters/gwa.{i}.tif'),format='GTiff',overwrite=TRUE)
    r.sum <- cellStats(r,stat='sum',na.rm=TRUE)
    gwa.sums <- c(gwa.sums,r.sum)
}

### Plot results ###

pdf('cotplot.pdf')

minlim = min(gww,usgs.gwd,gwa.sums,gwd.sums)
maxlim = max(gww,usgs.gwd,gwa.sums,gwd.sums)

plot(c(2000,2005,2010),gww,type='l',main='Groundwater Trends',xlab='Year',ylab='Groundwater',col='darkgoldenrod',lty=1,lwd=1.5,ylim=c(minlim,maxlim))

lines(2000:2008,usgs.gwd,col='darkcyan',lty=2,lwd=1.5)

lines(2000:2010,gwa.sums,col='chartreuse4',lty=3,lwd=1.5)

lines(2000:2010,gwd.sums,col='hotpink4',lty=4,lwd=1.5)

legend('left',legend=c('USGS Withdrawals','USGS Depletion (Konikow, 2013)','PCR-GLOBWB Abstractions','PCR-GLOBWB Depletion'),col=c('darkgoldenrod','darkcyan','chartreuse4','hotpink4'),lty=1:4,lwd=1.5,title='Source')

dev.off()

### Plot results without PCR-GLOBWB Groundwater Depletion ###

pdf('cotplot_nogwd.pdf')

minlim = min(gww,usgs.gwd,gwd.sums)
maxlim = max(gww,usgs.gwd,gwd.sums)

plot(c(2000,2005,2010),gww,type='l',main='Groundwater Trends',xlab='Year',ylab='Groundwater',col='darkgoldenrod',lty=1,lwd=1.5,ylim=c(minlim,maxlim))

lines(2000:2008,usgs.gwd,col='darkcyan',lty=2,lwd=1.5)

lines(2000:2010,gwa.sums,col='chartreuse4',lty=3,lwd=1.5)

legend('left',legend=c('USGS Withdrawals','USGS Depletion (Konikow, 2013)','PCR-GLOBWB Abstractions'),col=c('darkgoldenrod','darkcyan','chartreuse4'),lty=1:3,lwd=1.5,title='Source')

dev.off()

#barplot(gwa.sums,names.arg=2000:2010,main='Total annual groundwater depletion in USA [million cubic meters]')

