c <- read.csv('new_capeff_GEOID_test.csv',stringsAsFactors=F)
s <- read.csv('new_capeff_STATE ANSI_test.csv',stringsAsFactors=F)

c$Yield_Bu_per_Ac <- c$Production_Bu / c$Harvest_Ac
s$Yield_Bu_per_Ac <- s$Production_Bu / s$Harvest_Ac

c$Storage_Actual_Bu <- c$Storage_Bu * c$Percent_Harvest
s$Storage_Actual_Bu <- s$Storage_Bu * s$Percent_Harvest

ccols <- c('Harvest_Ac','Production_Bu','Yield_Bu_per_Ac','Storage_Actual_Bu','CWU_gn_m3yr','Precipitation_Volume_km3','VWS_rf_m3','Capture_Efficiency')
c <- subset(c,select=ccols)
s <- subset(s,select=c('Harvest_Ac','Production_Bu','Yield_Bu_per_Ac','Storage_Actual_Bu','CWU_gn_m3yr','Precipitation_Volume_km3','VWS_rf_m3','Capture_Efficiency'))
#c <- c[,-c('GEOID','Commodity','Water.Type','Storage_Bu','Precipitation_Pixel_Count','Land_Area_km2')]

#c <- lapply(c,function(x) as.numeric(as.character(x,na.rm=T),na.rm=T))
#c <- apply(c,2,function(x) as.numeric(as.character(x)))
#c <- as.numeric(as.character(unlist(c)))

# Remove integer(0), whatever that is???
sapply(c,class)
c <- c[!is.na(c$Capture_Efficiency),]
head(c,20)

which(is.na(c))

c$Color <- cut(c['Capture_Efficiency'], breaks = c(-Inf, 100, Inf), labels = c('black','red'))
#s$Color <- cut(s$Capture_Efficiency, breaks = c(-Inf, 100, Inf), labels = c('black','red'))

head(c)
normalize <- function(x) { return ((x - min(x,na.rm=T)) / (max(x,na.rm=T) - min(x,na.rm=T))) }
print('test')
#head(s)
print('test2')
# Plot counties, looking especially at large CapEff values against other variables
#pairs(~Harvest_Ac+Production_Bu+Yield_Bu_per_Ac+Storage_Actual_Bu+CWU_gn_m3yr+Precipitation_Volume_km3+VWS_rf_m3+Capture_Efficiency,data=c,col=c$Color)

# Boxplots comparing CapEff <100 and > 100 for other variables
c.norm <- apply(c[ccols],2,normalize)

