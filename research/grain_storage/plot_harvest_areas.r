library(ggplot2)
library(dplyr)
library(RColorBrewer)

perc_harv <- function(geo,year){
    df <- read.csv(sprintf('final_results/final_%s_%s.csv',geo,year))
    if (geo=='state') {
        df <- df[,c('State.ANSI','Commodity','Harvest_Ac')]
    }
    if (geo=='county') {
        df <- df[,c('GEOID','Commodity','Harvest_Ac')]
    }
    df <- df %>%
        group_by(Commodity) %>%
        summarise(count=n()) %>%
        mutate(Percent_Harvest=count/sum(count)*100)

    if (geo=='state') {
        colnames(df)[colnames(df) == 'count' ] <- 'Geo'
        df$Geo <- 'state'
    }

    if (geo=='county') {
        colnames(df)[colnames(df) == 'count' ] <- 'Geo'
        df$Geo <- 'county'
    }

    df$Year <- as.numeric(year)

    return(df)
}

s02 <- perc_harv('state','2002')
s07 <- perc_harv('state','2007')
s12 <- perc_harv('state','2012')
c02 <- perc_harv('county','2002')
c07 <- perc_harv('county','2007')
c12 <- perc_harv('county','2012')



s <- rbind(s02,s07,s12)
s <- s[order(-s$Percent_Harvest),]
print(s[(s$Commodity == 'WHEAT'),],n=Inf)

c <- rbind(c02,c07,c12)
c <- c[order(-c$Percent_Harvest),]
print(c[(c$Commodity == 'WHEAT'),],n=Inf)

# States
colorCount <- length(unique(s$Commodity))
ggplot(data=s, aes(x=Year, y=Percent_Harvest, fill=Commodity)) + 
    geom_area(alpha=1,size=0.5,color='black',position='stack') +
    scale_x_continuous(breaks=c(2002,2007,2012),minor_breaks=NULL) +
    scale_fill_manual(values=colorRampPalette(brewer.pal(n=8,name='Set2'))(colorCount)) +
    labs(x='Year',y='Harvest [%]') 
ggsave('harvest_areas_state_plot.png', width = 7, height = 4.5) # save plot

# Counties
colorCount <- length(unique(c$Commodity))
ggplot(data=c, aes(x=Year, y=Percent_Harvest, fill=Commodity)) + 
    geom_area(alpha=1,size=0.5,color='black',position='stack') +
    scale_x_continuous(breaks=c(2002,2007,2012),minor_breaks=NULL) +
    scale_fill_manual(values=colorRampPalette(brewer.pal(n=8,name='Set2'))(colorCount)) +
    labs(x='Year',y='Harvest [%]') 
ggsave('harvest_areas_county_plot.png', width = 7, height = 4.5) # save plot
