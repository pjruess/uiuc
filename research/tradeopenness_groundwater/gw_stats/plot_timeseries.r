library(ggplot2)
library(reshape2)
library(stringr)

# Read groundwater data
gwd <- read.csv('gwd_total.csv')[,c(3,4,7,12)]
gwa <- read.csv('gwa_total.csv')[,c(3,4,7,12)]

print(head(gwd))
print(head(gwa))

# Read regions crosswalk if needed
cw <- read.csv('iso_to_region_crosswalk.csv')[,c(3,6)]
cw <- cw[(cw$region!=''),]

print(head(cw,10))

gwd <- merge(gwd,cw,by.x='ISO3',by.y='alpha.3')[,c(2,3,5)]
gwa <- merge(gwa,cw,by.x='ISO3',by.y='alpha.3')[,c(2,3,5)]

print(head(gwd))
print(head(gwa))

write.csv(gwd,'test.csv')

# Sum regionally
gwd <- aggregate(gwd ~ region+year, gwd, sum)
gwa <- aggregate(gwa ~ region+year, gwa, sum)

# GWD, regions
ggplot(data=gwd,aes(x=year,y=gwd,color=region)) + 
    geom_line(aes(linetype=region,color=region),lwd=1.5) +
    #geom_point(aes(color=Area)) +
    labs(title='Groundwater Depletion (GWD) by Region')

ggsave('timeseries_gwd_regions.png')

# GWA, regions
ggplot(data=gwa,aes(x=year,y=gwa,color=region)) + 
    geom_line(aes(linetype=region,color=region),lwd=1.5) +
    #geom_point(aes(color=Area)) +
    labs(title='Groundwater Abstractions (GWA) by Region')

ggsave('timeseries_gwa_regions.png')

# Sum globally
#df <- aggregate(. ~ Item+Year, df, sum)
