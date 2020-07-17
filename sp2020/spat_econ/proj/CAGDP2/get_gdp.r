
df <- read.csv('CAGDP2__ALL_AREAS_2001_2018.csv')

df$GeoFIPS <- sprintf('%05d',as.numeric(as.character(df$GeoFIPS)))

df <- df[df$LineCode == 1,]

# Remove states
df <- df[substr(df$GeoFIPS,3,5) != '000',]

# Remove US total
#df <- df[df$GeoFIPS != 00000,]

df <- df[,c('GeoFIPS','X2018')]

colnames(df) <- c('GEOID','gdp18')

write.csv(df,'gdp_2018.csv',row.names=F)
