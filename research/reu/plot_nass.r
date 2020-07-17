# Script for creating time series plots

# Read in necessary libaries (downloadable packages with useful functions)
library(ggplot2)

# Read data
df <- read.csv('corn_simplified.csv')

# Make sure GEOID column is read correctly
df$GEOID <- sprintf('%05d',df$GEOID)

# Select commodity
df <- df[ df$Commodity == 'CORN, GRAIN', ]

# Select data item
df <- df[ df$Data.Item == 'ACRES HARVESTED', ]

# Sum together all counties for each year
df <- aggregate(Value~Year, df, FUN=sum)

# Rename columns for simpler plotting
colnames(df) <- c('Year','Area')

# Create plot
ggplot(data=df,aes(x=Year,y=Area)) + 
    geom_line(lwd=1.5) +
    labs(title='National Sum of Harvested Area for Corn, Grain')
ggsave('corn_area_national.png')
