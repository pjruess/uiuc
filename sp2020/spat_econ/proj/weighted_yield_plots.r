library(reshape2)
library(ggplot2)

crops <- c('corngrain','rice','soybeans','wheat')

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
    
    # Function for matrix creation
    make.mat <- function(df,item){
        df <- df[df$Data.Item2 == item,]
        df <- dcast(df,State.ANSI~Year,value.var='Value')
        df[,-1] <- as.data.frame(sapply(df[,-1],as.numeric))
        df <- df[df$State.ANSI != 'NA',]
        row.names(df) <- df$State.ANSI
        df <- df[,!colnames(df) == 'State.ANSI']
        #m <- data.matrix(df)
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
        #m <- data.matrix(df)
        return(df)
    }
    
    a <- add.all.states(e,a)
    p <- add.all.states(e,p)
    p.v <- add.all.states(e,p.v)
    y <- add.all.states(e,y)
    
    # Change export colnames to match other dataframes
    colnames(e) <- c('2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018')
    #e <- data.matrix(e)
    
    # Manually calculate yield using production (mass) / acres harvested
    y.c <- as.data.frame( data.matrix(p) / data.matrix(a) )
    #print(dim(a))
    #print(dim(p))
    #print(dim(p.v))
    #print(dim(y))
    
    # Manually calculate yield using production (value) / acres harvested
    #y.v.c <- as.data.frame( data.matrix(p.v) / data.matrix(a) )
    
    # Function for calculating shares matrix (fractional contribution of each state (row) to each year (col)
    # Basically sum up column and divide each row by that column's sum
    calc.perc <- function(df){
        for (c in names(df)){
            df[c] <- df[c] / sum(df[c],na.rm=T)
        }
        return(df)
    }
    
    a.pc <- calc.perc(a)
    p.pc <- calc.perc(p)
    e.pc <- calc.perc(e)
    
    # Function for calculating weighted yield
    # NOTE: I'm using calculated yield because it's more precise
    # NOTE: NA or zero? Need to NOT average over zeros. 
    weight.yield <- function(y,w,rname) {
        df <- as.data.frame( data.matrix(y) * data.matrix(w) )
        df[rname,] <- colMeans(df,na.rm=T) * 100
        return(df)
    }
    
    y.c.a.w <- weight.yield(y.c,a.pc,'Area.Weighted')
    y.c.p.w <- weight.yield(y.c,p.pc,'Production.Weighted')
    y.c.e.w <- weight.yield(y.c[,colnames(e.pc)],e.pc,'Export.Weighted') # subset relevant years
    
    # Add empty year columns to export dataframe
    for (y in setdiff(colnames(y.c),colnames(e.pc))){
        y.c.e.w[,y] <- NA
    }
    y.c.e.w <- y.c.e.w[,order(colnames(y.c.e.w))]
    
    y.c['Unweighted',] <- colMeans(y.c,na.rm=T)
    
    fin <- rbind(y.c.a.w['Area.Weighted',],y.c.e.w['Production.Weighted',])
    fin <- rbind(fin,y.c.e.w['Export.Weighted',])
    fin <- rbind(fin,y.c['Unweighted',])
    
    fin <- as.data.frame(t(fin))
    fin$Year <- rownames(fin)
    
    write.csv(fin,csv.out,row.names=F)
    
    # Melt results for plotting
    fin <- melt(fin,id='Year')
    colnames(fin) <- c('Year','Weight','Yield')
    fin$Year <- as.numeric(fin$Year)
    
    # Plot results
    #f <- function(k) {
    #    step <- k
    #    function(y) seq(floor(min(y)),ceiling(max(y)),by=step)
    #}

    ggplot(data=fin,aes(x=Year,y=Yield,color=Weight,group=Weight)) + 
            geom_line(aes(color=Weight),lwd=1) + #linetype=Weight
            scale_x_continuous(breaks=seq(1865,2015,10)) +
            #scale_x_continuous(breaks=seq(1925,2015,5)) +
            theme(axis.text.x = element_text(angle=90)) +
            #geom_point(aes(color=Area)) +
            labs(title=sprintf('US Averaged State Weighted Yields, %s',c))
    
    ggsave(plot.out)

    print(sprintf('Finished %s',c))

}
