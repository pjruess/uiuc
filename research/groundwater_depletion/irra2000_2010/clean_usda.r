library(data.table)
library(reshape)

df <- read.csv('usdanass_irriharvarea.csv')[,c('Year','State.ANSI','County.ANSI','Value')]

df$Value <- as.numeric(as.character(df$Value))

df$State.ANSI <- formatC(df$State.ANSI, width=2, format='d', flag='0')
df$County.ANSI <- formatC(df$County.ANSI, width=3, format='d', flag='0')
df$GEOID <- paste(df$State.ANSI,df$County.ANSI,sep='')

df <- df[, !names(df) %in% c('State.ANSI','County.ANSI')]

a <- aggregate( list('value'=df$Value), list('Year'=df$Year,'GEOID'=df$GEOID), FUN=sum, na.rm=T)

c <- cast(a,GEOID~Year)

c[is.na(c)] <- 0

write.csv(c,'usda_irri_areas_simplified.csv',row.names=F)
