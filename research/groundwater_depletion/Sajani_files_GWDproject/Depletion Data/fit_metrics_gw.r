library(Metrics)

# Clean GWA
clean.gwa <- function(df) {
    colnames(df) <- c('FIPS','GWA')
    df$FIPS <- formatC(df$FIPS,width=5,format='d',flag='0')
    df$GWA <- as.numeric(as.character(df$GWA))
    df$GWA[is.na(df$GWA)] <- 0
    df$GWA[df$GWA<0] <- 0 # convert -3.4e-40 to 0
    return(df)
}

clean.gww <- function(df) {
    colnames(df) <- c('FIPS','GWW')
    df$FIPS <- formatC(df$FIPS,width=5,format='d',flag='0')
    df$GWW <- as.numeric(as.character(df$GWW))
    df$GWW[is.na(df$GWW)] <- 0
    df$FIPS[df$FIPS==46113] <- 46102 # convert 46113 to 46102
    return(df)
}

# Read and clean PCR GWA
#gwa.00 <- read.csv('../../pcr_gwa_2000.csv')[,c('GEOID','sum')]
#gwa.10 <- read.csv('../../pcr_gwa_2010.csv')[,c('GEOID','sum')]
gwa.00 <- read.csv('../../paul_zonal_stats/gwa_2000.csv')[,c('GEOID','gwa')]
gwa.10 <- read.csv('../../paul_zonal_stats/gwa_2010.csv')[,c('GEOID','gwa')]
gwa.00 <- clean.gwa(gwa.00)
gwa.10 <- clean.gwa(gwa.10)

# Read & clean USGS GWW
gww.00 <- read.csv('../../usco2000.csv')[,c('FIPS','TO.WGWTo')]
gww.10 <- read.csv('../../usco2010.csv')[,c('FIPS','TO.WGWTo')]
gww.00 <- clean.gww(gww.00)
gww.10 <- clean.gww(gww.10)

# Merge GWA and GWW by year
gw.00 <- merge(gwa.00,gww.00)
gw.10 <- merge(gwa.10,gww.10)

# Save data for reviewing results
#write.csv(gw.00,'gwa_gww_2000.csv',row.names=F)
#write.csv(gw.10,'gwa_gww_2010.csv',row.names=F)

# Select data for metrics
df <- gw.10

# Create linear models
lm <- lm(GWA~GWW,data=df)

# R-squared and Adjusted R-squared
r <- summary(lm)$r.squared
r.adj <- summary(lm)$adj.r.squared

# Mean Absolute Error
mae <- mae(df$GWA,df$GWW)

# Root Mean Squared Error
rmse <- rmse(df$GWA,df$GWW)

# Jaccard Coefficient (Binary)
jaccard <- function(x,y) {
    p = sum(x==TRUE & y==TRUE)
    q = sum(x==TRUE & y==FALSE)
    r = sum(x==FALSE & y==TRUE)
    return ( p / ( p + q + r ) ) 
}

bin <- df
bin[,c('GWA','GWW')] <- ifelse(bin[,c('GWA','GWW')]>0,TRUE,FALSE)

jac <- jaccard(bin$GWA, bin$GWW)

# Simple Matching Coefficient
smc <- function(x,y) {
    p = sum(x==TRUE & y==TRUE)
    q = sum(x==TRUE & y==FALSE)
    r = sum(x==FALSE & y==TRUE)
    s = sum(x==FALSE & y==FALSE)
    return ( ( p + s ) / ( p + q + r + s ) ) 
}

smc <- smc(bin$GWA, bin$GWW)

res <- data.frame(r,r.adj,mae,rmse,jac,smc)

colnames(res) <- c('R-Squared','Adjusted R-Squared','Mean Absolute Error','Root Mean Squared Error','Jaccard Coefficient','Simple Matching Coefficient')

print(res)
write.csv(res,'fit_metrics.csv',row.names=F)
