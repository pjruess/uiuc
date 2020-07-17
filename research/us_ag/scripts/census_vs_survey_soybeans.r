library(reshape2)
library(ggplot2)
library(glue)

# Compare (plot) Census vs. Survey data for Corn, Grain Area and Production 

# Check if compiled file exists
final <- '../data/compare_census_survey/output/combined_census_survey_soybeans.csv'

if (!file.exists(final)) {

    # Define empty dataframe to compile all crops
    df <- data.frame()
    
    # Read in raw survey data
    s.raw.area <- read.csv('../data/compare_census_survey/output/survey/soybeans_survey_raw_clean_area_allyears.csv')
    s.raw.prod <- read.csv('../data/compare_census_survey/output/survey/soybeans_survey_raw_clean_prod_allyears.csv')

    # Read in raw census data
    c.raw.area <- read.csv('../data/compare_census_survey/output/census/soybeans_census_raw_clean_area_allyears.csv')
    c.raw.prod <- read.csv('../data/compare_census_survey/output/census/soybeans_census_raw_clean_prod_allyears.csv')

    # Read in filled survey data
    s.fill.area <- read.csv('../data/compare_census_survey/output/survey/soybeans_survey_filled_area_allyears.csv')
    s.fill.prod <- read.csv('../data/compare_census_survey/output/survey/soybeans_survey_filled_prod_allyears.csv')

    # Read in filled census data
    c.fill.area <- read.csv('../data/compare_census_survey/output/census/soybeans_census_filled_area_allyears.csv')
    c.fill.prod <- read.csv('../data/compare_census_survey/output/census/soybeans_census_filled_prod_allyears.csv')

    # Clean raw data, convert value to numeric, change column headers, etc.
    clean <- function(df,prog,var){
        # Select only county data
        df <- df[df$Geo.Level =='COUNTY',]

        df$Program <- prog

        # Specify necessary columns
        df <- df[,c('Year','GEOID','Program','Data.Item','Value')]

        # Redefine commodity column to include details (ie. 'Corn, Grain', etc.)
        df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))
    
        # Reorganize harvest and production to columns
        df <- dcast(df,...~Data.Item2, value.var='Value')
    
        # Rename columns
        colnames(df) <- c('Year','GEOID','Program','Crop',var)

        return(df)
    }

    s.raw.area.clean <- clean(s.raw.area,'SURVEY, RAW','Area.Ac')
    s.raw.prod.clean <- clean(s.raw.prod,'SURVEY, RAW','Prod.Bu')
    c.raw.area.clean <- clean(c.raw.area,'CENSUS, RAW','Area.Ac')
    c.raw.prod.clean <- clean(c.raw.prod,'CENSUS, RAW','Prod.Bu')

    s.fill.area.clean <- clean(s.fill.area,'SURVEY, FILL','Area.Ac')
    s.fill.prod.clean <- clean(s.fill.prod,'SURVEY, FILL','Prod.Bu')
    c.fill.area.clean <- clean(c.fill.area,'CENSUS, FILL','Area.Ac')
    c.fill.prod.clean <- clean(c.fill.prod,'CENSUS, FILL','Prod.Bu')

    area <- rbind(s.raw.area.clean,c.raw.area.clean,s.fill.area.clean,c.fill.area.clean)
    prod <- rbind(s.raw.prod.clean,c.raw.prod.clean,s.fill.prod.clean,c.fill.prod.clean)

    df <- merge(area,prod,by=c('Year','GEOID','Program','Crop'),all=T)

    # Calculate yield
    df$Area.Ac <- as.numeric(df$Area.Ac)
    df$Prod.Bu <- as.numeric(df$Prod.Bu)
    df$Yield.BuAc <- df$Prod.Bu / df$Area.Ac

    # Save compiled output
    write.csv(df,final,row.names=F)

} else {
    df <- read.csv(final)
}

# Remove iffy 2019 data
df <- df[df$Year !=2019,]

# Sum, Mean, and StDev for Area, Prod, and Yield (sum is nonsensical)
df.area <- aggregate(Area.Ac~Year+Program, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))
df.prod <- aggregate(Prod.Bu~Year+Program, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))
df.yield <- aggregate(Yield.BuAc~Year+Program, df, FUN=(function(x){c(mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))

write.csv(df.area,'../data/compare_census_survey/output/combined_census_survey_soybeans_stats_area.csv',row.names=F)
write.csv(df.prod,'../data/compare_census_survey/output/combined_census_survey_soybeans_stats_prod.csv',row.names=F)
write.csv(df.yield,'../data/compare_census_survey/output/combined_census_survey_soybeans_stats_yield.csv',row.names=F)

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
