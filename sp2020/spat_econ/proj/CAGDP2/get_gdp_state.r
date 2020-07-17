# Read input file
df <- read.csv('CAGDP2__ALL_AREAS_2001_2018.csv')

# Convert geoid column to read properly
df$GeoFIPS <- sprintf('%05d',as.numeric(as.character(df$GeoFIPS)))

# Select only industry total
df <- df[df$LineCode == 1,]

# Only select states
df <- df[substr(df$GeoFIPS,3,5) == '000',]

# Remove US total
df <- df[df$GeoFIPS != '00000',]

# Define state FIPS codes
df$StateFIPS <- substr(df$GeoFIPS,1,2)

# Remove all columns except geoid and years
df <- df[,-c(1:8)]

# Rename columns
colnames(df) <- c('gdp01','gdp02','gdp03','gdp04','gdp05','gdp06','gdp07','gdp08','gdp09','gdp10','gdp11','gdp12','gdp13','gdp14','gdp15','gdp16','gdp17','gdp18','StateFIPS')

# Save output
write.csv(df,'gdp_states_allyears.csv',row.names=F)
