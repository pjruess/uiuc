# Causal Effect of Trade Openness on Agricultural Variables
# Akshay Pandit & Paul J. Ruess
# Spring 2019

# Load necessary libraries
library(reshape2)
library(data.table)
library(dplyr)
library(gtools)
library(glue)

### Preparing stage 0 file

# Specify years to include
years <- 2000:2010

# Read in ISO codes
iso <- read.csv(file = 'rawdata/wikipedia-iso-country-codes.csv')

### Read in all data

# Read in Distance between countries
dist.path <- 'cleandata/2000_2010/dist_cepii.csv'
if (!file.exists(dist.path)) {
    print(glue('Creating file: {dist.path}'))
    dist <- readxl::read_xls('rawdata/dist_cepii.xls')[,c('iso_o','iso_d','contig','dist', 'distcap')]
    write.csv(dist,dist.path,row.names=FALSE) #save cleaned version
} else {
    print(glue('Reading file: {dist.path}'))
    dist <- read.csv(dist.path)
}

# Read in Geometric Variables (Latitude, Longitude, area, dummy variables, etc.)
geo.path <- 'cleandata/2000_2010/geo_cepii.csv'
if (!file.exists(geo.path)) {
    print(glue('Creating file: {geo.path}'))
    geo <- readxl::read_xls('rawdata/geo_cepii.xls')[,c('country','iso3','area','dis_int', 'lat', 'lon','landlocked')]
    write.csv(geo,geo.path,row.names=FALSE) #save cleaned version
} else {
    print(glue('Reading file: {geo.path}'))
    geo <- read.csv(geo.path)
}

# Read in Capital Stocks at Current PPPs (2011)
ck.path <- 'cleandata/2000_2010/pwt90.csv'
if (!file.exists(ck.path)) {
    print(glue('Creating file: {ck.path}'))
    ck <- readxl::read_xlsx('rawdata/pwt90.xlsx',sheet=3)[,c('countrycode','country','year','ck')]
    write.csv(ck,ck.path,row.names=FALSE) #save cleaned version
} else {
    print(glue('Reading file: {ck.path}'))
    ck <- read.csv(ck.path)
}

# Read in Population data (convert from thousand to single)...
pop.path <- 'cleandata/2000_2010/population.csv'
if (!file.exists(pop.path)) {
    print(glue('Creating file: {pop.path}'))
    pop <- readxl::read_xlsx('rawdata/WPP2017_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx', sheet = 1)
    pop <- pop[,!names(pop) %in% c('Index', 'Variant', 'Notes')]
    pop <- melt(pop, id.vars=c('Region, subregion, country or area *','Country code'), variable.name='Year', value.name='Population')
    pop <- merge(iso[,3:4],pop,by.x="Numeric.code",by.y="Country code")
    names(pop)[names(pop)=="Alpha.3.code"] <- 'iso'
    pop$Population<-pop$Population*1000
    write.csv(pop,pop.path,row.names=FALSE) #save cleaned version
} else {
    print(glue('Reading file: {pop.path}'))
    pop <- read.csv(pop.path)
}

#Read in Export and Import to Calculate Real Trade Openness (Import and Export data are % of GDP)
to.path <- 'cleandata/2000_2010/trade_openness.csv'
if (!file.exists(to.path)) {
    print(glue('Creating file: {to.path}'))
    
    # Read in export data 
    exp.path <- 'cleandata/2000_2010/exports.csv'
    if (!file.exists(exp.path)) {
        print(glue('Creating file: {exp.path}'))
        exp <- read.csv('rawdata/Exports_world_bank.csv')
        names(exp) <- gsub('X','',names(exp))
        exp <- melt(exp, id.vars=c('CountryName','CountryCode'), variable.name='Year', value.name='Exports')
        write.csv(exp,exp.path,row.names=FALSE) #save cleaned version
    } else {
        print(glue('Reading file: {exp.path}'))
        exp <- read.csv(exp.path)
    }

    # Read in import data
    imp.path <- 'cleandata/2000_2010/imports.csv'
    if (!file.exists(imp.path)) {
        print(glue('Creating file: {imp.path}'))
        imp <- read.csv('rawdata/Imports_world_bank.csv')
        names(imp) <- gsub('X','',names(imp))
        imp <- melt(imp, id.vars= c('CountryName','CountryCode'), variable.name='Year', value.name='Imports')
        write.csv(imp,imp.path,row.names=FALSE) #save cleaned version
    } else {
        print(glue('Reading file: {imp.path}'))
        imp <- read.csv(imp.path)
    }

    # Calculate trade openness
    to <- merge(exp,imp,by=c("CountryName","CountryCode", 'Year'))
    to$TO <- (to[,4]+to[,5])/100
    to <- to[,!names(to) %in% c('Exports', 'Imports')]
    write.csv(to,to.path,row.names=FALSE) #save cleaned version
} else {
    print(glue('Reading file: {to.path}'))
    to <- read.csv(to.path)
}

