
p.dir <- 'prism_ppt_state'
t.dir <- 'prism_tmean_state'

p.df <- data.frame()
t.df <- data.frame()

# Cleaning function
clean <- function(path){
        df <- read.csv(path)
        df <- df[,c(1,ncol(df))]
        return(df)
}

# Paste precip data together
for (p in list.files(p.dir)){
    path <- paste(p.dir,p,sep='/')
    if (ncol(p.df) == 0) {
        p.df <- clean(path) 
    } else {
        df <- clean(path)
        p.df <- merge(p.df,df,by='GEOID',all=T) # merge on rownames
    }
}

write.csv(p.df,'ppt_2000-2018.csv',row.names=F)

# Paste precip data together
for (t in list.files(t.dir)){
    path <- paste(t.dir,t,sep='/')
    if (ncol(t.df) == 0) {
        t.df <- clean(path) 
    } else {
        df <- clean(path)
        t.df <- merge(t.df,df,by='GEOID',all=T) # merge on rownames
    }
}

write.csv(t.df,'tmean_2000-2018.csv',row.names=F)
