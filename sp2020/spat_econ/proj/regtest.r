library('plm')
data('Grunfeld',package='plm')
df <- Grunfeld

f <- 'inv ~ value + capital'
f2 <- 'inv ~ -1 + value + capital + factor(firm)'
f3 <- 'inv ~ -1 + value + capital + factor(year)'

# Standard OLS
ols <- lm(f,df)
summary(ols)

fe <- plm(f,df,index=c('firm','year'),model='pooling')
summary(fe)
break

# Space fixed eff
ols.fe <- lm(f2,df)
summary(ols.fe)

fe.s <- plm(f,df,index=c('firm','year'),model='within',effect='individual')
summary(fe.s)

# Time fixed eff
ols.fe <- lm(f3,df)
summary(ols.fe)

fe.t <- plm(f,df,index=c('firm','year'),model='within',effect='time')
summary(fe.t)


break

pool <- plm(inv~value+capital,df,index=c('year'),model='pooling')
summary(pool)
