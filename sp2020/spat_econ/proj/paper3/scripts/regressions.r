library(splm) # needed for usaww matrix
library(spdep) # some funky functions
library(plm) # linear model with fixed effects
library(Ecdat) # USA Queen matrix
library(Matrix) # bdiag function
library(reshape2) # melt and dcast functions
library(lmtest) # BP test
library(rgdal) # readOGR
library(rgeos) # centroids
library(car) # scatterplot matrix
library(strucchange) # chow test
library(tseries) # jarque beraq test
library(gap) # chow test
library(sphet) # for gstsls stuff
library(spatialreg) # new version of some spdep functions
data('Produc',package='Ecdat')
data('usaww')

# States that don't grow corn (9 states if including AK and HI)
# 02, 09, 15, 23, 25, 32, 33, 44, 50
nocorn <- c('ALASKA', 'CONNECTICUT', 'HAWAII', 'MAINE', 'MASSACHUSETTS', 'NEVADA', 'NEW_HAMPSHIRE', 'RHODE_ISLAND', 'VERMONT')

# Create queen matrix
usaww.df <- melt(usaww) # reshape to long format
usaww.df <- usaww.df[!(usaww.df$Var1 %in% nocorn) & !(usaww.df$Var2 %in% nocorn),] # remove states
usa.q <- dcast(usaww.df,Var1~Var2) # return to matrix format
rownames(usa.q) <- usa.q$Var1 # rename rownames
usa.q <- usa.q[,!(names(usa.q) == 'Var1')] # remove Var1 column
usa.q <- as.matrix(usa.q) # convert to matrix format
usa.q1 <- mat2listw(usa.q) # for panel splm functions
usa.nt <- bdiag(usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q) # 19 time periods, from 2000-2018
usa.l <- mat2listw(usa.nt,style='W') # list format for Moran's
usa.l.pre <- mat2listw(bdiag(usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q)) # 10 for pre-2009
usa.l.post <- mat2listw(bdiag(usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q,usa.q)) # 9 for pre-2009

# Read corn data
df <- read.csv('corn_alldata.csv')
df$State <- sprintf('%02d',df$State) # format with leading zeros

# Scatterplot matrix
#spm(df[,c(5,7:10)])

# Regression function
f1 <- 'Yield ~ Pcp.sum*T.mean'
f2 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq'
f3 <- 'Yield ~ Pcp.sum*T.mean + T.mean.Sq'
f4 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq + T.mean.Sq'
f5 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'
f6 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq + Pcp.sum.Sq:T.mean.Sq'
m1 <- lm(formula=f1,data=df)
m2 <- lm(formula=f2,data=df)
m3 <- lm(formula=f3,data=df)
m4 <- lm(formula=f4,data=df)
m5 <- lm(formula=f5,data=df)
m6 <- lm(formula=f6,data=df)
print(anova(m1,m2,m3,m4,m5,m6)) 
print(AIC(m1,m2,m3,m4,m5,m6))
print(BIC(m1,m2,m3,m4,m5,m6))
print(logLik(m1))
print(logLik(m2))
print(logLik(m3))
print(logLik(m4))
print(logLik(m5))
print(logLik(m6))

print ('ADDING GDP AND EXPORTS')

f7 <- 'Yield ~ GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'
f8 <- 'Yield ~ Export + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'
f9 <- 'Yield ~ Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'

# Regular OLS
m7 <- lm(formula=f7,data=df)
m8 <- lm(formula=f8,data=df)
m9 <- lm(formula=f9,data=df)

# Check dif models as regular OLS
print(anova(m5,m7,m8,m9))
print(AIC(m5,m7,m8,m9))
print(BIC(m5,m7,m8,m9))
print(logLik(m5))
print(logLik(m7))
print(logLik(m8))
print(logLik(m9))

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

# Model transformation for structural instability

# Temporal Chow (pre2009 vs. post2009)
#df$pre2009 <- ifelse(df$Year < 2010,1,0)
#df$post2009 <- ifelse(df$Year >= 2010,1,0)
#f9.t <- 'Yield ~ Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq + pre2009 + Export*pre2009 + GDP.per.Cap*pre2009 + Pcp.sum*T.mean*pre2009 + Pcp.sum.Sq*T.mean.Sq*pre2009'
#m9.t <- lm(formula=f9.t,data=df)
#yp.t <- df[df$post2009==1,5,drop=F]
#xp.t <- df[df$post2009==1,7:12]
#yc.t <- df[df$pre2009==1,5,drop=F]
#xc.t <- df[df$pre2009==1,7:12]
#chow.t <- chow.test(yp.t,xp.t,yc.t,xc.t)
#print(summary(m9.t))
#print(chow.t) # highly sig, so split is important
# ^ Chow test is highly significant, so split between time periods is important

