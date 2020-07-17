library(ncdf4)
library(raster)
library(glue)

nc.path <- 'waterdemand_30min_groundwaterdepletion_month_1960-2010.nc' # standard model

# Read modeled GWD data from CWatM
nc <- nc_open(nc.path)

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

# Reformat netCDF FillValue with NA
gwd[gwd==fillvalue$value] <- NA

# Iterate through netCDF slices and save as raster with year/month in title
for (i in seq_along(years)) {
    
    y <- years[i]

    # Create filename
    r.path <- glue('rawdata/gwd/{y}.tif')

    # Select raster slice from netCDF
    gwd.slice <- gwd[,,i]
    r <- raster(t(gwd.slice),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))

    # Save raster as new file
    writeRaster(r, filename=r.path, format='GTiff', overwrite=TRUE)
    print(paste('File saved at ',r.path,sep=''))

    # Visualize
    #plot(r)
}

nc_close(nc)
