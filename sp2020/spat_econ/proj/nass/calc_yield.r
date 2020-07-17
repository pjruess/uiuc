library(reshape2)

# List of crops
crops <- c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT')

# Read in area
a.path <- 'output/survey/area/survey_filled_area_allcrops_allyears.csv'

# Read each crop file individually if not yet compiled; otherwise read compiled file
if (!file.exists(a.path)){
    a <- data.frame()
    for (c in crops){
        a.tmp <- read.csv(sprintf('output/survey/area/survey_filled_area_%s_allyears.csv',tolower(c)))
        a <- rbind(a,a.tmp)
    }
    write.csv(a,a.path)
} else {
    a <- read.csv(a.path)
}

# Read in production (mass)
p.path <- 'output/survey/prod_mass/survey_filled_prod_mass_allcrops_allyears.csv'

# Read each crop file individually if not yet compiled; otherwise read compiled file
if (!file.exists(p.path)){
    p <- data.frame()
    for (c in crops){
        p.tmp <- read.csv(sprintf('output/survey/prod_mass/survey_filled_prod_mass_%s_allyears.csv',tolower(c)))
        p <- rbind(p,p.tmp)
    }
    # Convert rice production from CWT to Bu [cwt ~ 2.22 bu]
    p[p$Commodity == 'RICE',]$Value <- p[p$Commodity == 'RICE',]$Value * 2.22 
    p$Data.Item <- as.character(p$Data.Item)
    p[p$Commodity == 'RICE',]$Data.Item <- 'RICE - PRODUCTION, MEASURED IN BU' 
    write.csv(p,p.path)
} else {
    p <- read.csv(p.path)
}

print(head(a[a$Data.Item=='WHEAT - ACRES HARVESTED' & !(is.na(a$Value)) & a$Geo.Level == 'COUNTY',],10))
print(head(p[p$Data.Item=='WHEAT - PRODUCTION, MEASURED IN BU' & !(is.na(p$Value)) & p$Geo.Level == 'COUNTY',],10))
break

# Merge datasets
df <- rbind(a,p)
print(head(df[df$Data.Item=='WHEAT - ACRES HARVESTED' & !(is.na(df$Value)),],10))
break

# Select only county data
df <- df[df$Geo.Level == 'COUNTY',]

# Specify necessary columns
df <- df[,c('Year','GEOID','Data.Item','Value')]
print(head(df))
print(head(df[df$Data.Item=='WHEAT - ACRES HARVESTED' & !(is.na(df$Value)),],10))

# Split data.item column
df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))
print(head(df[df$Data.Item1=='WHEAT' & !(is.na(df$Value)),],10))

# Long to wide data item format
df <- dcast(df,...~Data.Item2, value.var='Value')
print(head(df[df$Data.Item1=='WHEAT',],10))

# Rename columns
colnames(df) <- c('Year','GEOID','Crop','A','P') # Area in Acres; Production in Bu

# Calculate yield
df$Y <- as.numeric(df$P) / as.numeric(df$A) # Yield, Bu/Ac

print(head(df[df$Crop=='WHEAT',]))
break

# Rename variables to have shorter column headers
df$Crop <- tolower(unlist(lapply(strsplit(as.character(df$Crop), ', '), '[[', 1)))
df$Year <- unlist(lapply(substr(as.character(df$Year),3,4), '[[', 1))

# Make table wide for crop types and years
#wide.var <- function(df){
#    df <- melt(df,id.vars=c('Crop','Year','GEOID'))
#    df <- dcast(df,GEOID~Crop+variable+Year,value.var='value')
    #df <- dcast(df,...~Crop,value.var=var)
    #df <- df[,c(1,2,5:11)]
    #colnames(df) <- c('Year','GEOID',sprintf('Barley.%s',lab),sprintf('Corn.%s',lab),sprintf('Oats.%s',lab),sprintf('Rice.%s',lab),sprintf('Rye.%s',lab),sprintf('Sorghum.%s',lab),sprintf('Wheat.%s',lab))
    #final <- data.frame(GEOID=character())
    #for (y in unique(df$Year)){
    #    temp <- df[df$Year == y,2:9]
    #    colnames(temp) <- c('GEOID',sprintf('Barley.%s.%s',lab,y),sprintf('Corn.%s.%s',lab,y),sprintf('Oats.%s.%s',lab,y),sprintf('Rice.%s.%s',lab,y),sprintf('Rye.%s.%s',lab,y),sprintf('Sorghum.%s.%s',lab,y),sprintf('Wheat.%s.%s',lab,y))
    #    final <- merge(final,temp,by='GEOID')
    #}
    #print(head(final))
    #break
#}
df <- melt(df,id.vars=c('Crop','Year','GEOID'))
df <- dcast(df,GEOID~Crop+variable+Year,value.var='value')

# Remove underscores from colnames for appropriate length when saving to shapefile
colnames(df) <- gsub('_','',colnames(df))

# Save output
write.csv(df,'output/survey/survey_filled_alldata_allcrops_allyears_wide.csv',row.names=F)
