library(raster)
library(rgdal)

# Mask
mhmt <- readOGR('mahomet','mahomet')

#cdl <- raster(file.path('CDL_2019_clip/CDL_2019_clip.tif',RAT=T))
cdl <- raster('CDL_2019_clip/CDL_2019_clip.tif',RAT=T)

mhmt <- spTransform(mhmt,crs('+proj=longlat +datum=WGS84'))
print(crs(mhmt))
cdl <- projectRaster(cdl,crs=crs('+proj=longlat +datum=WGS84'))
print(crs(cdl))

# Mask CDL by Mahomet aquifer counties
cdl.mask <- mask(cdl,mhmt)

plot(cdl)
plot(cdl.mask)


