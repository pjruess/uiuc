
options(scipen=-999)

df <- read.csv('dwf.csv')

df <- df[(df$year == 2012) & (df$ori_res == 'faf') & (df$des_res == 'faf'),]

df <- df[order(-df$total),]

print(head(df,10))
