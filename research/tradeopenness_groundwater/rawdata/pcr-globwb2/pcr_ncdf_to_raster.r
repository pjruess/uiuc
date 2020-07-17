library(ncdf4)
library(raster)
library(glue)

data <- list(c('gwd_year.nc','groundwater_depletion'),c('gwa_year.nc','total_groundwater_abstraction'))

for (d in data) {

    # Read PCR data
    nc <- nc_open(d[1])
    
    # Get lat/lon coords
    lon <- ncvar_get(nc,'lon')
    lat <- ncvar_get(nc,'lat')
    
    ## Get time variable
    #time <- ncvar_get(nc,'time')
    #tunits <- ncatt_get(nc,'time','units')
    
    # Get GWD variable
    var <- ncvar_get(nc,d[2])
    #dlname <- ncatt_get(nc,d[2],'long_name')
    #dunits <- ncatt_get(nc,'anrg','units')
    fillvalue <- ncatt_get(nc,d[2],'_FillValue')
    
    ## Get global attributes
    #description <- ncatt_get(nc,0,'description')
    #title <- ncatt_get(nc,0,'title')
    #sources <- ncatt_get(nc,0,'source')
    #references <- ncatt_get(nc,0,'references')
    #history <- ncatt_get(nc,0,'history')
    #institution <- ncatt_get(nc,0,'institution')
    #disclaimer <- ncatt_get(nc,0,'disclaimer')
    
    # Reformat netCDF FillValue with NA
    var[var==fillvalue$value] <- NA
    
    # Iterate through netCDF slices and save as raster with year/month in title
    years <- 1958:2015
    for (i in seq_along(years)) {
        
        y <- years[i]

        # Create filename
        folder <- strsplit(d[1],'_')[[1]][1]
        r.path <- glue('{folder}/rasters/{y}.tif')
    
        # Select raster slice from netCDF
        slice <- var[,,i]
        r <- raster(t(slice),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
    
        # Save raster as new file
        writeRaster(r, filename=r.path, format='GTiff', overwrite=TRUE)
        print(paste('File saved at ',r.path,sep=''))
    }
    nc_close(nc)
}
