### plot county map for long difference in temp and prep

# load libraries
library(rgdal)
library(fields)
library(maptools)

# remove everything in the environment
rm(list = ls())

# read in csv data
# BLAH BLAH BLAH I know how to do most of this stuff. Review before exam.
diff.data <- read.csv("US counties poverty.dbf")

# write down shpfile for in county shpfile
shpfile.dir <- "C:/Users/simizicee/Downloads/county_map/county shpfile"
county_map <- readOGR(dsn = shpfile.dir, "gz_2010_us_050_00_20m")
county_map$fips <- as.numeric(as.character(county_map$STATE)) * 1000 + as.numeric(as.character(county_map$COUNTY))

# merge the mapdata with shpfile
diff_map <- merge(county_map, diff.data, by = "fips")

# remove the missing value for spplot
rmna_diff_map <- diff_map[!(is.na(diff_map$avetemp_df_sd) | is.na(diff_map$aveprec_df_100) | is.na(diff_map$land_val_df)),]

# create state boundary
state_borders <- unionSpatialPolygons(county_map, as.numeric(county_map@data$STATE))

# first, temperature
tchg <- rmna_diff_map$avetemp_df_sd
rg <- seq(-max(tchg)-0.25,max(tchg)+0.25,(2*max(tchg)+0.5)/20)
colz = tim.colors(length(rg))

# show a basic quantile map for changes in temperature
spplot(rmna_diff_map, "avetemp_df_sd", main="temperature", at = rg, col.regions = colz, col="transparent",
       sp.layout = list(state_borders, first = FALSE))

# show the histrogram for changes in temperature
hist(tchg,breaks=rg,col=colz,xlab="temp change (C)",main="",yaxt="n",ylab="",cex.axis=1.5,cex.lab=1.5)

# second, precipitation
pchg <- rmna_diff_map$aveprec_df_100
pchg <- ifelse(pchg >= 0.55,0.55,pchg) # suppress the extreme value
rmna_diff_map$aveprec_df_100 <- pchg
rg <- seq(-0.6,0.6,1.2/20)
colz = tim.colors(length(rg))

# show a basic quantile map for changes in precipitation
spplot(rmna_diff_map, "aveprec_df_100", main="precipitation", at = rg, col.regions = colz, col="transparent",
       sp.layout = list(state_borders, first = FALSE))

# show the histrogram for changes in precipitation
hist(pchg,breaks=rg,col=colz,xlab="precip change (%)",main="",yaxt="n",ylab="",cex.axis=1.5,cex.lab=1.5)

# third, land value
lvchg <- rmna_diff_map$land_val_df
rg <- c(seq(-max(lvchg),max(lvchg),(2*max(lvchg))/20))
colz = tim.colors(length(rg))

# show a basic quantile map for changes in land value
spplot(rmna_diff_map, "land_val_df", main="land value", at = rg, col.regions = colz, col="transparent", 
       sp.layout = list(state_borders, first = FALSE))

# show the histrogram for changes in land value
hist(lvchg,breaks=rg,col=colz,xlab="land value change (log)",main="",yaxt="n",ylab="",cex.axis=1.5,cex.lab=1.5)  