# Spatial Chow (cornbelt vs. non-cornbelt)
# Cornbelt: IL, IN, IA, KS, MI, MN, MO, NE, ND, OH, SD, WI (KY = 21 was considered but idk)
cornbelt <- c(17,18,19,20,26,27,29,31,38,39,46,55)
df$cornbelt <- ifelse(df$State %in% cornbelt, 1, 0)
df$notbelt <- ifelse(df$cornbelt == 1, 0, 1)
f9.s <- 'Yield ~ Export + GDP.per.Cap + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq + cornbelt + Export*cornbelt + GDP.per.Cap*cornbelt + Pcp.sum*T.mean*cornbelt + Pcp.sum.Sq*T.mean.Sq*cornbelt'
m9.s <- lm(formula=f9.s,data=df)
yp.s <- df[df$notbelt==1,5,drop=F]
xp.s <- df[df$notbelt==1,7:12]
yc.s <- df[df$cornbelt==1,5,drop=F]
xc.s <- df[df$cornbelt==1,7:12]
chow.s <- chow.test(yp.s,xp.s,yc.s,xc.s)

print(summary(m9.s))
print(chow.s) # highly sig, so split is important
jarque.bera.test(resid(m9.s))
bptest(m9.s)
moran.test(resid(m9.s),listw=usa.l,zero.policy=T)
lagrange <- lm.LMtests(m9.s,usa.l,test=c('all'))
summary(lagrange)
print(dim(df))

# VIF
print(vif(m9.s))

# Spatial models on OLS

# SER model
library(spatialreg)
m9.ser <- errorsarlm(f9.s,usa.l,data=df,tol.solve=1.0e-25)
summary(m9.ser)
#LR.sarlm(m9.ser,m9.s) # compare to OLS
#Hausman.test(m9.ser) # won't work even with tol.solve=1.0e-40

# SAL model
# Need to separate direct/indirect
m9.sal <- lagsarlm(f9.s,usa.l,data=df,tol.solve=1.0e-25)
summary(m9.sal)
#print(summary(impacts(m9.sal,listw=usa.l,R=1000),zstats=T,short=T)) # effects
#LR.sarlm(m9.sal,m9.s) # compare to OLS

# SAC (SARAR) model
# Need to separate direct/indirect
#m9.sac <- sacsarlm(f9.s,usa.l,data=df,tol.solve=1.0e-25) # not working
m9.sac <- gstsls(f9.s,usa.l,data=df)
summary(m9.sac)
#trMat <- trW(as(as_dgRMatrix_listw(usa.l),'CSparseMatrix'),type='mult')
#print(summary(impacts(m9.sac,tr=trMat,R=10000),zstats=T,short=T)) # effects

# BP tests to check if heterosked solved
# Heterosked NOT solved with SER and SAL models vs. OLS
bptest.sarlm(m9.ser)
bptest.sarlm(m9.sal)

# Spatial models on Panel
# WON'T WORK. Have tried formula=f9, using f9 written out explicitly (in case interactions are the problem), index=c('State','Year'), different model and effect specifications...
m9.ser.fe.within <- spml(formula=f9.s,data=df,index=NULL,lag=F,listw=usa.q1,model='within',effect='twoways',method='eigen')
summary(m9.ser.fe.within)


m9.ser.fe.random <- spml(formula=f9.s,data=df,index=NULL,lag=F,listw=usa.q1,model='random',effect=c('twoways'),method='eigen')
summary(m9.ser.fe.random)


sphtest(m9.ser.fe.within,m9.ser.fe.random)

break
m9.sac.fe <- spgm(formula=f9.s,data=df,lag=T,listw=usa.l,model='within',spatial.error=T)
summary(m9.sac.fe)



break

# Fixed effects...
m9fe <- plm(formula=f9,data=df,index=c('State','Year'),model='within',effect='twoways')
print('Model 9, FE, 2way')
summary(m9fe)
#fixef(m9fe)
moran.test(m9fe$residuals,listw=usa.l,zero.policy=T)
bptest(m9fe)

m9fe.s <- plm(formula=f9.s,data=df,index=c('State'),model='within',effect='individual')
print('Model 9, FE, 1way, Chow spatial groupings')
summary(m9fe.s)
#fixef(m9fe.s)
moran.test(m9fe.s$residuals,listw=usa.l,zero.policy=T)
bptest(m9fe.s)
break

# Moran's
moran <- moran.test(m9fe$residuals,listw=usa.l,zero.policy=T)
print(moran)
bp <- bptest(m9fe)
print(bp)

# Test core and periph individually
mc7 <- lm(formula=f7,data=df[df$pre2009==1,])
mp7 <- lm(formula=f7,data=df[df$post2009==1,])
summary(mc7)
moran.test(mc7$residuals,listw=usa.l.pre,zero.policy=T)
bptest(mc7)
jarque.bera.test(residuals(mc7))
summary(mp7)
moran.test(mp7$residuals,listw=usa.l.post,zero.policy=T)
bptest(mp7)
jarque.bera.test(residuals(mp7))


# SEM test
m3 <- spml(formula=f7,data=df,index=c('State','Year'),listw=usa.l,model='within',lag=F,spatial.error='b')#,effect='twoways')
print(summary(m3))
print(fixef(m3))


# Conley test (because heterosked)

# Add state centroids (lat/lon) to dataframe (for Conley test)
#shp <- readOGR('geoda','geoda_corn')
#shp$lat <- coordinates(shp)[,2]
#shp$lon <- coordinates(shp)[,1]
#shp <- shp[,c('STATEFP','lat','lon')]
#df <- merge(df,shp,by.x='State',by.y='STATEFP')


# NOTE: any states that produce but do not export?
# deg-days pretty consistent over time per state, so this will largely be absorbed by state fixed effects
