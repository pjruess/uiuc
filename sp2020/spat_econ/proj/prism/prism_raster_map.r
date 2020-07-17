library(raster)
library(rgdal)

path <- 'prism_2018_tmean'

# Define file paths for all .bil files
files <- Sys.glob(file.path(path,'*.bil'))
f <- files[1]
print(f)
p <- raster(f)
plot(p)
