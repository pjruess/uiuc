library(raster)
library(rgdal)

usa <- readOGR('cb_2016_us_county_500k','cb_2016_us_county_500k')

# Read raw rasters
r1 <- raster('irra2000_2010/irra2000.tif')
r2 <- raster('irra2000_2010/irra2010.tif')

# Mask extent to USA
r1.m <- mask(r1,usa)
writeRaster(r1.m,'irra2000_2010/irra2000_usa.tif',format='GTiff',overwrite=T)
r2.m <- mask(r2,usa)
writeRaster(r2.m,'irra2000_2010/irra2010_usa.tif',format='GTiff',overwrite=T)

# Read masked USA rasters

