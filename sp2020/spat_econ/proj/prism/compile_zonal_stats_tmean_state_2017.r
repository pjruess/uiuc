

poly <- read.csv('../cb_2018_us_state_500k/attribute_table.csv')
poly$ID <- rownames(poly)

df <- read.csv('clean/prism_tmean_state/PRISM_tmean_stable_4kmM3_201701_bil.csv')
colnames(df) <- c('ID','tmean201701')

for (m in 2:12){
    m <- sprintf('%02d',m)
    temp <- read.csv(sprintf('clean/prism_tmean_state/PRISM_tmean_stable_4kmM3_2017%s_bil.csv',m))
    colnames(temp) <- c('ID',sprintf('tmean2017%s',m))
    df <- merge(df,temp,by='ID',all=T)
}

print(head(df))

res <- merge(poly,df,by='ID',all=T)

res$tmean2017 <- rowMeans(res[,c('tmean201701','tmean201702','tmean201703','tmean201704','tmean201705','tmean201706','tmean201707','tmean201708','tmean201709','tmean201710','tmean201711','tmean201712')],na.rm=T) 

res <- res[,c('GEOID','tmean201701','tmean201702','tmean201703','tmean201704','tmean201705','tmean201706','tmean201707','tmean201708','tmean201709','tmean201710','tmean201711','tmean201712','tmean2017')] 

print(head(res))

res$GEOID <- sprintf('%05d',res$GEOID)

write.csv(res,'tmean2017_state.csv',row.names=F)


