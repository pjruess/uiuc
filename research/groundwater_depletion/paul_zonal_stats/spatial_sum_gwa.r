library(raster)
library(ncdf4)
library(rgdal)
library(glue)

# Read in country shapefile
countries <- readOGR('../cb_2016_us_county_500k/cb_2016_us_county_500k.shp')
print(countries)

# Countries dataframe for merging with final weighted values
c <- as.data.frame(countries)
rownames(c) <- NULL

# Read in GWA NetCDF file
gwa.nc <- nc_open('../waterdemand_30min_groundwaterabstraction_annual.nc')

gwa <- ncvar_get(gwa.nc,'gwab')
gwa.fillval <- ncatt_get(gwa.nc,'gwab','_FillValue')
gwa.lon <- ncvar_get(gwa.nc,'longitude')
gwa.lat <- ncvar_get(gwa.nc,'latitude')
gwa[gwa==gwa.fillval$value] <- NA

final <- data.frame(ID=numeric(),
                    gwa=numeric(),
                    year=numeric())

for (y in c(41,51)){ # 1960-2010
    gwa.y <- gwa[,,y]
    gwa.r <- raster(t(gwa.y),xmn=min(gwa.lon),xmx=max(gwa.lon),ymn=min(gwa.lat),ymx=max(gwa.lat),crs=CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0'))

    # Extract example: https://stackoverflow.com/questions/42361158/how-can-i-extract-an-area-weighted-sum-from-a-raster-into-a-polygon-in-r 
    df <- extract(gwa.r,countries,weights=T,normalizeWeights=F,df=T)
    df$gwa <- df$layer*df$weight

    # Aggregate example: https://stackoverflow.com/questions/1660124/how-to-sum-a-variable-by-group
    df <- aggregate(gwa ~ ID, df, sum, na.rm=T, na.action=NULL)
    year <- y + 1959
    df$year <- year

    temp <- merge(df,c,by=0)

    temp <- temp[order(as.numeric(temp$Row.names)),]#c('FIPS','ISO3','NAME','gwa','year')]

    write.csv(temp,glue('gwa_{year}.csv'),row.names=F)

    final <- rbind(final,temp)
    print(glue('Finished {year}'))
}

write.csv(final,'gwa_total.csv',row.names=F)
