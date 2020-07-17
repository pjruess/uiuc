years <- unlist(2000:2018)

for (y in years){

    poly <- read.csv('../cb_2018_us_state_500k/attribute_table.csv')
    poly$ID <- rownames(poly)
    
    df <- read.csv(sprintf('clean/prism_tmean_state/PRISM_tmean_stable_4kmM3_%s01_bil.csv',y))
    colnames(df) <- c('ID',sprintf('tmean%s01',y))
    
    for (m in 2:12){
        m <- sprintf('%02d',m)
        temp <- read.csv(sprintf('clean/prism_tmean_state/PRISM_tmean_stable_4kmM3_%s%s_bil.csv',y,m))
        colnames(temp) <- c('ID',sprintf('tmean%s%s',y,m))
        df <- merge(df,temp,by='ID',all=T)
    }
    
    res <- merge(poly,df,by='ID',all=T)
    
    res[,sprintf('tmean%s',y)] <- rowMeans(res[,11:22],na.rm=T)
    
    res <- res[,c(5,11:23)] 
    
    res$GEOID <- sprintf('%05d',res$GEOID)
    
    write.csv(res,sprintf('clean/annual/prism_tmean_state/tmean%s_state.csv',y),row.names=F)

}
