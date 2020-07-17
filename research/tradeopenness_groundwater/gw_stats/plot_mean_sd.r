library(ggplot2)
library(reshape2)
library(stringr)

df <- read.csv('mean_sd_countrywise.csv')

# Sum globally
#df <- aggregate(. ~ Agvars, df, sum)

# Remove 'Area' column
df <- df[,!(names(df) == 'Area')]

df <- melt(df,measure.vars=c('X1961.1970','X1971.1980','X1981.1990','X1991.2000','X2001.2010','X2011.2017'),variable.name='Year',value.name='Sum')

# Clean up 'Year' Column
df$Year <- gsub('.','-',substring(df$Year,2),fixed=T)

### PLOT MEANS

df1 <- df[!(df$Agvars %in% c('Area.harvested_sd','Production_sd','Yield_sd')),]

print(head(df1))

# Change header names for pretty plot
names(df1) <- c('Country.Code','Variable','Year','Sum')

# Plot without outliers
ggplot(data=df1,aes(x=Year,y=Sum)) + 
    geom_boxplot(aes(fill=Variable),outlier.shape=NA) +
    scale_y_continuous(limits=c(0,3.5e7)) + 
    labs(x='Decade',y='Country Means',title='Country Means of Area, Production, and Yield, NO OUTLIERS')

ggsave('plot_mean.pdf')

# Plot with outliers
ggplot(data=df1,aes(x=Year,y=Sum)) + 
    geom_boxplot(aes(fill=Variable)) + 
    labs(x='Decade',y='Country Means',title='Country Means of Area, Production, and Yield')

ggsave('plot_mean_outliers.pdf')

### PLOT STANDARD DEVIATIONS

df2 <- df[!(df$Agvars %in% c('Area.harvested_mean','Production_mean','Yield_mean')),]

print(head(df2))

# Change header names for pretty plot
names(df2) <- c('Country.Code','Variable','Year','Sum')

# Plot without outliers
ggplot(data=df2,aes(x=Year,y=Sum)) + 
    geom_boxplot(aes(fill=Variable),outlier.shape=NA) +
    scale_y_continuous(limits=c(0,2.5e6)) + 
    labs(x='Decade',y='Country Standard Deviations',title='Country Standard Deviation of Area, Production, and Yield, NO OUTLIERS')

ggsave('plot_sd.pdf')

# Plot with outliers
ggplot(data=df2,aes(x=Year,y=Sum)) + 
    geom_boxplot(aes(fill=Variable)) + 
    labs(x='Decade',y='Country Standard Deviations',title='Country Standard Deviations of Area, Production, and Yield')

ggsave('plot_sd_outliers.pdf')
