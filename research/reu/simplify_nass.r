# Script for cleaning/simplifying compiled nass data

# Read csv to dataframe (df) with data to plot
df <- read.csv('corn_compiled.csv')

# Print first 5 rows of df to check data
print(head(df))

# Print number of rows of data
print(nrow(df))

### Preliminary filters

# Select program (Survey or Census)
df <- df[ df$Program == 'SURVEY', ]
print(nrow(df)) # check if nrow has decreased based on selection

# Specify geographic level (State, Agricultural District, County, ...)
df <- df[ df$Geo.Level == 'COUNTY', ]
print(nrow(df)) # check if nrow has decreased based on selection

# Remove 'OTHER (COMBINED) COUNTIES' from 'County' column for simplicity
# ! character is a negator, so != is "not equal to"
df <- df[ df$County != 'OTHER (COMBINED) COUNTIES', ]
print(nrow(df)) # check if nrow has decreased based on selection

# Convert code columns to character (R reads as integer)
# sprintf allows redefining a value. This line converts numeric column to a string, for pasting to work
df$State.ANSI <- sprintf('%02d',df$State.ANSI)
df$County.ANSI <- sprintf('%03d',df$County.ANSI)

# Create GEOID column (State.ANSI + County.ANSI)
# paste: glues two strings together
df$GEOID <- paste(df$State.ANSI,df$County.ANSI,sep='')

# Organize df into ascending order by GEOID (just makes more sense for looking at; not necessary)
df <- df[order(df$Year,df$GEOID),]

# Select only useful columns (makes code run faster because less data is carried over)
df <- df[,c('Year','GEOID','Data.Item','Value')]

# Convert value column to numeric after removing commas, for calulations and plotting
# gsub replaces all instances of an element in a string: here replaces all commas with nothing
# as.numeric: converts to numeric (in this case converting from a string (called "character" in R)
df$Value <- as.numeric(gsub(',','',df$Value))

### Secondary filters

# Split Data.Item into two columns for easier data filtering
# tstrsplit: a "string split" function to split the Data.Item string over the ' - ' character
# lapply: apply this function to all rows, and recursive=FALSE means only apply once per row
# unlist: convert the returned list (ie., ["CORN, GRAIN", "ACRES HARVESTED"]) to a non-list 
# as.data.frame: converts to dataframe
df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))

# Redefine column names
colnames(df) <- c('Year','GEOID','Commodity','Data.Item','Value')

# Save output
write.csv(df,'corn_simplified.csv',row.names=F)
