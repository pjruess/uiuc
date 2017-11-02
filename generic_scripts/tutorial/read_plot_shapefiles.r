# For vector work; sp package loads with rgdal packages
library(rgdal)

# For metadata/attributes in vector or raster format
library(raster)

# Set working directory
# getwd()
# setwd('NEON-DS-Site-Layout-Files/')

# Import polygon shapefile: readOCR('path','filename')
# No extension necessary (this function ONLY imports shapefiles)
aoiBoundary_HARV <- readOGR('NEON-DS-Site-Layout-Files/HARV','HarClip_UTMZ18')

# view class of shapefile
# class(aoiBoundary_HARV)

# view crs for shapefile
# extent(aoiBoundary_HARV)

# view all metadata for shapefile
# aoiBoundary_HARV

# view shapefile data
# aoiBoundary_HARV@data

# view summary of metadata and attributes
# summary(aoiBoundary_HARV)

# create plot of shapefile
# 'lwd' is line width
# 'col' is internal color
# 'border' is border color
# plot(aoiBoundary_HARV,col='cyan1',border='black',lwd=3,main='AOI Boundary Plot')

# import roads and tower
lines_HARV <- readOGR('NEON-DS-Site-Layout-Files/HARV','HARV_roads')
point_HARV <- readOGR('NEON-DS-Site-Layout-Files/HARV','HARVtower_UTM18N')

# plot points and lines
# plot(aoiBoundary_HARV,col='lightgreen',main='NEON Harvard Forest\nField Site')
# plot(lines_HARV,add=TRUE) # add=TRUE plots vector data layered on top of raster data
# plot(point_HARV,add=TRUE,pch=19,col='purple') # pch adjusts symbology

# import height model
chm_HARV <- raster('NEON-DS-Site-Layout-Files/HARV/CHM/','HARV_chmCrop.tif')

print('--------------------------')

# Plot height and data
plot(chm_HARV,main='Map of Study Area\n w/ Canopy Height Model\nNEON Harvard Forest Field Site')
plot(lines_HARV,add=TRUE,col='black') # add=TRUE plots vector data layered on top of raster data
plot(aoiBoundary_HARV,border='grey20',add=TRUE,lwd=4)
plot(point_HARV,add=TRUE,pch=8) # pch adjusts symbology