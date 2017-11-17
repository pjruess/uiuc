library(maptools)
library(raster)

# Create list of all rasters to iterate through
grids <- list.files('~/Downloads/act2000twhe2000yld_package',pattern='*tif$')

# Read in the polygon shapefile to use as mask
poly <- readShapePoly('~/uiuc/research/grain_storage/cb_2016_us_county_500k/cb_2016_us_county_500k.shp')

# Create raster stack
s <- stack(paste0('~/Downloads/act2000twhe2000yld_package/',grids))

# Extract raster cell count (sum) within each polygon area (poly)
for (i in 1:length(grids)){
	ex <- extract(
		s,
		poly,
		fun=mean,
		na.rm=T, # remove NA values
		df=T # return results as dataframe
		)
}

# Write to a data frame
df <- data.frame(ex)
df

# Write to a CSV file
write.csv(df,file='r_zonal_stat_test.csv')