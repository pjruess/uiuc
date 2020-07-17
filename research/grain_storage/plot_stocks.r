library(ggplot2)
library(data.table)
library(reshape2)

#options(scipen = -999)

# Retrieve FAO total stock data
fao <- read.csv('faostat_stockvariations_usa_allyears.csv')
# Select grains used: barley, maize, oats, oilcrops other (flaxseed & safflower seed), pulses (chickpeas, lentils, and peas... amongst other things that cannot be removed), rape and mustardseed, rye, sorghum, soy, sunflower, and wheat.
fao <- fao[fao$Item.Code %in% c('2513','2514','2516','2570','2911','2558','2515','2518','2555','2557','2511','2549'),]
fao <- fao[, !(names(fao) %in% c('Area.Code','Area','Element.Code','Element','Item.Code','Unit','Description'))]
names(fao) <- gsub('Y','',names(fao))

# Convert 1000 T to Bu for each product
# Conversion data from https://www.agric.gov.ab.ca/app19/calc/crop/bushel2tonne.jsp
#print(fao[,(ncol(fao)-5):ncol(fao)])

#print(fao[,1:5])

### Calculate actual storage for each grain independently
# grain = crop ('Barley and products')
# conv = 1000T to Bu conversion (https://www.agric.gov.ab.ca/app19/calc/crop/bushel2tonne.jsp)
calc_stor <- function(df,grain,conv){
    df <- df[df$Item == grain,sapply(df,is.numeric)]*conv
    df <- melt(df)
    colnames(df) <- c('Year','Stock_Variation_Bu')

    # Calculate actual stocks (cumulative stock variations, assuming zero stock in first year)
    df[nrow(df)+1,] <- c(NA,0)
    df <- within(df, Stock_Cumulative <- cumsum(c(0,head(Stock_Variation_Bu,-1))))
    
    # Add min (neg value) to all df to ensure that all years are > 0
    min_stock <- min(df[,'Stock_Cumulative'])
    df['Stocks.Actual.Bu'] <- df['Stock_Cumulative'] - min_stock
    
    # Clean df dataframe
    df <- df[df$Year %in% c('2002','2007','2012'),]
    df <- df[,c('Year','Stocks.Actual.Bu')]
    df$Item <- rep(grain,nrow(df)) 
    #df <- melt(df,id.vars='Year')[,c(2,1,3)]
    #names(df) <- c('Variable','year','total')
    return(df)
}

# Combine all actual stocks data for 2002, 2007, and 2012
s1 <- calc_stor(fao,'Barley and products',45930.)
s2 <- calc_stor(fao,'Maize and products',39368.)
s3 <- calc_stor(fao,'Oats',64842.)
s4 <- calc_stor(fao,'Oilcrops, Other',39368.) #flax
s5 <- calc_stor(fao,'Pulses',36744.)
s6 <- calc_stor(fao,'Rape and Mustardseed',44092.)
s7 <- calc_stor(fao,'Rye and products',39368.)
s8 <- calc_stor(fao,'Sorghum and products',39368.) #corn
s9 <- calc_stor(fao,'Soyabeans',36744.)
s10 <- calc_stor(fao,'Sunflower seed',73487.)
s11 <- calc_stor(fao,'Wheat and products',36744.)
#s12 <- calc_stor(fao,'Pulses, Other and products',-36744.) # neg to get dif b/w pulses and other prods
stocks <- rbind(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11) #,s12

# Subtract pulses, other from pulses
#print(stocks[stocks$Item=='Pulses',])
#print(stocks[stocks$Item=='Pulses, Other and products',])
#stocks[(stocks$Item=='Pulses')&(stocks$Year=='2002'),'Stocks.Actual.Bu'] <- (stocks[(stocks$Item=='Pulses')&(stocks$Year=='2002'),'Stocks.Actual.Bu'] - stocks[(stocks$Item=='Pulses, Other and products')&(stocks$Year=='2002'),'Stocks.Actual.Bu'])
#stocks[(stocks$Item=='Pulses')&(stocks$Year=='2007'),'Stocks.Actual.Bu'] <- (stocks[(stocks$Item=='Pulses')&(stocks$Year=='2007'),'Stocks.Actual.Bu'] - stocks[(stocks$Item=='Pulses, Other and products')&(stocks$Year=='2007'),'Stocks.Actual.Bu'])
#stocks[(stocks$Item=='Pulses')&(stocks$Year=='2012'),'Stocks.Actual.Bu'] <- (stocks[(stocks$Item=='Pulses')&(stocks$Year=='2012'),'Stocks.Actual.Bu'] - stocks[(stocks$Item=='Pulses, Other and products')&(stocks$Year=='2012'),'Stocks.Actual.Bu'])
#print(stocks[stocks$Item=='Pulses',])
#break

