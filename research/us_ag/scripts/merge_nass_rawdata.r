library(reshape2)

# Check if compiled file exists
comp <- '../data/interim/allcrops_county_census_raw.csv'

if (!file.exists(comp)) {

    # Define empty dataframe to compile all crops
    df <- data.frame()
    
    # Read in all data from rawdata folder
    files <- list.files(path='../data/raw/',pattern='*.csv',full.names=T,recursive=F)
    for (data in files) {
        print(data)
        temp <- read.csv(data)
        df <- rbind(df,temp)
    }
    
    # Save compiled output
    write.csv(df,comp,row.names=F)

} else {
    df <- read.csv(comp)
}

# Check if compiled file exists
final <- '../data/clean/allcrops_county_census_clean.csv'

if(!file.exists(final)){

    # Fix AK counties (GEOID)
    df[(df$State == 'ALASKA') & (df$County == 'ANCHORAGE'),]$County.ANSI <- 20
    df[(df$State == 'ALASKA') & (df$County == 'FAIRBANKS NORTH STAR'),]$County.ANSI <- 90
    
    # No grains grown in below counties; important for other crops
    #df[(df$State == 'ALASKA') & (df$County == 'JUNEAU'),]$County.ANSI <- 110
    #df[(df$State == 'ALASKA') & (df$County == 'KENAI PENINSULA'),]$County.ANSI <- 122
    #df[(df$State == 'ALASKA') & (df$County == 'ALEUTIANS ISLANDS'),]$County.ANSI <- 16 # note this is the GEOID for aleutians west; east is 13 but don't want to duplicate in statistical analysis
    
    # Reclassify redacted values as NA
    df$Value <- as.numeric(as.character(gsub(',','',df$Value)))
    
    # Define GEOID column
    df$GEOID <- paste( sprintf('%02d', df$State.ANSI), sprintf('%03d', df$County.ANSI), sep='' )
    
    # Redefine commodity column to include details (ie. 'Corn, Grain', etc.)
    df <- as.data.frame(unlist(lapply(df,data.table::tstrsplit,' - '),recursive=F))
    
    # Select specific columns
    df <- df[,c('Year','GEOID','Data.Item1','Data.Item2','Value')]
    
    # Reorganize harvest and production to columns
    df <- dcast(df,...~Data.Item2, value.var='Value')
    
    df[,c(4:7)] <- sapply(df[,c(4:7)],as.numeric)
    
    # Silage (CORN & SORGHUM): 1 TON = 8 BU
    # CWT (RICE): 1 CWT = 2.22 BU
    df['PRODUCTION, MEASURED IN TONS'] <- df['PRODUCTION, MEASURED IN TONS'] * 8
    df['PRODUCTION, MEASURED IN CWT'] <- df['PRODUCTION, MEASURED IN CWT'] * 2.22
    df['PRODUCTION'] <- rowSums(df[,c('PRODUCTION, MEASURED IN BU','PRODUCTION, MEASURED IN TONS','PRODUCTION, MEASURED IN CWT')],na.rm=T)
    df[is.na(df['PRODUCTION, MEASURED IN BU']) & is.na(df['PRODUCTION, MEASURED IN TONS']) & is.na(df['PRODUCTION, MEASURED IN CWT']), 'PRODUCTION'] <- NA
    df <- df[,c('Year','GEOID','Data.Item1','ACRES HARVESTED','PRODUCTION')]
    colnames(df) <- c('Year','GEOID','Crop','Area.Ac','Prod.Bu')
    
    # Calculate yield
    df$Yield.BuAc <- df$Prod.Bu / df$Area.Ac

    # Save final output
    write.csv(df,final,row.names=F)

} else {
    break
}
