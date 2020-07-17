library(reshape2)

# List of crops
crops <- c('SOYBEANS')

# Read in area
a <- read.csv('survey_filled_area_soybeans_allyears.csv')

# Read in production (mass)
p <- read.csv('survey_filled_prod_mass_soybeans_allyears.csv')

# Merge datasets
df <- rbind(a,p)

# Select only county data
df <- df[df$Geo.Level == 'STATE',]

# Specify necessary columns
df <- df[,c('Year','State.ANSI','Data.Item','Value')]

# Split data.item column
df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))

# Long to wide data item format
df <- dcast(df,...~Data.Item2, value.var='Value')

# Rename columns
colnames(df) <- c('Year','State.ANSI','Crop','A','P') # Area in Acres; Production in Bu

# Calculate yield
df$Y <- as.numeric(df$P) / as.numeric(df$A) # Yield, Bu/Ac

# Rename variables to have shorter column headers
df$Crop <- tolower(unlist(lapply(strsplit(as.character(df$Crop), ', '), '[[', 1)))
df$Year <- unlist(lapply(substr(as.character(df$Year),3,4), '[[', 1))

# Make table wide for crop types and years
df <- melt(df,id.vars=c('Crop','Year','State.ANSI'))
df <- dcast(df,State.ANSI~Crop+variable+Year,value.var='value')

# Remove underscores from colnames for appropriate length when saving to shapefile
colnames(df) <- gsub('_','',colnames(df))

# Save output
write.csv(df,'survey_filled_alldata_soybeans_allyears_wide.csv',row.names=F)
