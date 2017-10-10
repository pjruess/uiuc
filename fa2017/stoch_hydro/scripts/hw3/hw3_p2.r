# Start PDF plotting device
pdf('hw3_p2.pdf',height=5,width=5)
library(nortest)
library(MASS)

splendora <- read.csv('usgs_08070500_peak_streamflow.csv')
splendora2017 <- read.csv('usgs_08070500_mean_daily_streamflow_gageheight_2017.csv')

check.normality <- function(x,label) {
	# Visualize population to check for normality
	qqnorm(x,main=paste('Normal Q-Q Plot of',label))
	qqline(x)

	# Visualize population to check for log-normality
	qqnorm(log(x),main=paste('Log-Normal Q-Q Plot of',label))
	qqline(log(x))
}

verify.normality <- function(data,testtype) {
	# Ho: Splendora peak flows are normally distributed
	if (testtype == 'log') {
		print(shapiro.test(log(data)))
		print(lillie.test(log(data)))
	} else {
		print('Type not specified. Normality Assumed.')
		print(shapiro.test(data))
		print(lillie.test(data))
	}
}

get.return.period <- function(fitdata,event,fittype){
	# Fit a distribution
	fit <- fitdistr(fitdata,fittype) # log-normal fit for normality
	# unclass(fit) # see what is available in fit object

	# Estimate Exceedance Probability
	p <- plnorm(max(event), # plnorm() for log-normal; exceedance of max
		meanlog=fit$estimate['meanlog'],
		sdlog=fit$estimate['sdlog'],
		lower.tail=FALSE) # exceedance, ie. P[X>x]
	T <- 1/p # return period
	cat('Threshold: ', max(event), '\n') # threshold value, xT
	cat('Exceedance Probability of Threshold (%): ', p, '\n') 
	cat('Estimated Return Period (yr^-1): ', T, '\n')
}

print('TESTS FOR NORMALITY AND CALCULATIONS OF RETURN PERIOD')
cat('\n','***********STREAMFLOW CASE**********','\n')
check.normality(
	x=splendora$peakflow_cfs,
	label='Streamflow (cfs)')
verify.normality(
	data=splendora$peakflow_cfs,
	testtype='log'
	)
get.return.period(
	fitdata=splendora$peakflow_cfs,
	event=splendora2017$max_streamflow_cfs,
	fittype='log-normal'
	)

cat('\n','**********GAGE HEIGHT CASE**********','\n')
check.normality(
	x=splendora$peakgageheight_ft,
	label='Gage Height (ft)'
	)
verify.normality(
	data=splendora$peakgageheight_ft,
	testtype='normal'
	)
get.return.period(
	fitdata=splendora$peakgageheight_ft,
	event=splendora2017$mean_gageheight_ft,
	fittype='log-normal'
	)



# End pdf plotting device
dev.off()