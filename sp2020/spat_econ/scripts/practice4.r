# Panels...

### Packages, data, and weight matrix
library(splm)
library(spdep)
library(plm)
library(Ecdat)

data('Produc',package='Ecdat')
data('usaww')

data <- Produc
attach(data)
summary(data)

fm <- log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp

# Exploring panel data
library(foreign)
coplot(log(gsp)~year|state,type='b')

library(car)
scatterplot(log(gsp)~year|state,boxplots=F,smooth=T,reg.line=F)

# Heterogeneity plots
library(gplots)
# Mean across years for each state
plotmeans(log(gsp)~state,bars=T,main='Heterogeneity across states')
# Mean across states for each year
plotmeans(log(gsp)~year,bars=T,main='Heterogeneity across years')

# OLS
ols <- lm(log(gsp)~log(pcap)+log(pc)+log(emp)+unemp)
summary(ols)

# spatial unit fixed effects by least squares dummy variable
fixed.dum <- lm(log(gsp)~-1+log(pcap)+log(pc)+log(emp)+unemp+factor(state))
summary(fixed.dum)

# Compare results side-by-side
library(apsrtable)
apsrtable(ols,fixed.dum,se=c('pval'),model.names=c('OLS','OLS_DUM'),align=c('left'),order=c('longest'))
# export results in txt
cat(apsrtable(ols,fixed.dum,model.names=c('OLS','OLS_DUM'),Sweave=F),file='ols_fixed1.txt')

# LR test on lm objects (from spdep)
LR.sarlm(ols,fixed.dum)

# Using PLM for fixed effect and random effect models
library(plm)
fixed <- plm(log(gsp)~log(pcap)+log(pc)+log(emp)+unemp,data=data,index=c('state','year'),model='within',effect='individual')
# ^ panel with index=c('state','year') part
# ^ model = 'within' (fixed effects), 'random' (random effects), 'pooling' (no effects = pooled OLS)
# ^ effect = 'individual' (spatial only), 'time' (time only), 'twoways' (both)
summary(fixed)
fixef(fixed) # constants for each state

# Test if fixed eff outperforms OLS
# ^ small p-val: outperforms OLS and sig interstate/year variation present
pFtest(fixed,ols)

# Random eff model; similar to effect='individual', though other effects also fine
random <- plm(log(gsp)~log(pcap)+log(pc)+log(emp)+unemp,data=data,index=c('state','year'),model='random')
summary(random)

# Check if random effects are useful
plmtest(random) #small p sig --> param heterogeneity must be taken into account

# Other uses of plmtest... (honda is default)
# BP Ho: covar across entities/time is zero --> sig p means sig covariance (not zero)
plmtest(fixed,c('time'),type=('bp'))
plmtest(fixed,c('individual'),type='bp')
plmtest(fixed,c('twoways'),type='bp')
plmtest(random,type='bp')
# ^ plmtest sig p means fixed/random eff are better than pooled OLS

# Multicollinearity
library(car)
vif(ols) # does not work for fixed b/c fixed has no intercept

# Compare fixed vs. random w Hausman test: p < 5% --> use fixed
phtest(fixed,random)

# Heteroskedasticity with HCvcov
# Random: use white1 or white2 + HC estimator (HC0 (white's) to HC4)
# ^ HC0: large samples, HC1-HC3: small samples, HC4: small w influential obs
# Fixed: use arellano
# Spatial autocorrelation in errors: use Conley's standard errors
library(lmtest)
bptest(log(gsp)~log(pcap)+log(pc)+log(emp)+unemp,data=data)

# Heterosked in random effects model...
summary(random)
coeftest(random) # original standard errors
coeftest(random,vcovHC) # heterosked consistent errors
coeftest(random,vcovHC(random,type='HC3')) # heterosked consistent errors
coeftest(random,vcovHC(random,method='white2',type='HC2')) # heterosked consistent errors
# to access all HC variables at once...
t(sapply(c('HC0','HC1','HC2','HC3','HC4'),function(x) sqrt(diag(vcovHC(random,type=x)))))

