

library(rio) # for reading xlsx
library(stringr) # for strsplit

### PRODUCTION DATA

# Read in National SCTG5 Production data for 2017
prod <- data.frame(import_list('MeatStatsFull.xlsx')['SlaughterWeights-Full']) # read SlaughterWeights-Full sheet
names(prod) <- as.matrix(prod[1,]) # name headers after first row
prod <- prod[-1,] # remove first row
prod <- prod[,-c(2:13,16)] # select 'Federally inspected average dressed weight (lbs)'
names(prod) <- as.matrix(prod[1,]) # name headers after first row
names(prod)[1] <- 'Date' # change name of first column to 'Date'
prod <- prod[-1,] # remove first row
prod[,-1] <- sapply(prod[,-1],as.numeric) # convert all production data to numeric
prod$Total <- rowSums(prod[,-1])

# Aggregate by year
prod <- prod[-c(1,2),] # remove first two rows (aggregated monthly data for Jan-Mar 2020 and 2019)
prod$Year <- data.frame(do.call(rbind,strsplit(as.character(prod$Date),'-',fixed=T)))[,2] # Separate years from months
prod <- prod[,-1] # remove date column
prod <- aggregate(.~Year,data=prod,FUN=sum) # aggregate all columns by year

### PUMA BUTCHER POPULATION DATA
# RCA is Revealed Comparative Advantage. Details here... https://datausa.io/about/glossary/
# In this case, RCA is People (Butchers and other Meat, Poultry, Fish Processors) in Workforce
puma <- read.csv('Spatial Concentration/Spatial Concentration.csv')
puma <- puma[puma$Year == 2017,] # select only 2017 data
puma$id <- substr(puma$ID.PUMA,8,14) # select relevant portion of PUMA id
puma <- puma[,c('id','ygopop.RCA')] # select only relevant columns
puma <- puma[order(puma$id),]

### CROSSWALK: PUMA TO COUNTY NOTE: this uses 2016 pop estimates based on 2012 pop. CAN CHANGE LATER.
p2c <- read.csv('geocorr2018.csv')
p2c <- p2c[-1,]
p2c$id <- paste0(p2c$state,p2c$puma12)
p2c <- p2c[,c('id','county','afact')]
names(p2c) <- c('id','geoid','afact')

### MERGE CROSSWALK WITH PUMA DATA TO GET COUNTY PUMA BUTCHER POPULATIONS
df <- merge(puma,p2c,by='id')
df$afact <- as.numeric(as.character(df$afact))
df$process <- df$ygopop.RCA * df$afact # PUMA production associated with each county
df$process.pct <- df$process / sum(df$process) # PUMA production PERCENTAGE for each county
df$prod <- df$process.pct * prod[prod$Year==2017,'Total']
df <- df[,c('geoid','process','process.pct','prod')] 

### CROSSWALK: COUNTY TO FAF
c2f <- data.frame(import_list('cfs-area-lookup-2007-and-2012.xlsx')['CFS Areas'])
names(c2f) <- as.matrix(c2f[1,]) # name headers after first row
c2f <- c2f[-1,c(1,2,8)] # remove first row and unused columns
names(c2f) <- c('state','county','cfs')
c2f <- data.frame(sapply(c2f,as.numeric))
c2f$geoid <- paste0( sprintf('%02d',c2f$state), sprintf('%03d',c2f$county) )
c2f <- c2f[,c('geoid','cfs')]

### MERGE CROSSWALK WITH COUNTY BUTCHER POPULATIONS AND AGGREGATE TO FAF ZONES
df <- merge(df,c2f,by='geoid')
df <- aggregate(prod~cfs,data=df,FUN=sum) # aggregate production by cfs

# Write output
write.csv(df,'../data_clean/production/faf_production_sctg5_lbs_2017.csv')






