### 1. BRIEF INTRODUCTION TO R

library(foreign) # package to import/export data b/w R and other stats packs

scores <- c(5:8) # set of values
print(scores)
print(mean(scores))
resids <- scores-mean(scores) # residuals (dif b/w values and mean)
print(resids)

### 2. CONCRETE EXAMPLE

df <- read.delim('r_codes/eu.txt',header=T)

print(names(data)) # columns headers
print(summary(df)) # min, max, and quartile values
print(var(df$GDP89)) # variance
print(sd(df$GDP89)) # standard deviation
print(length(df$GDP89)) # length, or number of rows
print(ncol(df$GDP89)) # number of columns
print(nrow(df$GDP89)) # number of rows
print(dim(df$GDP89)) # dimensions (null for vectors)
print(dim(df)) # dimensions of dataframe
hist(df$GDP89) # histogram
hist(df$GDP89,breaks=18) # histogram, specifying # of breaks
boxplot(df$GDP89) # boxplot
boxplot(df$GDP89,range=1.5) # boxplot specifying hinge value (formula in notes)
# Outlier is multiple (hinge) of interquartile range (dif b/w 75% and 25%)
print(boxplot.stats(df$GDP89)) # stats, n, conf, out
print(boxplot.stats(df$GDP89)$stats) # min, 1st Q, median, 3rd Q, max

### 3. BASIC REGRESSION

m <- lm(df$GROWTH~df$GDP89) # y~x format, so... growth(gdp89)
s <- summary(m)

c <- s$coefficients
print('model...')
print(s)
print('model coeffs...')
print(c)

ci <- confint(m,level=0.95) # level default 0.95; confidence intervals
print('conf int...')
print(ci)

tstats <- c[2,1]-5/c[2,2] 
print('tstats...')
print(tstats)
pval <- pt(abs(tstats),df=df.residual(m),lower.tail=F) # *2 for 2-tail test
print('pval...')
print(pval)

plot(df$GDP89,df$GROWTH,xlab='Initial Per Capita Income',ylab='Growth')
abline(m) # straight regression line (1:1)
text(9.5,0.08,'y=mx+b') # add text to plot

#simulated gdp using regression
sim.gdp <- rnorm(mean=10,sd=0.4,n=145) # random normal?

df.p <- data.frame(sim.gdp) # df.predicted
pred <- predict(m,df.p,interval='confidence',header=T)
print(head(pred))

library(plotrix)
plotCI(1:145,pred[,1],(pred[,1]-pred[,2]),(pred[,3]-pred[,1]),xlab='n',ylab='95% CI')

### 4. NORMALITY TESTS

# Manually calculated residuals
yhat <- fitted(m)
uhat <- df$GROWTH - yhat # this is u = y - y-hat (resid = dif b/w fit and actual)
print(head(uhat))

# Residuals using built-in function
uhat2 <- resid(m)
print(head(uhat2))

# Dif between both methods to calculate residuals (no dif)
print(summary(uhat-uhat2))

# Normally distributed residuals
set.seed = 121 # any value is fine; this is for the randomization
uhatnorm <- rnorm(mean=mean(uhat2),sd=sd(uhat2),n=145)
print(head(uhatnorm))

# Libraries for skewness and kurtosis. Either works. 
library(fBasics)
#library(e1071)

# Note that normal dist has skew = 0 and kurtosis = 3. 
# * positive skew of uhat (0.9) means right tail is longer than left, 
# ... so bulk of values are left of the mean (including median)
# * kurtosis < 3 means lower, wider peak around mean with shorter tails

print(skewness(uhat2))
print(skewness(uhatnorm))
print(kurtosis(uhat2))
print(kurtosis(uhatnorm))

hist(uhat2,breaks=28)
hist(uhatnorm,breaks=28)

# Jarque Bera JB test... Ho: data is normally distributed
# ^ Small P-val & large JB val --> reject null, so NOT normally dist
library(tseries)
jarque.bera.test(uhat2) # significant... NOT normally dist
jarque.bera.test(uhatnorm) # DON'T reject... normally dist (insig p-val, 0.29)

# Not significant for residuals, so H0 that JB=0 cannot be rejected.