# Heterosked in fixed effects model...
summary(fixed)
coeftest(fixed) # original standard errors
coeftest(fixed,vcovHC) # heterosked consistent errors
coeftest(fixed,vcovHC(fixed,method='arellano')) # heterosked consistent errors
coeftest(fixed,vcovHC(fixed,type='HC3')) # heterosked consistent errors
# to access all HC variables at once...
t(sapply(c('HC0','HC1','HC2','HC3','HC4'),function(x) sqrt(diag(vcovHC(fixed,type=x)))))

# Test for time dependence
pooled <- plm(log(gsp)~log(pcap)+log(pc)+log(emp)+unemp,data=data,index=c('state','year'),model='pooling')
# ^ pooled OLS bc following function don't work on lm(OLS) objects

# Test time-correlation (panel with large T)
# (Breusch-Godfrey/Wooldridge)
pbgtest(pooled)
pbgtest(fixed)
pbgtest(fixed)
# ^ sig p-val --> serial autocorrelation

# Test for serial correlation in errors (for fixed eff only)
# (Wooldridge)
Wooldridge <- pwartest(fixed)
print(Wooldridge)
# ^ sig p-val --> confirm serial correlation --> use 'arellano' std errors

library(TTR)
library(tseries)
Panel.set <- plm.data(data,index=c('state','year'))
adf.test(Panel.set$y,k=2)
# ^ sig p-val --> unit-root is present

# Test whether residuals are correlated across entities
# NOT NECESSARILY SPATIAL (could be with non-neighbors)
# (Breusch-Pagan/LM and Pesaran Cross-sectional Dependence (CD))
pcdtest(pooled,test=c('lm')) # BP
pcdtest(pooled,test=c('cd')) # Pesaran

pcdtest(fixed,test=c('lm'))
pcdtest(fixed,test=c('cd'))

pcdtest(random,test=c('lm'))
pcdtest(random,test=c('cd'))
# ^ sig values indicate spatial dependence

# Moran's I
library(Matrix)
# usaww (from Ecdat) is 48*48 queen of US states
# NT is (48*17)*(48*17), 17 for time periods (17 years)
NT <-bdiag(usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww, usaww,usaww)
NTlistw <- mat2listw(NT)
moran.test(pooled$residuals,listw=NTlistw,zero.policy=T)
moran.test(fixed$residuals,listw=NTlistw,zero.policy=T)
moran.test(random$residuals,listw=NTlistw,zero.policy=T)
# alternative: moran.mc(residuals(pooled),NTlistw,999)
# ^ sig p-val --> spatial autocorrelation (only in pooled model here)

# Spatial weights matrices
queen <- mat2listw(usaww) # from Ecdat package, dim(usaww) = 48*48
summary(queen)

USA <- read.delim('r_codes/USA/USA.txt',header=T)
attach(USA)
names(USA)

library(maptools)
USAshpf <- readShapePoly('r_codes/USA/USA',IDvar='ID')
names(USAshpf)
Queen <- poly2nb(USAshpf,queen=T)
summary(Queen)
is.symmetric.nb(Queen)

nb_Queen <- nb2mat(Queen,style='W')
# ^ style W used to respect the one embedded in usaww (row-standardized)

Queenlistw <- mat2listw(nb_Queen)
# ^ listw object needed for spat econ models

detach(USA)

### 3. Spatial panel models estimated by ML

# SARAR with random effects
sarar.random <- spml(formula=fm,data=Produc,index=NULL,listw=queen,model='random',lag=TRUE,spatial.error='b')
# ^ index = NULL: first two vars are indiv/time, same as index=c('state','year')
# ^ lag = TRUE: adds WY to model (FALSE: model has spat err autocorr ONLY)
# ^ spatial.error = 'b' (Baltagi), 'kkp' (Kapoor), 'none' (spatial lag only; no spat err correl)
summary(sarar.random) # note: lambda is WY coeff; rho is spat error autocorr coeff; phi is sigma_mu^2 / sigma_epsilon^2

# Effects only works for spatial.error='none' or ='kkp'
sarar.random.none <- spml(formula=fm,data=Produc,index=NULL,listw=queen,model='random',lag=TRUE,spatial.error='none')
effects <- impacts(sarar.random.none,listw=mat2listw(usaww,style='W'),time=17)
summary(effects,zstats=T,short=T)
# Insig indir effects apparently?

