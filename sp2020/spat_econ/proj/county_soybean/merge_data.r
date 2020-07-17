# Read in Survey data
a <- read.csv('../nass/output/survey_filled_area_soybeans_2018.csv')
p <- read.csv('../nass/output/survey_filled_prod_mass_soybeans_2018.csv')
df <- read.csv('../prism/clean/prism_county_2018.csv')
g <- read.csv('../CAGDP2/gdp_2018.csv')

# Select only counties
a <- a[a$Geo.Level == 'COUNTY',]
p <- p[p$Geo.Level == 'COUNTY',]

# Select only value columns
a <- a[,c('GEOID','Value')]
p <- p[,c('GEOID','Value')]
df <- df[,c('GEOID','ppt18sum','tmean18avg')]

# Change column names
colnames(a) <- c('GEOID','area18')
colnames(p) <- c('GEOID','prodmass18')

# Define GEOID column for merging
#a$GEOID <- sprintf('%05d',a$GEOID)
#p$GEOID <- sprintf('%05d',p$GEOID)
df$GEOID <- sprintf('%05d',df$GEOID)
g$GEOID <- sprintf('%05d',g$GEOID)

# Order df to check GEOID columns
#a <- a[order(a$GEOID),]
#p <- p[order(p$GEOID),]
#df <- df[order(df$GEOID),]

res <- merge(a,p,all=T)
res <- merge(res,df,all=T)
res <- merge(res,g,all=T)

res$yield18 <- res$prodmass18 / res$area18

res$GEOID <- sprintf('%05d',as.numeric(as.character(res$GEOID)))

# Save
write.csv(res,'merged_data_soybeans_2018.csv',row.names=F)
