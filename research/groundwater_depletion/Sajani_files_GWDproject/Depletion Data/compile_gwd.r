library(reshape2)
library(stringi)

# Control scientific notation
#options(scipen=-999) # -999 for scientific notation, 999 for non-scientific notation

# Read GWD data
gwd.00 <- read.csv('GWD/GWD_Counties_US_2000.csv')[,c(6,14:39)]
gwd.10 <- read.csv('GWD/GWD_Counties_US_2010.csv')[,c(6,14:39)]

clean <- function(df) {
    df <- melt(df,id.vars='GEOID')
    colnames(df) <- c('geoid','mirca','gwd')
    df$geoid <- formatC(df$geoid,width=5,format='d',flag='0')
    df$mirca <- substr(df$mirca,7,8)
    df$mirca <- as.numeric(df$mirca)
    df$sctg <- ifelse(df$mirca %in% c(1:7), 2, ifelse(df$mirca %in% c(8:10,12,13,15:18,21,24,26), 3, ifelse(df$mirca %in% c(25), 4, NA))) 
    df <- aggregate(gwd~geoid+sctg,df,sum)
    df <- dcast(df,geoid ~ sctg)
    colnames(df) <- c('geoid','sctg2','sctg3','sctg4')
    df$total <- df$sctg2 + df$sctg3 + df$sctg4
    return(df)
}

gwd.00 <- clean(gwd.00)
gwd.00$year <- 2000
gwd.10 <- clean(gwd.10)
gwd.10$year <- 2010
gwd <- rbind(gwd.00,gwd.10)
gwd <- gwd[,c(6,1,2,3,4,5)]
write.csv(gwd,'gwd.csv',row.names=F)
