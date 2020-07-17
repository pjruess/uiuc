library(ggplot2)
library(reshape)
library(glue)

file <- '../data/clean/data_available.csv'

if (!file.exists(file)) {

    df <- read.csv('../data/clean/allcrops_county_census_clean.csv')
    
    # Add leading zero to GEOID column
    df$GEOID <- sprintf('%05d', df$GEOID)
    
    # NOTE: Include four groups: 1. value, 2. zero, 3. NA, 4. unreported
    
    # NOTE: Currently using 2999 counties (maximum in USDA data for big 4 grain crops). 
    max <- length(unique(df$GEOID))
    
    # Create results dataframe skeleton
    res <- data.frame(year=numeric(),
                      crop=character(),
                      id=character(),
                      reported=numeric(),
                      unreported=numeric(),
                      unavailable=numeric(),
                      zero=numeric())
    
    for (y in unique(df$Year)) {
        for (c in append( unique(as.character(df$Crop)), 'ALL CROPS' )){
            for (i in c('Area.Ac','Prod.Bu','Yield.BuAc')) {
    
                # Subset df by year and identifier
                temp <- subset(df, Year == y)[,c('Year','GEOID','Crop',i)]
    
                # Subset by crop type
                if (c != 'ALL CROPS') { # select specific crop
                    temp <- subset(temp, Crop == c)
                    temp <- temp[,c('GEOID',i)]
                } else { # aggregate (sum) all crops, ignoring NA
                    temp <- temp[,c('GEOID',i)]
                    temp <- aggregate(.~GEOID, data=temp, FUN=sum, na.rm=T, na.action=na.omit)
                } 
    
                # Count NAs
                na <- nrow(temp[is.na(temp[i]),])
    
                # Remove NA rows
                temp <- temp[!is.na(temp[i]),]
    
                # Count zeros
                z <- nrow(temp[temp[i]==0,])
    
                # Remove zero rows
                temp <- temp[temp[i]!=0,]
    
                # Count data
                d <- nrow(temp)
    
                # Count unreported
                un <- max - na - z - d
    
                # Print updates
                print(paste(y, c, i, d, na, z))
    
                res.temp <- data.frame(year=y,
                                       crop=c,
                                       id=i,
                                       reported=d,
                                       unreported=un,
                                       unavailable=na,
                                       zero=z)
    
                res <- rbind(res,res.temp) 
            }
        }
    }
    
    write.csv(res,file,row.names=F)
} else {
    res <- read.csv(file)
}

for (c in unique(res$crop)) {
    for (i in unique(res$id)) {
        fin <- subset(res, (crop == c) & (id == i))[,c('year','zero','unavailable','unreported','reported')]
        fin <- melt(fin,id.vars='year')

        clab <- gsub(', ','_',c)
        ilab <- gsub('\\.','_',i)

        # Plot result
        ggplot(fin,aes(x=year,y=value,fill=variable)) + 
            geom_bar(position='fill',stat='identity') + 
            labs(title=glue('{ilab}, {clab}'),x='Year',y='Percentage')
        
        ggsave(glue('../plots/data_avail/data_avail_{ilab}_{clab}.png'))
    }
}
