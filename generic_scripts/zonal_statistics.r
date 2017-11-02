# Example from: https://gis.stackexchange.com/questions/66795/combine-raster-and-polygon-values-in-r

require(raster)
require(maptools)

# Read the polygon shapefile
poly = readShapePoly("C:/temp/poly.shp")
plot(poly)

# Read the single band raster
raster = raster("C:/temp/subset.tif")

# Extract the raster values underlying the polygons
v <- extract(raster, poly, fun = mean)
output = data.frame(v)
print(output)