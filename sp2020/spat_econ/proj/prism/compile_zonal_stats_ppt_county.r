y <- '2017'

poly <- read.csv('../cb_2018_us_county_500k/attribute_table.csv')
poly$ID <- rownames(poly)

df <- read.csv(sprintf('clean/prism_ppt_county/PRISM_ppt_stable_4kmM3_%s01_bil.csv',y))
colnames(df) <- c('ID',sprintf('ppt%s01',y))

for (m in 2:12){
    m <- sprintf('%02d',m)
    temp <- read.csv(sprintf('clean/prism_ppt_county/PRISM_ppt_stable_4kmM3_%s%s_bil.csv',y,m))
    colnames(temp) <- c('ID',sprintf('ppt%s%s',y,m))
    df <- merge(df,temp,by='ID',all=T)
}

res <- merge(poly,df,by='ID',all=T)

res[,sprintf('ppt%s',y)] <- rowSums(res[,11:22],na.rm=T)

res <- res[,c(5,11:23)] 

print(head(res))

res$GEOID <- sprintf('%05d',res$GEOID)

write.csv(res,sprintf('clean/annual/prism_ppt_state/ppt%s_county.csv',y),row.names=F)
