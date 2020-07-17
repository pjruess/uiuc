library(data.table)
library(reshape)

df <- read.csv('usda_irriharvarea_states.csv')

print(unique(df$Data.Item))

df <- df[,c('Year','State.ANSI','Value')]

df$Value <- as.numeric(as.character(gsub(',','',df$Value)))

df$Value <- df$Value / 2.471

df$State.ANSI <- formatC(df$State.ANSI, width=2, format='d', flag='0')

a <- aggregate(list('value'=df$Value), list('Year'=df$Year,'State.ANSI'=df$State.ANSI), FUN=sum, na.rm=T)

c <- cast(a,State.ANSI~Year)

c[is.na(c)] <- 0

write.csv(c,'usda_irri_areas_states_simplified.csv',row.names=F)
