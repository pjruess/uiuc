library(spdep)
library(spatialreg) # for regressions

### 2. CALLING DATA, WEIGHT MATRICES, MORAN's I, and LM TESTS

# Read data
df <- read.delim('r_codes/eu.txt',header=T)
attach(df)
summary(df)

# Distance matrix
w250 <- read.gwt2nb(file='../eu/w250.gwt',region.id=POLYID)
#summary(w250)

# Contiguity matrix (rook)
rook <- read.gal(file="../eu/rook1.gal", override.id=TRUE)
#summary(rook)

# With higher order (2 here)
rook.new <- nblag(rook,maxlag=2)

# K-nearest matrix
k5 <- read.gwt2nb(file='../eu/k5.gwt',region.id=POLYID)
#summary(k5)

# Can also create weights R (not recommended)
library(maptools)

eushp <- readShapePoly('../eu/eu',IDvar='POLYID')
names(eushp)
queen <- poly2nb(eushp,queen=T)
#summary(queen)

coords <- cbind(XCNTRD,YCNTRD)
kk5 <- knearneigh(coords,k=5,longlat=T) # longlat=T uses metric
#summary(kk5)

neigh <- dnearneigh(coords,0,400,longlat=T)
#summary(neigh,coords)

# 1/d^2 dist
idlist <- lapply(nbdists(neigh,coords),function(x) 1/(x^2))
summary(idlist)
break
# zero.policy ignores islands
WW400 <- nb2listw(neigh,glist=idlist,style='W',zero.policy=F)
#summary(WW400)

# Square matrices for ideal grids
Wnb <- cell2nb(3,3,type="rook") 
#summary(Wnb)

# Check symmetry (not useful for k-nearest, since non-symmetric by def'n)
#print(is.symmetric.nb(w250))
#print(is.symmetric.nb(as.matrix(neigh)))

# Convert nb objects to listw for use in regressions *** important ***
w250.listw <- nb2listw(w250)
k5.listw <- nb2listw(k5)
kk5.listw <- nb2listw(knn2nb(kk5), style="W")

# Model to test spatial stuff on
preds <- cbind(GDP89, MANUF89, AGRI, INV)
growth.lm <- lm(GROWTH ~ preds)
summary(growth.lm)

# Moran's with 999 permutations on dif spatial def'n
Moran.w250 <- moran.mc(residuals(growth.lm), w250.listw,999)
print(Moran.w250)
Moran.WW400 <- moran.mc(residuals(growth.lm), WW400,999)
print(Moran.WW400)
Moran.kk5 <- moran.mc(residuals(growth.lm), kk5.listw,999)
print(Moran.kk5)

# LM test for spatial autocorrel
# SER (w250) or SLM (WW400 or k5)
growth.lagrange <-lm.LMtests(growth.lm,w250.listw,test=c("all")) # if not 'all', only LMerror
print(growth.lagrange)

### 3. REGRESSIONS

# Models with homosked errors (estimated by max likelihood)...
# SER for no spillovers
growth.err <- errorsarlm(GROWTH ~ preds,w250.listw, data=df)
summary(growth.err)

# SLX for local spillovers
# Note: this lags ALL regressors. If want only some, need to specify
wpreds <- lag.listw(w250.listw, preds) # define spatial lags
slx.lm <- lm(GROWTH ~ preds+wpreds)
summary(slx.lm)

# SDEM (SER + SLX) for local spillovers
# Use when Moran shows spatial autocorr in SLX.
sdem.lm <- errorsarlm(GROWTH ~ preds+wpreds,w250.listw, data=df)
summary(sdem.lm)

# SAL for global spillovers
# Caution: separate direct vs. indirect effects before reporting/interpreting
growth.lag <- lagsarlm(GROWTH ~ preds,w250.listw, data = df)
summary(growth.lag)

# SAC for global spillovers
# Caution: separate direct vs. indirect effects before reporting/interpreting
growth.sac <- sacsarlm(GROWTH ~ preds, data = df, w250.listw,k5.listw)
summary(growth.sac)

