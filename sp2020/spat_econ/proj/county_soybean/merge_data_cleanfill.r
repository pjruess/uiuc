# Read in Survey data
a <- read.csv('../nass/output/survey_filled_area_soybeans_2018.csv')
p <- read.csv('../nass/output/survey_filled_prod_mass_soybeans_2018.csv')
a.c <- read.csv('../nass/output/survey_clean_area_soybeans_2018.csv')
p.c <- read.csv('../nass/output/survey_clean_prod_mass_soybeans_2018.csv')

# Select only counties
a <- a[a$Geo.Level == 'COUNTY',]
p <- p[p$Geo.Level == 'COUNTY',]
a.c <- a.c[a.c$Geo.Level == 'COUNTY',]
p.c <- p.c[p.c$Geo.Level == 'COUNTY',]

# Select only value columns
a <- a[,c('GEOID','Value')]
p <- p[,c('GEOID','Value')]
a.c <- a.c[,c('GEOID','Value')]
p.c <- p.c[,c('GEOID','Value')]

# Change column names
colnames(a) <- c('GEOID','area18f')
colnames(p) <- c('GEOID','prod18f')
colnames(a.c) <- c('GEOID','area18c')
colnames(p.c) <- c('GEOID','prod18c')

res.f <- merge(a,p,all=T)
res.f$yield18f <- res.f$prod18f / res.f$area18f

res.c <- merge(a.c,p.c,all=T)
res.c$yield18c <- res.c$prod18c / res.c$area18c

res <- merge(res.f,res.c,all=T)

res$GEOID <- sprintf('%05d',as.numeric(as.character(res$GEOID)))

# Save
write.csv(res,'merged_data_soybeans_2018_cleanfill.csv',row.names=F)
