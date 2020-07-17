library(plm) # linear model with fixed effects
#library(car) # scatterplot matrix
#library(lmtest) # BP test
#library(tseries) # jarque beraq test
#library(gap) # chow test
#library(strucchange) # chow test
#library(splm) # needed for usaww matrix
#library(spdep) # some funky functions

df <- read.csv('corn_alldata.csv')
df$State <- sprintf('%02d',df$State) # format with leading zeros

f <- 'Yield ~ Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'
#f2 <- 'Yield ~ -1 + Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq + factor(State)'
#f3 <- 'Yield ~ -1 + Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq + factor(Year)'
#f4 <- 'Yield ~ -1 + Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq + factor(State) + factor(Year)'

m <- lm(formula=f,data=df)
summary(m)
pool <- plm(f,df,index=c('State','Year'),model='pooling')
summary(pool)
print('--------------------------------------------------')
#m2 <- lm(formula=f2,data=df)
#summary(m2)
fe.s <- plm(formula=f,data=df,index=c('State','Year'),model='within',effect='individual')
summary(fe.s)
print('--------------------------------------------------')
#m3 <- lm(formula=f3,data=df)
#summary(m3)
fe.t <- plm(formula=f,data=df,index=c('State','Year'),model='within',effect='time')
summary(fe.t)
print('--------------------------------------------------')
#m4 <- lm(formula=f4,data=df)
#summary(m4)
fe.all <- plm(formula=f,data=df,index=c('State','Year'),model='within',effect='twoways')
summary(fe.all)

rand <- plm(formula=f,data=df,index=c('State','Year'),model='random')
summary(rand)

# Compare models - all outperform pooled OLS
pFtest(fe.s,pool)
pFtest(fe.t,pool)
pFtest(fe.all,pool)

plmtest(rand) #sig, so rand is better?
phtest(fe.all,rand,tol.solve=1e25) 

break

# Check dif models as regular OLS
print(anova(m5,m7,m8,m9))
print(AIC(m5,m7,m8,m9))
print(BIC(m5,m7,m8,m9))
print(logLik(m5))
print(logLik(m7))
print(logLik(m8))
print(logLik(m9))
break

# For now, use most complex model
print(summary(m9))
jarque.bera.test(resid(m9))
bptest(m9)
moran.test(resid(m9),listw=usa.l,zero.policy=T)
lagrange <- lm.LMtests(m9,usa.l,test=c('all'))
summary(lagrange)
print(dim(df))

# VIF
print(vif(m9))