# SDM for (SLX + SAL) for global spillovers
# Caution: separate direct vs. indirect effects before reporting/interpreting
growth.durbin <- lagsarlm(GROWTH ~ preds, data=df, w250.listw, type="mixed")
summary(growth.durbin)

# Select best model (AIC, BIC, logLik)
# * Can be compared as long as they have the exact same dependent variable *

# Use R* instead of R2 (R2 can't be used for spatial b/c assumes i.i.d. errors)

# LR tests for comparing OLS vs. any of the spatial models
LR.test <- LR.sarlm(slx.lm,growth.lm)
print(LR.test)

LR.test1 <- LR.sarlm(sdem.lm,growth.lm)
print(LR.test1)

LR.test2 <- LR.sarlm(growth.durbin,growth.lm)
print(LR.test2)

# Hausman tests checks is SDM is relevant vs. SER
print(Hausman.test(growth.err))
# ^ P-val < 5%: ser captures omitted var, but correl w vars --> use SDM
# ^ P-val > 5%: omitted not correlated w observed --> keep SER

# Alternatives to ML estimation... 

# For Spatial Lag Model (SAL)
# Caution: separate direct vs. indirect effects before reporting/interpreting
# if ways X+WX only (no W^(2)*X term), then add W2X=FALSE
lag.2sls <- stsls(GROWTH~preds,w250.listw,data=df)
print(summary(lag.2sls))

# For Spatial Durbin? Impossible (WX perfectly collinear w SDM regressors)

# For SEM
err.gmm <- GMerrorsar(GROWTH~preds,w250.listw,data=df)
print(summary(err.gmm))

# For SDEM
slx.gmm <- GMerrorsar(GROWTH~preds,w250.listw,data=df)
print(summary(slx.gmm))

# For SAC (=SARAR)
# Make sure to calc indirect/direct effects
sac.gstsls <- gstsls(GROWTH~preds,w250.listw,data=df)
print(summary(sac.gstsls))

### Separating direct vs. indirect effects for global effects models
# Calc std errors using Monte Carlo if R specified (# iters) & ZSTATS=T
# (SAL, SDM, SAC)
# Direct: marginal effect on a region
# Indirect: sum of marginal effects from other regions (sum of spillovers)

# SAL - ML estimation
effects <- impacts(growth.lag,listw=w250.listw,R=1000)
print(summary(effects,zstats=T,short=T))

# SAL - 2SLS estimation
W <- as(as_dgRMatrix_listw(w250.listw),'CsparseMatrix')
trMatc <- trW(W,type='mult')
effects2 <- summary(impacts(lag.2sls,tr=trMatc,R=10000),zstats=T,short=T)
print(effects2)

# SDM - 2SLS estimation
effects3 <-summary(impacts(growth.durbin,tr=trMatc,R=10000,zstats=T,short=T))
print(effects3)

# SAC - ML estimation
effects4 <- impacts(growth.sac,listw=w250.listw,R=1000)
print(summary(effects4,zstats=T,short=T))

# SAC - GS2SLS estimation
effects5 <- summary(impacts(sac.gstsls,tr=trMatc,R=10000),zstats=T,short=T)
print(effects5)

# Breusch-Pagan BP to detect heterosked
# Can only be used on Max Lik models (not GMM or 2SLS)

# OLS BP
library(lmtest)
bptest(growth.lm)

# Max Lik BP
bptest.sarlm(growth.err)
bptest.sarlm(sdem.lm)

# If BP significant (heterosked) --> correct for it

# Correcting Heteroskedasticity...

# 1. Parametrically estimating variance-covariance matrix

# OLS
library(sandwich)
growthrobust <- coeftest(growth.lm,vcov.=NeweyWest)
print(growthrobust)

# SLX
slxrobust <- coeftest(slx.lm,vcov.=NeweyWest)
print(slxrobust)

# SAL
library(sphet)

