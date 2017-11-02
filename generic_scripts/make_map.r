require(maptools)
# list.files('../research/grain_storage/cb_2016_us_county_500k/')
# file.exists(path)

counties <- '../research/grain_storage/cb_2016_us_county_500k/cb_2016_us_county_500k.shp'
cwu <- '../research/grain_storage/CropWaterUse_USvalues/CWUbl_m3ha/cwu15_bl/sta.adf'

counties_mt <- readShapePoly(counties)
# counties_mt['GEOID']
# plot(counties_mt)

# cwu_mt <- readShapePoly(cwu)
# plot(cwu_mt)

require(raster)
cwu_rast <- shapefile(cwu)
plot(cwu_rast)






# require(rgdal)



# shape_gd <- readOGR(dsn='.',layer=counties) # spatial points dataframe