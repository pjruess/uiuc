poly <- read.csv('cb_2018_us_county_500k/attribute_table.csv')
poly$ID <- rownames(poly)

clean <- function(path,colname){
    df <- read.csv(path)
    colnames(df) <- c('ID',colname)
    return(df)
}

p09 <- clean('zonal_stats/PRISM_ppt_stable_4kmM3_201209_bil.csv','ppt09')
p10 <- clean('zonal_stats/PRISM_ppt_stable_4kmM3_201210_bil.csv','ppt10')
p11 <- clean('zonal_stats/PRISM_ppt_stable_4kmM3_201211_bil.csv','ppt11')

t09 <- clean('zonal_stats/PRISM_tmean_stable_4kmM3_201209_bil.csv','tmean09')
t10 <- clean('zonal_stats/PRISM_tmean_stable_4kmM3_201210_bil.csv','tmean10')
t11 <- clean('zonal_stats/PRISM_tmean_stable_4kmM3_201211_bil.csv','tmean11')

df <- merge(p09,p10,by='ID',all=T)
df <- merge(df,p11,by='ID',all=T)
df <- merge(df,t09,by='ID',all=T)
df <- merge(df,t10,by='ID',all=T)
df <- merge(df,t11,by='ID',all=T)

res <- merge(poly,df,by='ID',all=T)
#res <- res[,c('State.ANSI','ppt09','ppt10','ppt11','tmean09','tmean10','tmean11')]

#res$State.ANSI <- sprintf('%05d',res$State.ANSI)

write.csv(res,'prism_2012_ppt_tmean_states_compiled.csv',row.names=F)