# First option: gstslshet
lag.2sls.robust <- gstslshet(GROWTH~preds,w250.listw,data=df,sarar=F)
summary(lag.2sls.robust)

# Second option: spreg (this is preferred option)
lag.robust <- spreg(GROWTH~preds,data=df,w250.listw,model='lag',het=T)
summary(lag.robust)
# Note: spatial lag coeff is 'lambda' here (should technically be 'rho')
# Make sure to separate dir/indir results

# SEM
SER.robust <- spreg(GROWTH~preds,data=df,w250.listw,model='error',het=T)
# Note: spatial lag coeff is 'lambda' here (should technically be 'rho')

# SAC (two options)
#sac.gstsls <- gstslshet(GROWTH~preds,w250.listw,data=df)
#summary(sac.gstsls)
SAC.robust <- spreg(GROWTH~preds,data=df,w250.listw,model='sarar',het=T)
summary(SAC.robust)
# Make sure to separate dir/indir results

# 2. Non-parametrically setting structure of var-covar matrix w observed data

# Spatial HAC
# only for case where model estimated by OLS or 2SLS
# assumed forms of heterosked & spatial correl across error terms are UNKNOWN
# Need 2 things... 	
# - 1). matrix of pairwise distances bw all spatial units
# - 2). typology of kernel function
#library(sphet)

coords <- cbind(XCNTRD,YCNTRD)
neigh.shac <- dnearneigh(coords,row.names=POLYID,0,402,longlat=T) 
# ^ 250mi = 402km
# ^ longlat=T --> use decimal degrees
summary(neigh.shac,coords)

# List of spatial neighbor links
dlist.shac <- nbdists(neigh.shac,coords,longlat=T)
summary(dlist.shac)
idlist.shac <- lapply(dlist.shac,function(x) 1/(x^2)) # for 1/d^2
shac.listw <- nb2listw(neigh.shac,glist=idlist.shac,style='W',zero.policy=F)
summary(shac.listw)
# ^ style = 'W' to stay similar to w250 used above

write.sn2gwt(sn=listw2sn(shac.listw),file='shac.gwt')
shac.dist <- read.gwt2dist(file='shac.gwt',region.id=POLYID)
summary(shac.dist)

# Run HAC model
HAC <- spreg(GROWTH~preds+wpreds,data=df,model='ols',het=T,HAC=T,distance=shac.dist,type='Epanechnikov',bandwidth=402)
summary(HAC)

# Can also HAC on lag model...
HAC.sal <- spreg(GROWTH~preds,data=df,w250.listw,model='ivhac',HAC=T,distance=shac.dist,type='Epanechnikov',bandwidth=402)
summary(HAC.sal)
# Report dir/indir results

# Note on 2SLS regression when endogenous regressor(s)
exo.preds <- cbind(GDP89,MANUF89,AGRI)
HAC.IV <- spreg(GROWTH~exo.preds,endog=~INV,instruments=~XCNTRD+YCNTRD,data=df,w250.listw,model='ols',HAC=T,distance=shac.dist,type='Epanechnikov',bandwidth=402)
summary(HAC.IV)
# ^ model='ols': model is a-spatial, estimation relies on 2SLS
# ^ HAC=T: SHAC is executed

# Alternative for HAC=F (model with WY)
HAC.IV.sal <- spreg(GROWTH~exo.preds,endog=~INV,instruments=~XCNTRD+YCNTRD,data=df,w250.listw,model='lag',HAC=F,distance=shac.dist,type='Epanechnikov',bandwidth=402)
summary(HAC.IV.sal)

# Can also do model = 'error' or = 'sarar'

# Note sometimes matrix inversion can't be performed...
# ^ error in solve.default(inf,tol=tol.solve): system computationally singular
# can add 'tol.solve=1.0e-11'
# ^ (do this in the model call): lagsarlm(func,listw,data,tol.solve=1.0e-11)
# or (preferred) can rescale data so they all display similar magnitude
# ^ changes magnitude of estimated betas, but precision and interpretation stays the same

