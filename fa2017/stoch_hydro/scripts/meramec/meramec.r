meramec <- read.csv('MeramecRiver-PeakFlow_1904-2015.csv') # note propagated round-off error

# Visualize population to check for normality
qqnorm(meramec$PeakFlowCFS)
qqline(meramec$PeakFlowCFS)

# Try log-normal
qqnorm(log(meramec$PeakFlowCFS))
qqline(log(meramec$PeakFlowCFS))

# Fit a distribution
library(MASS)
logfit <- fitdistr(meramec$PeakFlowCFS,'log-normal') # fit log-normal is same as fitting normal on log(data)
logmean <- mean(log(meramec$PeakFlowCFS))
logsd <- sd(log(meramec$PeakFlowCFS))
logfit
logmean
logsd

# Ho: Meramec peak flows are normally distributed
library(nortest)
shapiro.test(log(meramec$PeakFlowCFS))
lillie.test(log(meramec$PeakFlowCFS))

# Perform Analysis
# Retrieve maximum of recent flood
meramec2017 <- read.csv('MeramecRiver-Flow_2017.csv')
flood2017 <- max(meramec2017$FlowCFS)
flood2017 # threshold value, xT

# Estimate Exceedance Probability
# note: plnorm() is already log, so don't need to transform data (pnorm() is normal)
probflood <- plnorm(flood2017,meanlog=logmean,sdlog=logsd,lower.tail=FALSE)
probflood
estT <- 1/probflood # return period
estT