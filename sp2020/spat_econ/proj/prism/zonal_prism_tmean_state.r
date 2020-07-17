library(raster)
library(rgdal)

path <- 'prism_2000-18_tmean'

# Read counties
regions <- readOGR('../cb_2018_us_state_500k/cb_2018_us_state_500k.shp')

# Define file paths for all .bil files
files <- Sys.glob(file.path(path,'*.bil'))

# Read data from .bil file
for (f in files) {
    # Read current data
    # Reading .bil data example: rpubs.com/Mentors_Ubiqum/topological_datarint(head(df))
    p <- raster(f)
    
    # Extract area weighted values to df
    df <- extract(p,regions,weights=T,normalizeWeights=F,df=T)
    colnames(df) <- c('ID','layer','weight')
    df$value <- df$layer * df$weight
    df <- df[,c('ID','value','weight')]

    # Weighted arithmetic mean
    # for each ID, sum(values) / sum(weights)
    df <- aggregate(. ~ ID, df, sum, na.rm=T, na.action=NULL)

    df$value <- df$value / df$weight
    df <- df[,c('ID','value')]

    # Save output
    print(head(df))
    out <- paste('clean/prism_tmean_state/',paste(strsplit(strsplit(f,'/')[[1]][2],'\\.')[[1]][1],'.csv',sep=''),sep='')
    write.csv(df,out,row.names=F)
    print(paste('Finished: ',out,sep=''))
}