# Read in climate data
clean.climate <- function(path,variable) {
    path <- 'rawdata/Temperature'
    files <- list.files(path=path,pattern= "*.csv")
    files <- lapply(files, function(x) paste(path,x,sep='/')) #list of file names
    df <- do.call(rbind, lapply(files, function(x) read.csv(x, stringsAsFactors = FALSE)))
    names(df) <- sub('X.','',names(df))
    df <- aggregate(x=df$tas,by=list(df$Country,df$Year),FUN='mean')
    colnames(df) <- c('Country_iso','Year',variable)
    return(df)
}

# Temperature data
temp.path <- 'cleandata/2000_2010/temperature.csv'
if (!file.exists(temp.path)) {
    print(glue('Creating file: {temp.path}'))
    temp <- clean.climate('rawdata/Temperature','Temperature')
    write.csv(temp,temp.path,row.names=FALSE)
} else {
    print(glue('Reading file: {temp.path}'))
    temp <- read.csv(temp.path)
}

# Rainfall data
rf.path <- 'cleandata/2000_2010/rainfall.csv'
if (!file.exists(rf.path)) {
    print(glue('Creating file: {rf.path}'))
    rf <- clean.climate('rawdata/Rainfall','Rainfall')
    write.csv(rf,rf.path,row.names=FALSE)
} else {
    print(glue('Reading file: {rf.path}'))
    rf <- read.csv(rf.path)
}

# Read in wto data
wto.path <- 'cleandata/2000_2010/wto.csv'
if (!file.exists(wto.path)) {
    print(glue('Creating file: {wto.path}'))
    wto <- read.csv(file = "rawdata/wto.csv")
    wto <- wto[c(1,4:5)]
    wto.2 <- data.frame(iso_o = rep (wto$ISO, each = nrow(wto)), iso_d = rep (wto$ISO, times = nrow(wto)), Year_o = rep(wto$Year, each = nrow(wto)), Year_d = rep (wto$Year, times = nrow(wto)))
    wto.2 <- wto.2[rep(seq_len(nrow(wto.2)), each = length(years)),]
    wto.2 <- cbind(wto.2, Year_m = rep(years, times = nrow(wto)*nrow(wto)))
    wto.2<- wto.2 %>%   mutate(wto_o = ifelse(Year_m >= Year_o, 1, 0), wto_d = ifelse(Year_m >= Year_d, 1, 0))
    wto.2 <- subset(wto.2, select = -c(Year_o, Year_d))
    setnames(wto.2, old = "Year_m", new = "Year")
    wto <-wto.2
    write.csv(wto,wto.path,row.names=FALSE)
} else {
    print(glue('Reading file: {wto.path}'))
    wto <- read.csv(wto.path)
}

# Read in rta data
rta.path <- 'rawdata/rta.csv'
print(glue('Reading file: {rta.path}'))
rta <- read.csv(rta.path) # NOTE: is this Qian's data or our cleaned version?

