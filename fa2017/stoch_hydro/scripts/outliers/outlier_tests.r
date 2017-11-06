# Import necessary libraries
library(car) # for linear models
library(MASS) # to check for normality
library(EnvStats) # to run Rosner's test for outliers

# Read in Data
df <- read.csv('Rainfall-Runoff.csv')

# Create linear model
RRmodel <- lm(Runoff_mm~Rainfall_mm,data=df)
summary(RRmodel)
png('raw_data_and_fit.png')
Runoff_hat <- fitted(RRmodel)
plot(df$Rainfall_mm, df$Runoff_mm)
lines(df$Rainfall_mm, Runoff_hat)
dev.off()

# Log-transform data
logRainfall <- log(df$Rainfall_mm)
logRunoff <- log(df$Runoff_mm)

# Shapiro test for normality
# Ho: Normally distributed
# Ha: Not normally distributed
# Large p-value, fail to reject, probably normally distributed
shapiro.test(logRainfall)
shapiro.test(logRunoff) # returns nothing because zero-value was log-transformed to negative infinity
shapiro.test(df$Runoff_mm) # definitely not normally distributed (super small p-value)

# Rosner's Test
# Checks for multiple outliers (iterative for k outliers, requiring k tests)
# Data MUST be normally distributed
# For steps m = 1, 2, ..., k
# Ho: All values in sample of size (n-m+1) are from the same normal population
# Ha: Unlikely that the m most extreme events came from the same normal population
rosnerTest(logRainfall) # default k=3 (number of suspected outliers), alpha = 0.05, warn = TRUE (issue warnings)
# Output specifies that one outlier is detected, and sample 36 is that outlier (the last point in the dataset)
rosnerTest(logRunoff) # data violates normality, so these results are arguably meaningless

# Dixon-Thompson
# Checks whether an outlier exists in the dataset (either low or high)
# Data MUST be normally distributed
# Ho: data ~ N(mu,sigma)
# Ha: an outlier exists
# Reject Ho if R > Rc
# R values come from table depending on sample size and whether testing for low or high outliers
# Example...
# n = 18
# c(3010,15000,16000,19040,20300,33990,57140,63000,66410,67050,69000,70000,73040,80000,103980,112070,119200,124070)
# X = 3010 (the value we believe is an outlier)
# Low-outlier, sample size 14-25... R = (X_3-X_1)/(X_n-2 - X_1) = (16000 - 3010) / (112070 - 3010 ) = 0.119
# Rc = 0.467 (n = 18, 5% significance level)
# Result: R < Rc, so fail to reject
# Low value is not an outlier
vals <- c(3010,15000,16000,19040,20300,33990,57140,63000,66410,67050,69000,70000,73040,80000,103980,112070,119200,124070)
dixon.test(vals,type=0,opposite=FALSE,two.sided=TRUE)


