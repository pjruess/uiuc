library(raster)
library(rgdal)

path <- 'PRISM_ppt_stable_4kmM3_198101_201907_bil'
path <- 'prism_2018_ppt'

# Read counties
regions <- readOGR('../cb_2018_us_county_500k/cb_2018_us_county_500k.shp')

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

    # Calculate spatial sum of values
    df <- aggregate(value ~ ID, df, sum, na.rm=T, na.action=NULL)

    # Save output
    print(head(df))
    out <- paste('clean/prism_ppt_county/',paste(strsplit(strsplit(f,'/')[[1]][2],'\\.')[[1]][1],'.csv',sep=''),sep='')
    write.csv(df,out,row.names=F)
    print(paste('Finished: ',out,sep=''))
}