# Calculate bilateral trade from geographic variables and time-variant panel variables (constructed trade openness) 
biopen.path <- 'rawdata/bitrade.csv'
if (!file.exists(biopen.path)) {
    print(glue('Creating file: {biopen.path}'))
    #Read Bilateral trade data
    # bi_trade<-read.table(file = 'rawdata/DOT_03-01-2019 14-24-34-36_timeSeries/DOT_03-01-2019 14-24-34-36_timeSeries.csv',header = T ,sep = ',',stringsAsFactors = FALSE,na.strings=c("","e"," ","NA"),strip.white = T)
    # bi_trade<-bi_trade[!(bi_trade$Indicator.Name=='Goods, Value of Trade Balance, US Dollars'),]
    # IMF_codes<-read.csv('rawdata/IMF_codes.csv')#IMF list
    # setnames(IMF_codes, old = c("English.short.name.lower.case","Alpha.3.code","Counterpart.Country.Code"), new = c('Country.Name','ISO.Code','IMF.Code'))
    # bi_trade<-merge(bi_trade,IMF_codes[c(2:3)],by.y="IMF.Code",by.x ="Country.Code")
    # bi_trade<-merge(bi_trade,IMF_codes[c(2:3)],by.y="IMF.Code",by.x="Counterpart.Country.Code")
    # setnames(bi_trade, old = c("ISO.Code.y","ISO.Code.x"), new = c("Counterpart.Country.Code","Country.Code"))
    # bi_trade <- bi_trade[-c(1:2)]
    # colnames(bi_trade)[1]<-'Country.Name'
    # bi_trade<-bi_trade[,!names(bi_trade) %in% c('Attribute')]
    # bi_trade <- bi_trade[c(76:77,1:75)]
    # bi_trade <- bi_trade[-c(7:38,74:77)]
    # bi_trade <- bi_trade[!duplicated(bi_trade),]
    # # bi_trade[bi_trade == 'e'] <- 0
    # bi_trade[7:41] <-sapply(bi_trade[7:41],as.double)
    # bi_trade<-subset(bi_trade, select = -c(Country.Name, Indicator.Code, Counterpart.Country.Name))
    # setnames(bi_trade, old = c("Country.Code", "Counterpart.Country.Code"), new = c("Country_ISO","Counterpart_ISO"))
    # 
    # bi_trade <- reshape(bi_trade, varying = 4:38, sep = "", direction = "long" )
    # bi_trade <- subset(bi_trade, select = -c(id))
    # setnames(bi_trade, old = c("time"), new = c("Year"))
    # bi_trade$X[as.integer(as.character(bi_trade$Year)) >= 2000 & is.na(bi_trade$X)] = 0
    # bi_trade <- na.omit(bi_trade)
    # 
    # bi_trade <- bi_trade[which(bi_trade$Indicator.Name != "Goods, Value of Imports, Cost, Insurance, Freight (CIF), US Dollars"),]
    # # bi_trade <- melt(bi_trade, id.vars= c('Country.Name', 'Country.Code' ,'Indicator.Name','Indicator.Code', 'Counterpart.Country.Name','Counterpart.Country.Code'), variable.name='Year', value.name='X')
    # bi_trade <- bi_trade %>% group_by(Country_ISO,Counterpart_ISO, Indicator.Name, Year) %>% summarize(X = max(X))
    # export <- bi_trade[which(bi_trade$Indicator.Name == "Goods, Value of Exports, Free on board (FOB), US Dollars"),]
    # export <- subset(export, select = -c(Indicator.Name))
    # colnames(export) <- c("Country_ISO", "Counterpart_ISO", "Year", "Export")
    # import<-export
    # colnames(import) <- c("Counterpart_ISO","Country_ISO", "Year", "Import")
    # # export <- export %>% group_by(Country_ISO,Counterpart_ISO, Year) %>% summarize(Export = max(Export))
    # # import <- import %>% group_by(Counterpart_ISO, Country_ISO, Year) %>% summarize(Import = max(Import))
    # bi_trade <- merge(export, import, by = c("Country_ISO","Counterpart_ISO", "Year"))
    # bi_trade$Trade <- bi_trade$Export + bi_trade$Import
    # # bi_trade <- bi_trade[which(bi_trade$Trade !=0),]
    # 
    # ############Reading GDP (in US$) data #####################
    # GDP<-read.csv('rawdata/GDP_world_bank.csv')
    # names(GDP)<-gsub('X','',names(GDP))
    # #GDP<-GDP[-c(3:44,60)]
    # GDP<- melt(GDP, id.vars= c('Country.Name' ,'Country.Code'), variable.name='Year', value.name='GDP')
    # GDP<-na.omit(GDP)
    # GDP<-GDP[which(GDP$GDP!=0),]
    # biopen<-merge(bi_trade,GDP[c(2:4)],by.x=c('Country_ISO','Year'),by.y=c('Country.Code','Year'))
    # biopen$biopenness<-biopen$Trade/biopen$GDP
    # biopen <- subset(biopen, select = -c(Export, Import, Trade, GDP))
    # write.csv(biopen,"cleandata/2000_2010/bi_trade.csv", row.names = F)
    # biopen <- read.csv("cleandata/2000_2010/bi_trade.csv")
} else {
    print(glue('Reading file: {biopen.path}'))
    biopen <- read.csv(biopen.path) # Read in clean bilateral trade data
}

