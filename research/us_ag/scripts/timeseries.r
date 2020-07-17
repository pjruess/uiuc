library(ggplot2)
library(glue)

### Regions
df <- read.csv('../data/clean/allcrops_county_census_clean.csv')

# Remove NA from value column
#df <- df[!is.na(df$Value),]

# Sum, Mean, and StDev for Area, Prod, and Yield (sum is nonsensical)
df.area <- aggregate(Area.Ac~Year+Crop, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))#, na.rm=T, na.action=NULL)
df.prod <- aggregate(Prod.Bu~Year+Crop, df, FUN=(function(x){c(sum=sum(x,na.rm=T), mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))#, na.rm=T, na.action=NULL)
df.yield <- aggregate(Yield.BuAc~Year+Crop, df, FUN=(function(x){c(mean=mean(x,na.rm=T), sd=sd(x,na.rm=T))}))#, na.rm=T, na.action=NULL)

print(head(df.area))
print(head(df.prod))
print(head(df.yield))

# NOTE: Include Sweet Rice and Wild Rice with Rice total?
# NOTE: Corn: grain and silage separate or summed?

# Plot time trends
for (d in c('sum','mean','sd')){
    #temp <- df.area[,c('Year','Crop')]
    #temp$Value <- df.area$Area.Ac[,d]

    # Harvested Area
    ggplot(data=df.area,aes(x=Year,y=Area.Ac[,d],color=Crop)) + 
        geom_line(aes(linetype=Crop,color=Crop),lwd=1.5) +
        #geom_point(aes(color=Area)) +
        labs(glue(title='Harvested Area by Crop, {d}'),y=glue('Area.Ac.{d}'))
	ggsave(glue('../plots/trends/area_{d}.png'))

    # Production
    ggplot(data=df.prod,aes(x=Year,y=Prod.Bu[,d],color=Crop)) + 
        geom_line(aes(linetype=Crop,color=Crop),lwd=1.5) +
        #geom_point(aes(color=Area)) +
        labs(glue(title='Production by Crop, {d}'),y=glue('Prod.Bu.{d}'))
	ggsave(glue('../plots/trends/prod_{d}.png'))

    if (d != 'sum') {
        # Yield
        ggplot(data=df.yield,aes(x=Year,y=Yield.BuAc[,d],color=Crop)) + 
            geom_line(aes(linetype=Crop,color=Crop),lwd=1.5) +
            #geom_point(aes(color=Area)) +
            labs(glue(title='Yield by Crop, {d}'),y=glue('Yield.BuAc.{d}'))
	    ggsave(glue('../plots/trends/yield_{d}.png'))
    }

}