### 4. SPATIAL REGIMES
# (using core and periphery ideas from before)

core <- REGIME
periphery <- ifelse(REGIME>0,0,1)
summary(core+periphery)

GDPC<- GDP89*core
GDPP<- GDP89* periphery
MANUC<- MANUF89* core
MANUP<- MANUF89* periphery
AGRIC<- AGRI* core
AGRIP<- AGRI* periphery
INVC<- INV* core
INVP<- INV* periphery

regs1 <- cbind(GDPC, GDPP, AGRIC, AGRIP, MANUC, MANUP, INVC, INVP)

# avoid dummy variable trap by including '-1'
regime1 <- lm(GROWTH ~ -1 + core + periphery + regs1)
summary(regime1)

# SER by ML
growth.err2 <- errorsarlm(GROWTH ~ -1 + core + periphery + regs1,w250.listw, data=df)
summary(growth.err2)

# SER by GMM
growth.err22 <- GMerrorsar (GROWTH ~ -1 + core + periphery + regs1,w250.listw, data=df)
summary(growth.err22)

# SLX
# Write EXACTLY as below to ensure spatial lags include variables from each other
# ^ (core from periph and vice versa when near border)
wregs <- lag.listw(w250.listw, preds)

wregsC <- wregs*core
wregsP <- wregs*periphery
wregs1 <- cbind(wregsC,wregsP)

slx2 <-lm(GROWTH ~ -1 + core + periphery + regs1 + wregs1)
summary(slx2)

# SDEM by ML
sdem2 <- errorsarlm(GROWTH ~ -1 + core + periphery + regs1 + wregs1, w250.listw, data=df)
summary(sdem2)

# SDEM by GMM
sdem22 <- GMerrorsar (GROWTH ~ -1 + core + periphery + regs1 + wregs1, w250.listw, data=df)
summary(sdem22)

# SAL by ML
growth.lag2 <- lagsarlm(GROWTH ~ -1 + core + periphery + regs1,w250.listw, data = df)
summary(growth.lag2)

# SAL by 2SLS
growth.lag22 <- stsls(GROWTH ~ -1 + core + periphery + regs1,w250.listw, data = df) # sarar=T default
summary(growth.lag22)

# SAC by ML
growth.sac2 <- sacsarlm(GROWTH ~ -1 + core + periphery + regs1, data = df, w250.listw)
summary(growth.sac2)

# SAC by 2SLS
growth.sac2.gstsls <- gstsls(GROWTH ~ -1 + core + periphery + regs1, data = df, w250.listw)
summary(growth.sac2.gstsls)

# Spatial Durbin (can have two intercepts as above)
growth.durbin2 <- lagsarlm(GROWTH ~ regs1, data=df, w250.listw,type='mixed')
summary(growth.durbin2)

# LR test for best model...
LR.test3 <- LR.sarlm(growth.durbin2,growth.err2)
print(LR.test3)

# For spatial models with robust estimates (heterosked issues)...

# SLX robust
slxrobust2 <-coeftest(slx2, vcov.=NeweyWest)
print(slxrobust2)

# Spatial Lag 2SLS robust
lag.2sls.robust2 <- gstslshet(GROWTH ~ -1 + core + periphery + regs1,w250.listw, data = df, sarar=FALSE)
summary(lag.2sls.robust2)

# Spatial Error w/ Heterosked (non-parametric Spatial HAC approach)
HAC.2 <- spreg(GROWTH ~ -1 + core + periphery + regs1, data=df, w250.listw, model="ols", HAC=TRUE, distance=shac.dist, type="Epanechnikov", bandwidth=402)
summary(HAC.2)
# ^ controls for both 1) spatial error autocorrel and 2) heterosked

# Direct and Indirect Effects (with Spatial Heterogeneity)

# Spatial Lag by ML
effects <- summary(impacts(growth.lag2,listw=w250.listw,R=1000),zstats=T,short=T)
print(effects)