### Stage 0 Dataframe
st0.path <- 'results/2000_2010/input_data_clean_stage0.csv'
if (!file.exists(st0.path)) {
    print(glue('Creating file: {st0.path}'))

    # Initiate Stage 0 Dataframe
    st0.t <- iso[c(1,3)]
    st0.2 <- st0.t[rep(seq_len(nrow(iso)), each = nrow(iso)),]
    st0.3 <- st0.t[rep(seq_len(nrow(iso)), times = nrow(iso)),]
    st0.2$English.short.name.lower.case <- NULL
    st0.2$iso_d <- st0.3$Alpha.3.code
    names(st0.2)[1] <- 'iso_o'
    st0 <- st0.2[rep(seq_len(nrow(st0.2)), times = length(years)),]
    st0$year <- rep(years, each = nrow(st0.t)*nrow(st0.t))
    st0 <- st0[st0$iso_d!=st0$iso_o,]

    # Add origin geographic
    st0 <- merge(st0,geo[c(2:3,7)],by.x=c("iso_o"),by.y=c("iso3"))
    setnames(st0, old = c('area','landlocked'), new = c('area_o','landlocked_o'))
    
    # Add destination geographic
    st0 <- merge(st0,geo[c(2:3,7)],by.x=c("iso_d"),by.y=c("iso3"))
    setnames(st0, old = c('area','landlocked'), new = c('area_d','landlocked_d'))
    
    # Add distance
    st0 <- merge(st0,dist,by.x=c("iso_o","iso_d"),by.y=c("iso_o","iso_d"))
    
    # Add origin population
    st0 <- merge(st0,pop[c(2,4:5)],by.x=c("iso_o","year"),by.y=c("iso",'Year'))
    names(st0)[colnames(st0) == 'Population']<-'pop_o'
    
    # Add destination population
    st0 <- merge(st0,pop[c(2,4:5)],by.x=c("iso_d","year"),by.y=c("iso",'Year'))
    names(st0)[colnames(st0) == 'Population']<-'pop_d'
    
    # Add bilateral trade
    st0 <- merge(st0, biopen, by.x=c('iso_o','iso_d','year'),by.y =c('iso_o','iso_d','Year'), all.x = T)
    
    # Add world trade organization membership
    st0 <- merge(st0,wto,by.x=c("iso_o","iso_d","year"),by.y=c("iso_o","iso_d","Year"), all.x = TRUE)
    
    # Add regional trade agreements
    st0 <- merge(st0,rta,by.x=c("iso_o","iso_d","year"),by.y=c("iso_o","iso_d",'Year'), all.x = TRUE)
    
    # Clean data
    st0$wto_o[is.na(st0$wto_o)] <- 0
    st0$wto_d[is.na(st0$wto_d)] <- 0
    st0$rta[is.na(st0$rta)] <- 0
    st0 <- unique(st0)

    # Save Stage 0 clean data
    write.csv(st0,st0.path,row.names=FALSE)

} else {
    print(glue('Reading file: {st0.path}'))
    st0 <- read.csv(st0.path)
}

