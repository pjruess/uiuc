library(ncdf4) # for reading and processing NetCDF files
library(glue) # for formatting strings 
library(rgdal) # for spatial analysis (masking with US map)
library(raster) # for reading and processing rasters

# Read in USA map
usa <- readOGR('../cb_2016_us_county_500k','cb_2016_us_county_500k')

# Read in NetCDF with GWD data
nc.p.1 <- 'irra2000_usa_final.nc'

# Read modeled GWD data from CWatM
nc.1 <- nc_open(nc.p.1)
print(nc.1)

# Get lat/lon coords
lon <- ncvar_get(nc.1,'lon')
lat <- ncvar_get(nc.1,'lat')

# Get GWA variable
i.1 <- ncvar_get(nc.1,'irra2000')
fillvalue <- ncatt_get(nc.1,'irra2000','_FillValue')

# Fill zeroes
i.1[i.1==fillvalue$value] <- NA

# Select rasters to compare
#i.1 <- i.1[,,1] #2000
r.1 <- raster(t(i.1),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS(proj4string(usa)))

r.1 <- flip(r.1, direction='y')

writeRaster(r.1, 'irrafract2000.tif', format='GTiff', overwrite=T)

####################

# Read in NetCDF with GWD data
nc.p.2 <- 'irra2010_usa_final.nc'

# Read modeled GWD data from CWatM
nc.2 <- nc_open(nc.p.2)
print(nc.2)

# Get lat/lon coords
lon <- ncvar_get(nc.2,'lon')
lat <- ncvar_get(nc.2,'lat')

# Get GWA variable
i.2 <- ncvar_get(nc.2,'irra2010')
fillvalue <- ncatt_get(nc.2,'irra2010','_FillValue')

# Fill zeroes
i.2[i.2==fillvalue$value] <- NA

# Select rasters to compare
#i.2 <- i.2[,,1] #2000
r.2 <- raster(t(i.2),xmn=min(lon),xmx=max(lon),ymn=min(lat),ymx=max(lat),crs=CRS(proj4string(usa)))

r.2 <- flip(r.2, direction='y')

writeRaster(r.2, 'irrafract2010.tif', format='GTiff', overwrite=T)
