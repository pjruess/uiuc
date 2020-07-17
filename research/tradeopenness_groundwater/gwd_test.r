
library(reshape2)
library(data.table)
library(dplyr)
library(gtools)
library(glue)

years <- 2000:2002

# Read in groundwater data
gwd.path <- 'cleandata/gwd.csv'
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


break

### ORIGINAL VERSION (JUST TOTAL GWD)

    # Read in groundwater data
    gwd.path <- 'cleandata/gwd.csv'
    if (!file.exists(gwd.path)){
        print(glue('Creating file: {gwd.path}'))
    
        # Initiate empty dataframe
        gwd <- data.frame(ISO=character(),
                          GWD=character(),
                          Year=character())
    
        # Iterate through years and add GWD
        for (y in years) {
            df <- read.csv(glue('rawdata/gwd_csv/{y}.csv'))[,c('ISO3','sum')]
            colnames(df) <- c('ISO','GWD')
            df$Year <- y
            df <- df[df$GWD != 'None',]
            gwd <- rbind(gwd,df)
        }

       write.csv(gwd,gwd.path,row.names=FALSE)

    } else {
        print(glue('Reading file: {gwd.path}'))
        gwd <- read.csv(gwd.path)
    }