# Retrieve information for VWS calculation for all years
vws_data <- function(res,yr,wtype){

    df <- read.csv(paste(paste('final_results/final',paste(res,yr,sep='_'),sep='_'),'csv',sep='.')) 
    df <- df[, (names(df) %in% c('Commodity','Water.Type','Production_Bu','Harvest_Ac','CWU_gn_m3yr','CWU_bl_m3yr'))]
    # Iterate over all grains and calculate US totals
    res <- data.frame()
    for (grain in unique(df$Commodity)){
        df_rf <- df[(df$Commodity == grain) & (df$Water.Type == 'RAINFED'),]
        df_ir <- df[(df$Commodity == grain) & (df$Water.Type == 'IRRIGATED'),]
        df_rf <- data.frame(grain,yr,'rainfed',sum(df_rf$Production_Bu,na.rm=T),sum(df_rf$Harvest_Ac,na.rm=T),mean(df_rf$CWU_gn_m3yr,na.rm=T),mean(df_rf$CWU_bl_m3yr,na.rm=T))
        names(df_rf) <- c('Item','Year','Water.Type','Production.Bu.Sum','Harvest.Ac.Sum','CWU.gn.m3yr.mean','CWU.bl.m3yr.mean')
        df_ir <- data.frame(grain,yr,'irrigated',sum(df_ir$Production_Bu,na.rm=T),sum(df_ir$Harvest_Ac,na.rm=T),mean(df_ir$CWU_gn_m3yr,na.rm=T),mean(df_ir$CWU_bl_m3yr,na.rm=T))
        names(df_ir) <- c('Item','Year','Water.Type','Production.Bu.Sum','Harvest.Ac.Sum','CWU.gn.m3yr.mean','CWU.bl.m3yr.mean')
        res <- rbind(res,df_rf,df_ir)
    }

    # Calc total harvest fractional area
    #res$Percent.Harvest <- res$Harvest.Ac.Sum / sum(res$Harvest.Ac.Sum) * 100

    # Change commodity names to match stocks
    res$Item <- gsub('CORN,GRAIN','Maize and products',res$Item)
    res$Item <- gsub('CORN,SILAGE','Maize and products',res$Item)
    res$Item <- gsub('FLAXSEED','Oilcrops, Other',res$Item)
    res$Item <- gsub('SAFFLOWER','Oilcrops, Other',res$Item)
    res$Item <- gsub('PEAS,DRYEDIBLE','Pulses',res$Item)
    res$Item <- gsub('PEAS,AUSTRIANWINTER','Pulses',res$Item)
    res$Item <- gsub('LENTILS','Pulses',res$Item)
    res$Item <- gsub('MUSTARD,SEED','Rape and Mustardseed',res$Item)
    res$Item <- gsub('RAPESEED','Rape and Mustardseed',res$Item)
    res$Item <- gsub('CANOLA','Rape and Mustardseed',res$Item)
    res$Item <- gsub('SORGHUM,GRAIN','Sorghum and products',res$Item)
    res$Item <- gsub('SORGHUM,SILAGE','Sorghum and products',res$Item)
    res$Item <- gsub('BARLEY','Barley and products',res$Item)
    res$Item <- gsub('OATS','Oats',res$Item)
    res$Item <- gsub('WHEAT','Wheat and products',res$Item)
    res$Item <- gsub('RYE','Rye and products',res$Item)
    res$Item <- gsub('SOYBEANS','Soyabeans',res$Item)
    res$Item <- gsub('SUNFLOWER','Sunflower seed',res$Item)

    return(res)
}

cnty02 <- vws_data('county','2002','RAINFED')
cnty07 <- vws_data('county','2007','RAINFED')
cnty12 <- vws_data('county','2012','RAINFED')
agstats <- rbind(cnty02,cnty07,cnty12)

# Function for calculating vws of each crop in each year
calc_vws <- function(agstats,stocks){
    df <- merge(agstats,stocks)
    df.agg <- setDT(df)[, .(Harvest.Ac.Total = sum(Harvest.Ac.Sum,na.rm=TRUE)), by = list(Item,Year)]
    df <- merge(df,df.agg)
    df$Percent.Harvest <- df$Harvest.Ac.Sum / df$Harvest.Ac.Total * 100

    df$VWS.rf.m3 <- with(df, ifelse(df$Water.Type=='rainfed',df$Stocks.Actual.Bu / df$Production.Bu.Sum * df$CWU.gn.m3yr.mean * df$Percent.Harvest,NA))
    df$VWS.ir.m3 <- with(df, ifelse(df$Water.Type=='irrigated',df$Stocks.Actual.Bu / df$Production.Bu.Sum * df$CWU.bl.m3yr.mean * df$Percent.Harvest,NA))
    df$VWS.m3 <- rowSums(df[,c('VWS.rf.m3','VWS.ir.m3')], na.rm=TRUE)

    # Groupby to get summary statistics for each year
    df <- setDT(df)[, .(VWS.rf.m3 = sum(VWS.rf.m3,na.rm=TRUE),
                        VWS.ir.m3 = sum(VWS.ir.m3,na.rm=TRUE),
                        VWS.m3 = sum(VWS.m3,na.rm=TRUE)), by = list(Year)]
    return(df)
}

