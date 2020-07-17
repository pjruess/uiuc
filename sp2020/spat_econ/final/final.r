

df <- read.delim('SWCOUNTIES.txt',header=T)
head(df)

# 1. Median
median(df$FARM_VALUE)

# 2. OLS
f <- 'FARM_VALUE ~ SHARE_OF_I + FERTI_PER_ + T_AV_WINTE + T_AV_SPRIN + P_AV_WINTE + P_AV_SPRIN + H_FRQ + PER_CA_INC + DENSITY + CLAY_RATIO + SLOPE_RATI'
print(f)
m <- lm(f,data=df)
summary(m)

# 3. AIC, BIC, etc.
print(paste('AIC:', AIC(m)))
print(paste('BIC:', BIC(m)))
logLik(m)
cor.test(df$FARM_VALUE,fitted(m),method='pearson')

# 4. Multicollinearity (VIF)
library(car)
vif(m)

# 7. JB Test
library(tseries)
jarque.bera.test(resid(m))

# 8. BP Test
library(lmtest)
bptest(m)

# 9. Queen matrix
library(maptools)
shp <- readShapePoly('SWCOUNTIES',IDvar='POLYID')
library(spdep)
queen <- poly2nb(shp,queen=T)
queen.l <- nb2listw(queen,style='W') # W for row standardization
summary(queen.l)

# 10. w250 matrix
coords <- cbind(df$XCTRD,df$YCTRD)
n <- dnearneigh(coords,0,250,longlat=T) # longlat=T for km
id <- lapply(nbdists(n,coords),function(x) 1/(x^2))
w250.l <- nb2listw(n,glist=id,style='W',zero.policy=F) # zero.policy=F to ignore islands
summary(w250.l)

# 11. Spatial Autocorrelation (Moran)
moran.mc(resid(m), queen.l,999)
moran.mc(resid(m), w250.l,999)

# 12. LM tests
summary(lm.LMtests(m,queen.l,test=c("all")))
summary(lm.LMtests(m,w250.l,test=c("all")))

# 14. Lag model
library(spatialreg)
m.lag <- lagsarlm(f,queen.l,data=df)
summary(m.lag)
#summary(impacts(m.lag,listw=queen.l,R=1000),zstats=T,short=T)

# 15. 2SLS
m.lag.2sls <- stsls(f,queen.l,data=df)
summary(m.lag.2sls)
#W <- as(as_dgRMatrix_listw(queen.l),'CsparseMatrix')
#trMatc <- trW(W,type='mult')
#summary(impacts(m.lag.2sls,tr=trMatc,R=10000),zstats=T,short=T)

# 16
bptest.sarlm(m.lag)
moran.mc(resid(m.lag), queen.l,999)

# 17
LR.sarlm(m.lag,m)

# 18
preds <- cbind(df$SHARE_OF_I,df$FERTI_PER_,df$T_AV_WINTE,df$T_AV_SPRIN,df$P_AV_WINTE,df$P_AV_SPRIN,df$H_FRQ,df$PER_CA_INC,df$DENSITY,df$CLAY_RATIO,df$SLOPE_RATI)
wpreds <- lag.listw(queen.l, preds) # define spatial lags
slx.lm <- lm(df$FARM_VALUE ~ preds+wpreds)
summary(slx.lm)

bptest(slx.lm)
moran.mc(resid(slx.lm), queen.l,999) # also for problem 20

AIC(m.lag,slx.lm)
BIC(m.lag,slx.lm)
logLik(m.lag)
logLik(slx.lm)

# 21
df$high.irri <- ifelse (df$SHARE_OF_I >median(df$SHARE_OF_I), 1,0)


f2 <- 'FARM_VALUE ~ SHARE_OF_I + FERTI_PER_ + T_AV_WINTE + T_AV_SPRIN + P_AV_WINTE + P_AV_SPRIN + H_FRQ + PER_CA_INC + DENSITY + CLAY_RATIO + SLOPE_RATI + high.irri + FERTI_PER_*high.irri + T_AV_WINTE*high.irri + T_AV_SPRIN*high.irri + P_AV_WINTE*high.irri + P_AV_SPRIN*high.irri + H_FRQ*high.irri + PER_CA_INC*high.irri + DENSITY*high.irri + CLAY_RATIO*high.irri + SLOPE_RATI*high.irri'
sdm <- lagsarlm(f2, data=df, queen.l, type="mixed")
summary(sdm)
#summary(impacts(sdm,listw=queen.l,R=1000),zstats=T,short=T)

# 23
moran.mc(resid(sdm), queen.l,999)
ser <- GMerrorsar (f2,queen.l, data=df)
summary(ser)
moran.mc(resid(ser), queen.l,999)

# 24 using sdm
df$T_AV_WINTE <- df$T_AV_WINTE + 5
df$T_AV_SPRIN <- df$T_AV_SPRIN + 10
f3 <- 'FARM_VALUE ~ SHARE_OF_I + FERTI_PER_ + T_AV_WINTE + T_AV_SPRIN + P_AV_WINTE + P_AV_SPRIN + H_FRQ + PER_CA_INC + DENSITY + CLAY_RATIO + SLOPE_RATI + high.irri + FERTI_PER_*high.irri + T_AV_WINTE*high.irri + T_AV_SPRIN*high.irri + P_AV_WINTE*high.irri + P_AV_SPRIN*high.irri + H_FRQ*high.irri + PER_CA_INC*high.irri + DENSITY*high.irri + CLAY_RATIO*high.irri + SLOPE_RATI*high.irri'
sdm <- lagsarlm(f3, data=df, queen.l, type="mixed")

plot(df$FARM_VALUE,fitted(sdm))
