library(reshape2)
library(ggplot2)
library(glue)

# Compare (plot) Census vs. Survey data for Corn, Grain Area and Production 

# Check if compiled file exists
comp <- '../data/interim/combined_census_survey_corn_grain.csv'

if (!file.exists(comp)) {

    # Define empty dataframe to compile all crops
    df <- data.frame()
    
    # Read in all data from rawdata folder
    files <- list.files(path='../data/survey/',pattern='*.csv',full.names=T,recursive=F)
    files <- append(files,'../data/raw/corn_grain_county_census.csv')
    for (data in files) {
        print(data)
        temp <- read.csv(data)
        df <- rbind(df,temp)
    }
    
    # Save compiled output
    write.csv(df,comp,row.names=F)

} else {
    df <- read.csv(comp)
}

# Check if final file exists
final <- '../data/clean/clean_census_survey_corn_grain.csv'

if(!file.exists(final)){

    # Define GEOID column
    df$GEOID <- paste( sprintf('%02d', df$State.ANSI), sprintf('%03d', df$County.ANSI), sep='' )
    
    # Select specific columns
    df <- df[,c('Program','Year','GEOID','County.ANSI','State','County','Data.Item','Value')]

    # Separate out CENSUS data to add in later
    df.census <- df[df$Program == 'CENSUS',]

    # Separate out SURVEY data to add in later
    df <- df[df$Program == 'SURVEY',]

    # Read in county shapefile attribute table for all possible counties
    cnty <- read.csv('../../always_data/county_attribute_table.csv')
    cnty$GEOID <- sprintf('%05d', cnty$GEOID)
    cnty <- cnty[,c('GEOID','NAME')]
    
    final <- data.frame()

    # NOTE: 'OTHER' data is distinguished for Agricultural Districts... Need to separate out this way.
    # NOTE: To do this, need county data INCLUDING ag districts (check always_data/ for ideas)

    # For each year, add missing counties to dataframe (otherwise miss counties for some years)
    for (y in unique(df$Year)) {
        print(y)
        temp <- df[df$Year == y,]
        temp <- merge(temp,cnty,all=T)
        print(head(temp))
        final <- rbind(final,temp)
        print(head(final))
        write.csv(final,glue('test_{y}.csv'),row.names=F)
    }

    write.csv(final,'test_indivyears.csv',row.names=F)

    print(head(df))
    break
    #write.csv(df,'test.csv',row.names=F)

    # Duplicate 

    # For each state, select the 'OTHER, COMBINED COUNTIES' column

    # Select 'other' added counties

    # Evenly distribute 'OTHER, COMBINED COUNTIES' value to all 'other' counties

    
    print(head(cnty))
    print(head(df))
    print(unique(df$Program))

    break

    # Remove Survey data with missing County.ANSI ('OTHER, COMBINED COUNTIES')
    #df <- df[df$County != 'OTHER (COMBINED) COUNTIES',]

    # Reclassify redacted values as NA
    df$Value <- as.numeric(as.character(gsub(',','',df$Value)))
    
    # Redefine commodity column to include details (ie. 'Corn, Grain', etc.)
    df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))
    
    # Select specific columns
    df <- df[,c('Year','GEOID','Program','Data.Item1','Data.Item2','Value')]
    
    # Reorganize harvest and production to columns
    df <- dcast(df,...~Data.Item2, value.var='Value')
    
    df[,c(5:6)] <- sapply(df[,c(5:6)],as.numeric)
    
    colnames(df) <- c('Year','GEOID','Program','Crop','Area.Ac','Prod.Bu')
    
    # Calculate yield
    df$Yield.BuAc <- df$Prod.Bu / df$Area.Ac

    # Save final output
    write.csv(df,final,row.names=F)

} else {
    df <- read.csv(final)
}

print(head(df))

# Sum, Mean, and StDev for Area, Prod, and Yield (sum is nonsensical)
df.area <- aggregate(Area.Ac~Year+Program, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))
df.prod <- aggregate(Prod.Bu~Year+Program, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))
df.yield <- aggregate(Yield.BuAc~Year+Program, df, FUN=(function(x){c(mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))

print(head(df.area))
print(head(df.prod))
print(head(df.yield))

# Plot time trends
for (d in c('sum','mean','sd')){

    # Harvested Area
    ggplot(data=df.area,aes(x=Year,y=Area.Ac[,d],color=Program)) + 
        geom_point(aes(color=Program)) +
        #geom_line(aes(linetype=Program,color=Program),lwd=1.5) +
        #geom_point(aes(color=Area)) +
        labs(glue(title='Harvested Area by Program, {d}'),y=glue('Area.Ac.{d}'))
	ggsave(glue('../plots/census_vs_survey/area_{d}.png'))

    # Production
    ggplot(data=df.prod,aes(x=Year,y=Prod.Bu[,d],color=Program)) + 
        geom_point(aes(color=Program)) +
        #geom_line(aes(linetype=Program,color=Program),lwd=1.5) +
        #geom_point(aes(color=Area)) +
        labs(glue(title='Production by Program, {d}'),y=glue('Prod.Bu.{d}'))
	ggsave(glue('../plots/census_vs_survey/prod_{d}.png'))

    if (d != 'sum') {
        # Yield
        ggplot(data=df.yield,aes(x=Year,y=Yield.BuAc[,d],color=Program)) + 
            geom_point(aes(color=Program)) +
            #geom_line(aes(linetype=Program,color=Program),lwd=1.5) +
            #geom_point(aes(color=Area)) +
            labs(glue(title='Yield by Program, {d}'),y=glue('Yield.BuAc.{d}'))
	    ggsave(glue('../plots/census_vs_survey/yield_{d}.png'))
    }

}