# Spatial panel error model (SEM) with fixed effects and spatial errors
sem.random <- spml(formula=fm,data=Produc,index=NULL,listw=queen,model='random',lag=FALSE,spatial.error='kkp')
summary(sem.random)
# No direct vs. indirect here (b/c lag = FALSE???)

# SARAR with fixed effects
# Note: spatial.error = 'b' or 'kkp' are the same here
sarar.fixed <- spml(formula=fm,data=Produc,index=NULL,listw=queen,lag=TRUE,spatial.error='kkp',model='within',effect='individual',method='eigen')
summary(sarar.fixed)
# model = 'within': fixed effects
# effect = 'individual': across spatial units only
# method = 'eigen': likelihood expressed as log Jacobian
# ^ method alternatives: 'spam', 'Matrix', 'LU' (sparse matrices)
# ^ method alternatives: 'Chebyshev' (approx), 'MC' (Monte Carlo of LeSage & Pace)

effects2 <- impacts(sarar.fixed,listw=mat2listw(usaww,style='W'),time=17)
summary(effects2,zstats=T,short=T)

# Spatial error autocorrelation (SER) with both time and spatial fixed effects
ser.fixed <- spml(formula=fm,data=Produc,index=NULL,listw=queen,model='within',effect=c('twoways'),method='eigen')
summary(ser.fixed)

ser.fixed.effects <- effects(ser.fixed)
print(ser.fixed.effects)
# ^ twoways fixed effects

# Time fixed effects
ser.fixed.time <- spml(formula=fm,data=Produc,listw=queen,model='within',effect='time',method='eigen')
summary(ser.fixed.time)

v <- effects(ser.fixed.time)
print(v)

# Model fit (Pearson correlation test b/w fitted and observed values)
ct <- cor.test(fitted(ser.fixed),log(gsp),method='pearson')
print(ct)
# ^ p-val insig means can't conclude correlation is dif from 0 (no linear relationship)
# ^ abs value of 1 indicates perfect linear relationship; 0 no linear relationship

# 4. SPATIAL PANEL DATA ESTIMATED BY GMM

# Random effects
# Spatial SER panel w random eff
ser.gmm <- spgm(formula=fm,data=Produc,listw=queen,lag=F,moments='weights',model='random',spatial.error=T)
summary(ser.gmm)
print(ser.gmm$errcomp) # spatial error coefficient
# ^ rho: spat err autocor param; sigma^2: variance
# ^ moments = defaults, 'weights', or 'fullweights' (Kapoor et al., 2007)

# Spatial SAC panel w random eff
sac.gmm <- spgm(formula=fm,data=Produc,listw=queen,lag=T,moments='fullweights',model='random',spatial.error=T)
summary(sac.gmm)
print(sac.gmm$errcomp)
# ^ lambda: coeff of spat dep var; rho: spat errors
# Note: impact function for direct/indirect does not work for GMM

# SAC of SER fixed eff model = 'within' (fixed eff)
sac.gmm.fixed <- spgm(formula=fm,data=Produc,lag=T,listw=queen,model='within',spatial.error=T)
summary(sac.gmm.fixed)
# ^ lambda: coeff of spatially dep var; rho for spat errors

# SER is SAC, just change lag to FALSE
ser.gmm.fixed <- spgm(formula=fm,data=Produc,lag=F,listw=queen,model='within',spatial.error=T)
summary(ser.gmm.fixed)

### 5. TESTS

# Testing for random effects and/or spatial error autocorrelation
test1 <- bsktest(x=fm,data=Produc,listw=queen,test='LM1')
print(class(test1))
print(test1)
# test = ...
# "LMH" H_0:ρ=σ_μ^2=0 vs. H_1 : at least one component is not zero.
# "LM1" H_0:σ_μ^2=0 (assuming no spatial autocorrelation) vs. H_1:σ_μ^2≠0
# "LM2" H_0:ρ=0 (assuming no random effects) vs. H_1:ρ≠0
# "CLMlambda" H_0:ρ=0 (assuming the possible existence of random effects, i.e. σ_μ^2≥0) vs. H_1:ρ≠0 (assuming the possible existence of random effects)
# "CLMmu" H_0:σ_μ^2=0 (assuming the possible existence of spatial autocorrelation, i.e. ρ≥0) vs. H_1:σ_μ^2≠0 (assuming the possible existence of spatial autocorrelation)
# ^ sig p-val rejects Ho, alt hypoth printed in results
# So if LM1 is rejected, conclude random eff AND spatial autocorrelation

