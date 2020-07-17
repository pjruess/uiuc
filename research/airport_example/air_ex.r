# from: https://gist.github.com/rafapereirabr/9a36c2e5ff04aa285fa3

library(plyr)

a <- read.csv('airports.csv')
f <- read.csv('PEK-openflights-export-2012-03-19.csv')

# locations
a <- a[,c('IATA','longitude','latitude')]

# ag flights
f <- ddply(f,c('From','To'),function(x) count(x$To))
print(head(a))
print(head(f))

df <- merge(f,a,by.x='From',by.y='IATA')
df <- df[,c(1:2,4:6)]
colnames(df) <- c('ori','des','val','ori_lon','ori_lat')
df <- merge(df,a,by.x='des',by.y='IATA')
colnames(df) <- c('des','ori','val','ori_lon','ori_lat','des_lon','des_lat')

df$id <- as.character(c(1:nrow(df)))

print(head(df))

library(rworldmap)
library(ggplot2)
worldMap <- getMap()
map <- fortify(worldMap)

ggplot() + 
    geom_polygon(data= map, aes(long,lat, group=group), fill="gray30") +
    geom_curve(data = df, aes(x = ori_lon, y = ori_lat, xend = des_lon, yend = des_lat, color=val),curvature = -0.2, arrow = arrow(length = unit(0.01, "npc"))) +
    scale_colour_distiller(palette="Reds", name="Frequency", guide = "colorbar") +
    coord_equal()

