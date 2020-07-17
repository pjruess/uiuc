df1 <- read.csv('cleandata/main_control_0708.csv')
df1$iso_o <- df1$ISO
df2 <- read.csv('cleandata/main_df1_0621.csv')

df <- merge(df1,df2)

write.csv(df,'cleandata/qian_alldata.csv',row.names=FALSE)

df_s0 <- df[,c('Year','iso_o')]
write.csv(df_so,'cleandata/qian_stage0_data.csv',row.names=FALSE)

df_s1 <- df[,c('Year','iso_o')]
write.csv(df_so,'cleandata/qian_stage0_data.csv',row.names=FALSE)

df_s0 <- df[,c('Year','iso_o')]
write.csv(df_so,'cleandata/qian_stage0_data.csv',row.names=FALSE)

df_s0 <- df[,c('Year','iso_o')]
write.csv(df_so,'cleandata/qian_stage0_data.csv',row.names=FALSE)
