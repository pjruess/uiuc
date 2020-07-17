library(raster)
library(ncdf4)
library(rgdal)
library(glue)

# Read in country shapefile
countries <- readOGR('../TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp')
print(countries)

# Countries dataframe for merging with final weighted values
c <- as.data.frame(countries)
rownames(c) <- NULL

# Read in GWD NetCDF file
gwd.nc <- nc_open('../rawdata/waterdemand_30min_groundwaterdepletion_yearly_1960-2010.nc')

gwd <- ncvar_get(gwd.nc,'anrg')
gwd.fillval <- ncatt_get(gwd.nc,'anrg','_FillValue')
gwd.lon <- ncvar_get(gwd.nc,'longitude')
gwd.lat <- ncvar_get(gwd.nc,'latitude')
gwd[gwd==gwd.fillval$value] <- NA

final <- data.frame(ID=numeric(),
                    gwd=numeric(),
                    year=numeric())

for (y in 1:51){ # 1960-2010
    gwd.y <- gwd[,,y]
    gwd.r <- raster(t(gwd.y),xmn=min(gwd.lon),xmx=max(gwd.lon),ymn=min(gwd.lat),ymx=max(gwd.lat),crs=CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0'))

    # Extract example: https://stackoverflow.com/questions/42361158/how-can-i-extract-an-area-weighted-sum-from-a-raster-into-a-polygon-in-r 
    df <- extract(gwd.r,countries,weights=T,normalizeWeights=F,df=T)
    df$gwd <- df$layer*df$weight

    # Aggregate example: https://stackoverflow.com/questions/1660124/how-to-sum-a-variable-by-group
    df <- aggregate(gwd ~ ID, df, sum, na.rm=T, na.action=NULL)
    year <- y + 1959
    df$year <- year

    temp <- merge(df,c,by=0)

    temp <- temp[order(as.numeric(temp$Row.names)),]#c('FIPS','ISO3','NAME','gwd','year')]

    write.csv(temp,glue('gwd_{year}.csv'),row.names=F)

    final <- rbind(final,temp)
    print(glue('Finished {year}'))
}

write.csv(final,'gwd_total.csv',row.names=F)