vws <- calc_vws(agstats,stocks)
vws <- melt(vws,id.vars='Year')[,c(2,1,3)]
colnames(vws) <- c('Variable','year','total')

# Re-organize data
#stocks <- colSums(fao[sapply(fao,is.numeric)],na.rm=TRUE)

# Read and re-organize final results data
df <- read.csv( 'final_results/summary.csv' )
df <- melt( df, id.vars = 'Variable' )
df <- with( df, cbind( Variable, colsplit( df$variable, pattern = '\\_', names = c( 'Geography', 'year', 'func' )), value ))
df <- dcast(df, ...~func, value.var = 'value')

# Aggregate data by variable and year, to remove separation of county and state
dt <- setDT(df)[, sum(sum,na.rm=TRUE), by = .(Variable,year)]
colnames(dt)[colnames(dt) == 'V1' ] <- 'total'

# Summarize actual stocks by year
stocks <- setDT(stocks)[, .(Stocks.Actual.Bu = sum(Stocks.Actual.Bu,na.rm=TRUE)), by=list(Year)]
stocks <- melt(stocks,id.vars='Year')[,c(2,1,3)]
colnames(stocks) <- c('Variable','year','total')

# Comine with actual stock data
dt <- rbind(dt,stocks,vws)
#sapply(dt,class)
#print(unique(dt$Variable))

# Filter grain data
grain <- dt[(dt$Variable=='Storage_Bu')|(dt$Variable=='Stocks.Actual.Bu')|(dt$Variable=='Production_Bu'),] 
grain <- data.frame(lapply(grain, function(x) { gsub('Storage_Bu','Storage.Capacity.Bu',x) } ))
grain <- data.frame(lapply(grain, function(x) { gsub('Production_Bu','Production.Bu',x) } ))

# Filter VW data
vw <- dt[(dt$Variable=='VWS_m3')|(dt$Variable=='VWS.m3'),] 
vw <- data.frame(lapply(vw, function(x) { gsub('VWS_m3','VWSC.m3',x) } ))

grain$year <- as.numeric(as.character(grain$year))
grain$total <- as.numeric(as.character(grain$total))
vw$year <- as.numeric(as.character(vw$year))
vw$total <- as.numeric(as.character(vw$total))

print(grain)
#print(vw)
#sapply(grain,class)
#sapply(vw,class)

# Plot total grain stocks
#while (!is.null(dev.list())) dev.off()
#print(grain)
#ggplot(data=grain, aes(x=year)) +
#    geom_line(aes(y='Storage.Capacity.Bu',color='Storage.Capacity.Bu')) #+ 
#    #geom_line(aes(y='Stocks.Actual.Bu',color='Stocks.Actual.Bu')) +
#    #geom_line(aes(y='Production.Bu',color='Production.Bu')) 
#
#ggsave('stocks_grain_plot.png')
#break
library(scales)

ggplot(data=grain, aes(x=year, y=total, color=Variable, group=Variable, shape=Variable)) + 
    geom_point() + geom_line(aes(linetype=Variable)) + 
    scale_x_continuous(breaks=c(2002,2007,2012),minor_breaks=NULL) + 
    scale_y_continuous(labels = scientific) +
    labs(x='Year',y='Mass [Bu]') + #title='Grain Stocks Change Over Time',x='Year',y='Value') + 
    theme(plot.title=element_text(hjust=0.5))
ggsave('stocks_grain_plot.png', width = 7, height = 4.25) # save plot

# Plot VW stocks
ggplot(data=vw, aes(x=year, y=total, color=Variable, group=Variable, shape=Variable)) + 
    geom_point() + geom_line(aes(linetype=Variable)) + 
    scale_x_continuous(breaks=c(2002,2007,2012),minor_breaks=NULL) + 
    scale_y_continuous(labels = scientific) +
    labs(title='Virtual Water Stocks Change Over Time',x='Year',y='Value') + 
    theme(plot.title=element_text(hjust=0.5))
ggsave('stocks_vw_plot.png', width = 7, height = 4.25) # save plot
