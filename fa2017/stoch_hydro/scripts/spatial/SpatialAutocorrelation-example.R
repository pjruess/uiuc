# Spatial autocorrelation example
library(maptools)
library(rgdal)
library(spdep)
library(maps)
library(ggplot2)
library(mapproj)

# Read shapefile
getinfo.shape("IL_counties/IL_counties/Illinois_Counties_Clipped.shp")
illinois <- readShapePoly("IL_counties/IL_counties/Illinois_Counties_Clipped.shp")
class(illinois)

# Project shapefile
proj4string(illinois) <- CRS("+proj=longlat +ellps=WGS84")
illinois_NAD <- spTransform(illinois, CRS("+init=epsg:3358"))
map(illinois, myborder=0.05)
map.axes(cex.axis=0.8)
plot(illinois_NAD)
map.axes(cex.axis=0.8)

# Neighbors based on contiguity
illinois_nbq <- poly2nb(illinois) # QUEEN boundary points
illinois_nbr <- poly2nb(illinois, queen=FALSE) # ROOK boundary points
coords <- coordinates(illinois)
# Plot Queen
plot(illinois, main="Queen's Case")
plot(illinois_nbq, coords, add=TRUE)
# Plot Rook
plot(illinois, main="Rook's Case")
plot(illinois_nbr, coords, add=TRUE)

# Neighbors based on distance (k-nearest neighbors)
coords <- coordinates(illinois_NAD)
IDs <- row.names(as(illinois_NAD, "data.frame"))
illinois_kn1 <- knn2nb(knearneigh(coords, k=1), row.names=IDs)
illinois_kn2 <- knn2nb(knearneigh(coords, k=2), row.names=IDs)
illinois_kn4 <- knn2nb(knearneigh(coords, k=4), row.names=IDs)
# Plot K = 1
plot(illinois_NAD,main="K=1")
plot(illinois_kn1, coords, add=TRUE)
# Plot K = 2
plot(illinois_NAD,main="K=2")
plot(illinois_kn2, coords, add=TRUE)
# Plot K = 4
plot(illinois_NAD,main="K=4")
plot(illinois_kn4, coords, add=TRUE)

# Neighbors based on distance (specified distance)
dist <- unlist(nbdists(illinois_kn1, coords))
summary(dist)
max_k1 <- max(dist)
illinois_kd1 <- dnearneigh(coords, d1=0, d2=0.75*max_k1, row.names=IDs)
illinois_kd2 <- dnearneigh(coords, d1=0, d2=1*max_k1, row.names=IDs)
illinois_kd3 <- dnearneigh(coords, d1=0, d2=1.5*max_k1, row.names=IDs)
# Plot specified distance = 0.75
plot(illinois_NAD,main="Distance=0.75")
plot(illinois_kd1, coords, add=TRUE)
# Plot specified distance = 1 
plot(illinois_NAD,main="Distance=1.0")
plot(illinois_kd2, coords, add=TRUE)
# Plot specified distance = 1.5
plot(illinois_NAD,main="Distance=1.5")
plot(illinois_kd3, coords, add=TRUE)

# Row-standardized weights matrix
illinois_nbq_w <- nb2listw(illinois_nbq)
illinois_nbq_w

# Binary weights matrix
illinois_nbq_wb <- nb2listw(illinois_nbq, style="B")
illinois_nbq_wb

# Tutorial for spdep library, based on https://geodacenter.asu.edu/drupal_files/spdepintro.pdf
# Confirm built-in library test data work
data(columbus)
summary(columbus)
objects(columbus)

# Create linear regression model
columbus.lm <- lm(CRIME ~ INC + HOVAL, data=columbus)
summary(columbus.lm)

# Define spatial weights
col.listw <- nb2listw(col.gal.nb)
print(col.gal.nb)
summary(col.gal.nb)

# Perform Moran's I test
col.moran <- lm.morantest(columbus.lm, col.listw)
summary(col.moran)
print(col.moran)
