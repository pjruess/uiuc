# Start with regular OLS before adding spatial components
# Always report standard error, mean, etc... sigma(0,1) business

df <- read.delim('r_codes/eu.txt',header=T)

# Get a sense for degree of correlation between data
# Want to get a sense of degree of multicollinearity

# Don't be too quick to remove variables from your analysis
# because this might add omitted variable bias even if it helps fit

# Making a matrix of data
attach(df)

### 1. CHECKING DISTRIBUTION OF DATA AND THEIR CORRELATION

preds <- cbind(GDP89,MANUF89,AGRI,INV) # all predictor variables
mat <- cor(preds) # correlation matrix
print(mat)

# Check correlation significance: small p-val means sig, val is cor (bottom)
# Ex: GDP89,AGRI... p-val < 2.2e-16, cor = -0.78
cor.test(GDP89,AGRI) # can do for each pair of variables

# These check for all variable pairs automatically (cor, then p)
library(Hmisc)
pear <- rcorr(preds,type='pearson')
spear <- rcorr(preds,type='spearman')

print(pear)
print(spear)

# Visualization: diagonal is smoothed histogram; others are relationships
# Ex: no linear relationship b/w gdp & inv
library(car)
car.spm <- spm(preds) # scatterplot matrix

# Note: VIF is better
# ^ which covar shows highest relation b/w own val and other covars

### 2. Run model and display results

m <- lm(GROWTH~GDP89+MANUF89+AGRI+INV)
summary(m)
m2 <- lm(GROWTH~preds) # same as above
summary(m2)

# Remember...
# t-val = est / std.error
# deg freedom needs to compare to critical t-val
# if deg free > 60, calc t is 2... so we know that Intercept
# variable is significant here at 5% level (b/c > 2)
# (same for GDP, AGRI, and INV... but not MANUF89)
# manuf prob of being wrong when saying manuf dif than zero is 62%...
# so prob of being wrong is high, so maybe remove
# but Sandy wants to keep even if insignificant to avoid OVB

# Adj R-sq can be fine even if low. Compare to literature.

# Two options for reporting. Coeff (p-val) vs. coeff (std.err).
# I prefer p-val. So does Sandy. 

# VIF runs model bw each covariate and all other covariates
# GDP89 function of manu, ag, and inv... similar for all others
# VIF: 1 (no collinearity), infinity (perfect collinearity)
# ^ VIF > 10 means highly collinear
m.vif <- vif(m)
print(m.vif)

# Example with pure multicollinearity
#g <- AGRI * 2 + 5
#m.hack <- lm(GROWTH~GDP89+MANUF89+AGRI+INV+g)
#print(vif(m.hack))
# Error: "There are aliased coefficients in the model" (some shit is related)
# This may happen when adding dummy variables to model

### 3. ANOVA or best subset regression

# Result of basic OLS gives F-statistics, which tests the ANOVA

# ANCOVA (analysis of covariance)
# Asks if its worth it to add an additional variable
# Run with Y on X1 and X2 -> R^2
# Run second model including X3 -> new R^2
# ANOVA asks if new R^2 is significantly greater than old R^2
# (because it will be larger with more covariates, so
# have to check if dif is SIGNIFICANT)

# Compare a few models (page 6 R scripts #2)
m2 <- lm(GROWTH~GDP89+AGRI+INV) # no manuf
m3 <- lm(GROWTH~GDP89+MANUF89+AGRI+INV+AGRI*INV) # interaction

summary(m) # old model to compare with
summary(m2)
summary(m3)

# ANOVA results
# Shows each model, then tells resid sum of sq for each one (RSS)
# m vs. m2 ... dif between R^2 is not significant (62% p-val)
# so can't really conclude that model 1 is better than model 2
# model 3 also isn't significantly better/worse than model 1
# Default syntax compares to first model in the list
print(anova(m,m2,m3))

# Variable selection (determining which covariates are best)

# This selects best covariate of options (only one)
# Can then run a model with two covariates, using the best (1st)
# combined with the remaining options, to determine best 2 covs
library(leaps)
x1 <- regsubsets(preds,GROWTH) # adds each var 1 by 1 and prioritizes
print(summary(x1))
# ^ GDP89 > AGRI > INV > MANUF89

# Make plots to look at how R2 and adj.R2 change with addition
# of new covariates
# R2 always goes up... so adj.R2 is better
# (can see that when MANUF89 is added, adj.R2 is LOWER) --> maybe remove
x2 <- leaps(preds,GROWTH,nbest=1,method='r2')
x3 <- leaps(preds,GROWTH,nbest=1,method='adjr2')
par(mfrow=c(1,2))
plot(x2$size-1,x2$r2,xlab='number of predictors',ylab=expression(R^2))
lines(spline(x2$size-1,x2$r2))
plot(x3$size-1,x3$adjr2,xlab='number of predictors',ylab=expression(adj.R^2))
lines(spline(x3$size-1,x3$adjr2))

### 4. TESTS ON COEFFICIENTS

# library(car)
# equality of covariates
linearHypothesis(m,c('AGRI = GDP89'))
# p = 16%, so cannot reject (Betas NOT significantly diff)

# covariate equality to specific value
linearHypothesis(m,c('AGRI = 1'))
# p is tiny and sig, so reject: AGRI != 1

# or combined covariates equality to specific value
linearHypothesis(m,c('AGRI + GDP89 = 1'))
# p is tiny and sig, so reject: AGRI + GDP89 != 1

