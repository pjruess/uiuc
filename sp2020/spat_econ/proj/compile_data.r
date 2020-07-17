library(reshape2)

crops <- c('corngrain','rice','soybeans','wheat')
crops <- c('corngrain')

# Read in gdp per capita data
gdp <- read.csv('bea/gdp_per_capita_states_chained2012dollars_1997-2018.csv')
gdp <- as.data.frame(sapply(gdp,as.numeric))
row.names(gdp) <- substr(sprintf('%05d',gdp$GeoFips),1,2)
gdp <- gdp[,c(6:24)]
colnames(gdp) <- c('2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018')

# Read in climate data (sum precipitation and mean temperature from PRISM)
clean.clim <- function(df) {
    df <- as.data.frame(sapply(df,as.numeric))
    row.names(df) <- substr(sprintf('%05d',df$GEOID),4,5)
    df <- df[,c(2:20)]
    colnames(df) <- c('2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018')
    return(df)
}
pcp <- clean.clim(read.csv('prism/clean/annual/ppt_2000-2018.csv'))
tmean <- clean.clim(read.csv('prism/clean/annual/tmean_2000-2018.csv'))

for (c in crops){

    print(sprintf('Starting %s',c))

    # Read in agricultural data
    df <- read.csv(sprintf('nass/survey_alldata_%s_state_allyears.csv',c))[,c('Year','State.ANSI','Data.Item','Value')]
    
    # Read in export data
    e <- read.csv(sprintf('ers/ers_%s_state_exports_million_dollars.csv',c))
    
    # Define output
    csv.out <- sprintf('yield_weights/%s_yield_weights.csv',c)
    plot.out <- sprintf('yield_weights/%s_yield_weights.png',c)
    
    # Convert state ansi column to correct format
    df$State.ANSI <- sprintf('%02d',df$State.ANSI)
    
    # convert value to numeric after removing commas
    df$Value <- as.numeric(gsub(',','',df$Value))
    
    # Split up Data.Item column
    df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))

    # Select only years 2000-2018 (restricted by export data) 
    df <- df[df$Year %in% 2000:2018,]

    # Function for matrix creation
    make.mat <- function(df,item){
        df <- df[df$Data.Item2 == item,]
        df <- dcast(df,State.ANSI~Year,value.var='Value')
        df[,-1] <- as.data.frame(sapply(df[,-1],as.numeric))
        df <- df[df$State.ANSI != 'NA',]
        row.names(df) <- df$State.ANSI
        df <- df[,!colnames(df) == 'State.ANSI']
        return(df)
    }
    
    # select out data items and create matrices
    a <- make.mat(df,'ACRES HARVESTED')
    
    if (c == 'rice') {
        # conversions: 1 cwt = 100 lbs = 2.22 bushels
        # conversions from: https://www.omicnet.com/reports/past/archives/ca/tbl-1.pdf
        p <- make.mat(df,'PRODUCTION, MEASURED IN CWT')
        p <- p * 2.22
        y <- make.mat(df,'YIELD, MEASURED IN LB / ACRE')
        y <- y / 100 * 2.22
    } else {
        p <- make.mat(df,'PRODUCTION, MEASURED IN BU')
        y <- make.mat(df,'YIELD, MEASURED IN BU / ACRE')
    }

    p.v <- make.mat(df,'PRODUCTION, MEASURED IN $')

    # Create export matrix
    e <- as.data.frame(sapply(e,as.numeric))
    e$STATEFP <- sprintf('%02d',e$STATEFP)
    row.names(e) <- e$STATEFP
    e <- e[,!colnames(e) %in% c('STATEFP','state')]
    
    # Merge by rownames and unmerge all agricultural data with exports to add missing State.ANSI values
    add.all.states <- function(e,df){
        df <- merge(e,df,by=0,all=T)
        row.names(df) <- df$Row.names
        df <- df[,-(1:20)]
        return(df)
    }
    
    a <- add.all.states(e,a)
    p <- add.all.states(e,p)
    p.v <- add.all.states(e,p.v)
    y <- add.all.states(e,y)
    
    # Change export colnames to match other dataframes
    colnames(e) <- c('2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018')
    
    # Manually calculate yield using production (mass) / acres harvested
    y.c <- as.data.frame( data.matrix(p) / data.matrix(a) )

    # Transform data for merging
    trans <- function(df,cname){
        df <- as.data.frame(t(df))
        df$Year <- rownames(df)
        
        # Melt results for plotting
        df <- melt(df,id='Year')
        colnames(df) <- c('Year','State',cname)
        df$Year <- as.numeric(df$Year)
        return(df)
    }

    a <- trans(a,'Area')
    p <- trans(p,'Production')
    y <- trans(y,'Yield')
    y.c <- trans(y.c,'Yield.Calc')
    e <- trans(e,'Export')
    gdp <- trans(gdp,'GDP.per.Cap')
    pcp <- trans(pcp,'Pcp.sum')
    tmean <- trans(tmean,'T.mean')

    fin <- Reduce(merge, list(a,p,y,y.c,e,gdp,pcp,tmean))

    # Remove states with zero corn yield
    print(length(unique(fin$State)))
    fin <- fin[!(is.na(fin$Yield)),]
    print(length(unique(fin$State)))
    
    # Make squared terms
    fin$Pcp.sum.Sq <- fin$Pcp.sum^2
    fin$T.mean.Sq <- fin$T.mean^2

    # Log Yield term
    fin$Yield.Log <- log(fin$Yield)

    write.csv(fin,'corn_alldata.csv',row.names=F)
    write.csv(fin[fin$Year == '2018',],'corn_alldata_2018.csv',row.names=F)
    break

}