# Spatial Lab by 2SLS (HOMOsked)
effects2<- summary(impacts(growth.lag22, listw= w250.listw, R=1000),zstats=T,short=T)
print(effects2)

# Spatial Lab by 2SLS (HETEROsked)
#effects3<- summary(impacts(lag.2sls.robust2, listw= w250.listw, R=1000),zstats=T,short=T)
#print(effects3)

# Spatial Durbin
effects4<- summary(impacts(growth.durbin2, listw= w250.listw, R=1000),zstats=T,short=T)
print(effects4)

# SAC
effects5<- summary(impacts(growth.sac2, listw= w250.listw, R=1000),zstats=T,short=T)
print(effects5)

### 5. SIMULATION EXPERIMENTS

# Simulation 1
simu1 <- read.delim('r_codes/simu1.txt',header=F)
attach(simu1)

rho <- coef(growth.lag)[1] # spatial lag coeff, significant

beta <- coef(growth.lag)[6] # spatial lag beta coeff of invest, p-val = 5.3%

ww250 <- nb2mat(w250)
durbin <- solve(diag(145)-rho*ww250)
# ^ 'solve' calcs inverse in parenthesis, 'diag' creates identity mat (145*145)

# Results
simu <- as.vector(simu1)
dxbeta <- as.vector(unlist(simu*beta))
deltay <- (durbin%*%dxbeta)
sink(file='r_codes/simu1.xlsx')

write.table(deltay,sep='\t') # sends output to new xls file
sink()
# Note: can send results to .dbf file instead, to visualize results

# Simulation 2
simu2 <- read.delim('r_codes/simu2.txt',header=F)
attach(simu2)

lambda <- coef(growth.err)[1] # spatial lag coeff, significant

simu <- as.vector(simu2)
dxbeta <- as.vector(unlist(simu*lambda))
deltay <- (durbin%*%dxbeta)
sink(file='r_codes/simu2.xlsx')

write.table(deltay,sep='\t') # sends output to new xls file
sink()
# Note: can send results to .dbf file instead, to visualize results

### 6. PROJECTIONS

# With an A-Spatial Model
AGRIsimu <- rnorm(mean=10,sd=10,n=145)
preds1 <- cbind(GDP89,MANUF89,AGRIsimu,INV)
newdata <- data.frame(preds1)
pred <- predict(growth.lm,newdata,interval='confidence',header=T)
print(head(pred))

library(plotrix)
x <- 1:145
plotCI(x, pred[,1], (pred[,1]-pred[,2]), (pred[,3]-pred[,1]),xlab='n',ylab='yhat & 95% CI')

# With a Spatial Model
# ^ (regressor changes impact other regressors, all simultaneously)

GDP89new <- GDP89+2
MANUF89new <- GDP89+MANUF89
AGRInew <- AGRI*0.2
INVnew <- INV
predsnew <- cbind(GDP89new,MANUF89new,AGRInew,INVnew)
newdata2 <- data.frame(predsnew)

# Plotting
x <- 1:145

# Spatial Lag model
y.hat.new <- predict.sarlm(growth.lag, data=newdata2, listw=w250.listw,region.id=POLYID,interval='confidence',header=T)
y.hat.new.m <- as.matrix(data.frame(y.hat.new))
plotCI(x, y.hat.new.m[,1], (y.hat.new.m[,1]-y.hat.new.m[,2]), (y.hat.new.m[,3]-y.hat.new.m[,1]), xlab='n', ylab='y hat, trend, fit+trend')

# Spatial error model...
y.hat.new.err <- predict.sarlm(growth.err, data=newdata2, listw=w250.listw, region.id=POLYID,interval='confidence',header=T)
y.hat.new.mat <- as.matrix(data.frame(y.hat.new.err))
plotCI(x, y.hat.new.mat[,1], (y.hat.new.mat[,1]-y.hat.new.mat[,2]), (y.hat.new.mat[,3]-y.hat.new.mat[,1]), xlab='n', ylab='y hat and fit+trend')