### 5. ADDITIONAL TOOLS FOR MODEL SELECTION

# Library for spatial dependence to run Schwarz criterion
library(spdep)

AIC(m,m2,m3) # lower is better, so 2 is best model (-907)
BIC(m,m2,m3) # ^ same ... model 2 is best (-892)
logLik(m) 
logLik(m2)
logLik(m3) # want HIGHER, so 3 is best

# Test for comparing lin-lin (linear) vs. log-log models
# Does NOT test lin-log or log-lin models
# ^ Must manually compare with lin-log or log-lin 
# ^ Can use AIC/BIC/logLik/adj.R2, etc. to compare models
# I think log-log vs. log-lin works, or lin-lin vs lin-log? Unsure.

# Also note... if literature/theory has ideas,
# then just use whatever model is commonly accepted

# NOTES...
# For converting zero (0) to log, add 1 to every single value
# ^ This makes log(1), which is mathematically possible
# Can also apply to ratios

library(lmtest)

LNMANU <- log(MANUF89)

m4 <- lm(MANUF89~GROWTH+GDP89+AGRI+INV)
summary(m4)
m5 <- lm(LNMANU~GROWTH+GDP89+AGRI+INV)
summary(m5)
petest(m4,m5) # PE test to determine which fit is best (lin or log)
# RESULTS: add dif of two models, to see if one is better
# Also... fit(m1) - exp(fit(m2)) to check dif
# if either is sig dif than zero...
# first: log-log sig better? 
# second: lin-lin sig better?
# p-val means log-log is better than lin-lin for this model

### 5. SPATIAL HETEROGENEITY: STRUCTURAL INSTABILITY &/OR HETEROSKEDASTICITY
# (but only after calibration of non-spatial model)

# HETEROSKEDASTICITY... constant variance of error terms or no?

# Koenker-Bassett
yhatsq <- fitted(m)^2
uhatsq <- resid(m)^2
m7 <- lm(uhatsq~yhatsq)
summary(m7)
# ^ no heteroskedasticity (bc p-val > 5%)

# Check how they impact each other visually: flat means no effect
par(mfrow=c(1,1))
plot(yhatsq,uhatsq)
abline(m7)

# Breusch-Pagan
bptest(m) # p-val > 5%, so not sig, so no heteroskedasticity (homosked)

# (Just pick one: KB or BP)

# STRUCTURAL INSTABILITY... 

# Core is core of Europe, periphery is exterior countries (based on 'REGIME')
core <- REGIME
print(core)
periphery <- ifelse(REGIME>0,0,1)
print(periphery)

# -1 to avoid dummy variable trap... need to look into this more

regnew<-lm(GROWTH~-1+ core + GDP89:core +MANUF89:core +AGRI:core +INV:core + periphery + GDP89:periphery +MANUF89:periphery +AGRI:periphery +INV:periphery)
summary(regnew)

# No -1 needed bc B1 is roughly same as previous B1p*Dp
# This is dif bw core in ref to periphery (reference group)
# GDP is sig dif in core than in periph
reg4<-lm(GROWTH~GDP89+MANUF89+AGRI+INV+core+ GDP89:core +MANUF89:core +AGRI:core +INV:core)
summary(reg4)

# Chow...

# Read core and periph data
df.c <- read.delim('r_codes/euc.txt',header=T)
df.p <- read.delim('r_codes/eup.txt',header=T)

attach(df.c)
yc <- GROWTH
xc <- cbind(GDP89,MANUF89,AGRI,INV)

attach(df.p)
yp <- GROWTH
xp <- cbind(GDP89,MANUF89,AGRI,INV)

# Chow test
library(gap)
chow.test(yp,xp,yc,xc)

# Same chow test results with dif package
# 'core' is dummy, 1 in core and 0 elsewhere
library(strucchange)
sctest(GROWTH~GDP89+MANUF89+AGRI+INV,data=df,type='Chow',core)
# Chow shows that the groups are sig dif (core != periph)
# ^ Keep the core/periph separation

detach(df.c)
detach(df.p)
attach(df)

# This is the eqn.4 regression
bptest(regnew) # no heterosked (BP not sig)

library(tseries)
jarque.bera.test(resid(regnew)) # highly sig --> not normally dist

# Test each group individually (core is 5, periph is 6)
# Can summarize these results in table to compare, report BP & JB also
reg5 <- lm(yc~xc)
summary(reg5)
reg6 <- lm(yp~xp)
summary(reg6)

bptest(reg5) # not sig --> homosked
bptest(reg6) # not sig --> homosked

jarque.bera.test(resid(reg5)) # not normally dist (spatial autocorr)
jarque.bera.test(resid(reg6)) # not normally dist (spatial autocorr)

# Heteroskedast...
# Option 1 and 3 are popular. Option 2 is not so popular. 
# 1: lin-lin model... transform all variables to log
# ^ only works if all data are not already log (duh)
# 2: find problem covar and address it (this is tricky)
# ^ make plots to identify problem -> remove covar w sqrt div
# ^ this makes interp of betas really difficult, so screw this
# 3: White's robust std errors
# ^ controls for heteroskedast in a random way (no assumps)
# ^ this helps us remove it

# White's... (option 3)
robust <- coeftest(regnew,vcovHC(regnew,type='HC0'))
print(robust)
summary(regnew)
# ^ Comparison...
# Beta values DO NOT change
# Errors and p-vals DO change