### Stage 1 Dataframe
st1.path <- 'results/2000_2010/input_data_clean_stage_control.csv'
if (!file.exists(st1.path)) {
    print(glue('Creating file: {st1.path}'))
    
    # Initiate Stage 1 Dataframe
    st1 <- iso[c(1,3)]
    st1.2 <- st1[rep(seq_len(nrow(st1)), each = length(years)),]
    st1.2$year <- rep(years, times = nrow(st1))
    st1.2 <- st1.2[-1]
    setnames(st1.2, old = c('year','Alpha.3.code'), new = c('Year','ISO'))
    
    # Add population
    st1.2 <- merge(st1.2,pop[c(2,4:5)],by.x=c("ISO","Year"), by.y = c("iso","Year"))
    
    # Add geographic
    st1.2 <- merge(st1.2,geo[c(2:3)],by.x=c("ISO"),by.y=c("iso3"))
    
    # Add trade openness
    st1.2 <- merge(st1.2,to[c(2:4)],by.x=c("ISO","Year"),by.y=c("CountryCode",'Year'))
    
    # Add capital stock at current PPPs (in mil. 2011 US$) NOTE: should this be adjusted to 2016 US$?
    st1.2 <- merge(st1.2, ck[c(1,3:4)], by.x=c("ISO","Year"), by.y=c("countrycode",'year'),all=TRUE)
    st1.2$lperP <- st1.2$area/st1.2$Population # area per population
    st1.2$ckperP <- st1.2$ck/st1.2$Population # capital stock per population
    st1.2 <- na.omit(st1.2)
    
    # Add temperature
    st1.2 <- merge(st1.2,temp,by.x=c("ISO","Year"),by.y=c("Country_iso",'Year'))
    
    # Add rainfall
    st1.2 <- merge(st1.2,rf,by.x=c("ISO","Year"),by.y=c("Country_iso",'Year'))
    
    # Clean data
    st1.2 <- subset(st1.2,select = -c(TO)) # NOTE: Why remove trade openness? Why is it added earlier?
    #st1.2 = st1.2[st1.2$ISO != "LBR" ,]
    #st1.2 = st1.2[st1.2$ISO != "LUX" ,]
    
    # Save Stage 1 clean data
    write.csv(st1.2,st1.path,row.names = FALSE)

} else {
    print(glue('Reading file: {st1.path}'))
    st1 <- read.csv(st1.path)
}

### Dependent variable: Groundwater Depletion (GWD)
st2.path <- 'results/2000_2010/input_data_clean_stage_gwd.csv'
if (!file.exists(st2.path)) {
    print(glue('Creating file: {st2.path}'))

    # Merge other variables for final dataset
    out_vars <- iso[c(1,3)]
    out_vars_2 <- out_vars[rep(seq_len(nrow(out_vars)), each = length(years)),]
    out_vars_2$year <- rep(years, times = nrow(out_vars))
    out_vars_2 <- out_vars_2[-1]
    setnames(out_vars_2, old = c('year','Alpha.3.code'), new = c('Year','ISO'))
    out_vars_2 <- merge(out_vars_2,pop[c(2,4:5)],by.x=c("ISO","Year"),by.y=c("iso",'Year'))
    out_vars_2 <- merge(out_vars_2,geo[c(2:3)],by.x=c("ISO"),by.y=c("iso3"))
    
    # Read in groundwater data
    gwd.path <- 'cleandata/2000_2010/gwd.csv'
    if (!file.exists(gwd.path)){
        print(glue('Creating file: {gwd.path}'))
    
        # Initiate empty dataframe
        gwd <- data.frame()
    
        # Iterate through years and add GWD
        for (y in years) {
    
            gwd.temp <- data.frame(ISO=character(),
                              GWD=character(),
                              Crop=character())

            for (f.path in list.files(glue('rawdata/gwd_csv/{y}'))) {
                print(f.path)
                crop <- unlist(strsplit(f.path,'_'))[1]
                df <- read.csv(glue('rawdata/gwd_csv/{y}/{f.path}'))[,c('ISO3','sum')]
                df$Crop <- crop
                colnames(df) <- c('ISO','GWD','Crop')
                df <- df[df$GWD != 'None',]
                gwd.temp <- rbind(gwd.temp,df)
            }
            gwd.vals <- dcast(gwd.temp,ISO~Crop,value.var='GWD')
            gwd.vals$Year <- y
            gwd <- rbind(gwd,gwd.vals)
        }
    
        write.csv(gwd,gwd.path,row.names=FALSE)
    
    } else {
        print(glue('Reading file: {gwd.path}'))
        gwd <- read.csv(gwd.path)
    }
    
    out_vars_2 <- merge(out_vars_2,gwd,by=c("ISO","Year"))
    out_vars_2 <- merge(out_vars_2,to[c(2:4)],by.x=c("ISO","Year"),by.y=c("CountryCode",'Year'))
    out_vars_2 <- out_vars_2[-c(3:4)]
    #out_vars_2 <- out_vars_2[out_vars_2$ISO != "LBR" ,]
    #out_vars_2 <- out_vars_2[out_vars_2$ISO != "LUX" ,]
    
    # Save Stage 2 dependent variables
    write.csv(out_vars_2,st2.path,row.names = FALSE)
    print('Script finished')
} else {
    print('Script finished')
}
