# Start PDF plotting device
pdf('hw3_p2.pdf',height=5,width=5)

splendora <- read.csv('usgs_08070500_peak_streamflow.csv')

get_return_period <- function(x,y){
	x <- data
}

get.return.period(splendora$peakflow_cfs,splendora2017$max_streamflow_cfs)
get.return.period(splendora$peakgageheight_ft,splendora2017$mean_gage_height_ft)

x <- splendora$peakflow_cfs

# Visualize population to check for normality
qqnorm(x)
qqline(x)

# Visualize population to check for log-normality
qqnorm(log(x))
qqline(log(x))

# Ho: Splendora peak flows are normally distributed
library(nortest)
shapiro.test(log(x))
lillie.test(log(x))

# Fit a distribution
library(MASS)
fit <- fitdistr(x,'log-normal') # log-normal fit for normality
# unclass(fit) # see what is available in fit object

# Perform Analysis
# Retrieve maximum of recent flood
splendora2017 <- read.csv('usgs_08070500_mean_daily_streamflow_gageheight_2017.csv')
disch2017 <- max(splendora2017$max_streamflow_cfs)
height2017 <- max(splendora2017$mean_gage_height_ft)



# Estimate Exceedance Probability
p <- plnorm(disch2017, # plnorm() for log-normal
	meanlog=fit$estimate['meanlog'],
	sdlog=fit$estimate['sdlog'],
	lower.tail=FALSE) # exceedance, ie. P[X>x]

cat('Threshold streamflow (cfs): ', disch2017, '\n') # threshold value, xT
cat('Threshold gage height (ft): ', height2017, '\n') # threshold value, xT

cat('Exceedance Probability of Threshold (%): ', p, '\n') 
estT <- 1/p # return period
cat('Estimated Return Period (yr^-1): ', estT, '\n') 

# End pdf plotting device
dev.off()