# Linear hypothesis testing, from library(car)
linearHypothesis(sarar.random,'log(pcap)=log(pc)')
# ^ sig p-val: coefs are sig dif from each 

# Spatial Hausman test

# SEM
test1 <- sphtest(x=fm,data=Produc,listw=queen,spatial.model='error',method='GM')
print(test1)
# ^ sig p-val: sig dif bw random & fixed eff models --> use fixed

# SAC

mod1 <- spgm(formula=fm,data=Produc,listw=queen,lag=T,model='random',spatial.error=T)
mod2 <- spgm(formula=fm,data=Produc,listw=queen,lag=T,model='within',spatial.error=T)
test2 <- sphtest(x=mod1,x2=mod2)
print(test2)
# ^ results: sig p-val, so one is inconsistent... use fixed eff model (mod2)

### 6. CONTROLLING FOR SPATIAL AUTOCORREL & HETEROSKED SIMULTANEOUSLY IN PANEL
# * Conley's robust standard errors (SHAC) *

library(data.table)
library(lfe)
library(geosphere)
library(Rcpp)
library(RcppArmadillo)
library(dplyr)

olsConley <- function(data, y, X, lat, lon, cutoff) {
	tbldfGrabber <- function(data, varnames) {
		matrixObject <- data %>% select(.dots = varnames) %>% as.matrix()
	} 
	n <- nrow(data)
	k <- length(X)
	ydata <- tbldfGrabber(data, y)
	xdata <- tbldfGrabber(data, X)
	betahat <- solve(t(xdata) %*% xdata) %*% t(xdata) %*% ydata
	e <- ydata - xdata %*% betahat
	# grab latitude & longitude
	latdata <- tbldfGrabber(data, lat)
	londata <- tbldfGrabber(data, lon)
	# loop over all of the spatial units 
	meatWeight <- lapply(1:n, function(i) 
		{
			# turn longitude & latitude into KMs. 1 deg lat = 111 km, 1 deg lon = 111 km* cos(lat)
			lonscale <- cos(latdata[i]*pi / 180) * 111
			latscale <- 111
			# distance calculation --> use pythagorean theorem
			dist <- as.numeric(sqrt((latscale*(latdata[i] - latdata))^2+ (lonscale*(londata[i] - londata))^2))
			# set a window var = 1 iff observation j is within cutoff dist of obs i
			window <- as.numeric(dist <= cutoff)
			XeeXh <- ((t(t(xdata[i, ])) %*% matrix(1, 1, n) * e[i,]) *(matrix(1, k, 1) %*% (t(e) * t(window)))) %*% xdata
			return(XeeXh)
		}
	)
	##Now lets make the “sandwich”. First, the meat = sum_i what we just made
	meat <- (Reduce("+", meatWeight)) / n
	# and the usual bread
	bread <- solve(t(xdata) %*% xdata)
	sandwich <- n* (t(bread) %*% meat %*% bread)
	# se as per usual
	se <- sqrt(diag(sandwich))
	output <- list(betahat, se)
	names(output) <- c("betahat", "conleySE")
	return(output)
}

# Application of Conley's
attach(USA)
names(USA)

colnames(USA)[colnames(USA)=="Y_COORD"] <- "lat"
colnames(USA)[colnames(USA)=="X_COORD"] <- "long"

DataUSA <- mutate(USA, ones=1)

USAConley <- olsConley(DataUSA, "G90.04", c("ones","HSCHOOL","COLLEGE","UNEMPLOY","AGRI","GDP90"), "long", "lat", 100)
print(USAConley)
# results: estimated beta & std errors
# ^ compare with traditional s.e.

cannedstderrors <- summary(lm(data = USA, G90.04 ~ HSCHOOL+COLLEGE+UNEMPLOY+AGRI+GDP90))
cannedstderrors
# ^ trad too small, increasing chance of type I error (reject null when actually true)
