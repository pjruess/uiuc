library(rgdal)
library(raster)
# library(maptools)

polygon_path <- 'cb_2016_us_county_500k/cb_2016_us_county_500k.shp'
counties <- readOGR(polygon_path)
raster_path <- '~/Downloads/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10.img'
nlcd <- raster(raster_path)



# pdf('nlcd_2011.pdf')
# plot(raster)
# dev.off()

# Select by x = 81 or 82 (cropland)
con <- function(x) {
	if (x == 81 || x == 82) { 
		res <- 1
	} else {
		res <- 0
	}
	return(res)
}

nlcd_con <- calc(nlcd,con)

# matr <- as.matrix(nlcd_calc)

c <- extract(nlcd_con,counties,fun=sum,na.rm=TRUE,df=TRUE)
df <- data.frame(c)
write.csv(df,file='script_outputs/nlcd_2011_zonalstats.csv')

# raster <- as.matrix(raster)

# Con <- function(condition, true.value, false.value){
# 	return( condition*true.value + (!condition)*false.value )
# }

# as.matrix( Con( (raster=81|raster=82), 1, 0 ) )

# freq(nlcd,value=81) 


# nlcd <- nlcd[ which( nlcd@data$ID == '81' | nlcd@data$ID == '82'), ]
# nlcd@data




