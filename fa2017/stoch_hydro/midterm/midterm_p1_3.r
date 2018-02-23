# Read in csv data to dataframe
data <- read.csv(
	'usgs_06934500_peak_discharge_cfs.csv',
	colClasses=c('Date','integer') # specify column data types
	)
eventdata <- read.csv(
	'usgs_06934500_daily_mean_discharge_cfs.csv',
	colClasses=c('Date','integer') # specify column data types
	)

print('Discharge ranking BEFORE removal, largest to smallest')
data$peak_disch_cfs[order(-data$peak_disch_cfs,decreasing=FALSE)]

# Remove estimated 1844 and 1903 floods
data <- data[data$datetime >= as.Date('1904-01-01'),]

print('Discharge ranking AFTER removal, largest to smallest')
data$peak_disch_cfs[order(-data$peak_disch_cfs,decreasing=FALSE)]

# NORMALITY
# Source file with check.normality() function
source('~/windows/Users/Paul/OneDrive/uiuc/generic_scripts/stat_check_assumptions.r')
# Library required for lilliefors normality test in check.normality, lillie.test()
library(nortest)

print('NORMAL DATA')
check.normality(
	data=data$peak_disch_cfs,
	path='midterm_p1_3_normal_qqplot_alldata.png',
	title='Normal Q-Q Plot of\nStreamflow (cfs)',
	tests=TRUE
	)
print('LOG-NORMAL DATA')
check.normality(
	data=log(data$peak_disch_cfs),
	path='midterm_p1_3_lognormal_qqplot_alldata.png',
	title='Log-Normal Q-Q Plot of\nStreamflow (cfs)',
	tests=TRUE
	)

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

# Collect discharge data for 1993 only
event <- eventdata[eventdata$datetime >= as.Date('1993-01-01') & eventdata$datetime <= as.Date('1993-12-31'),]

# Calculate return period
# Library required for fitdistr() function
library(MASS)
get.return.period(
	fitdata=data$peak_disch_cfs,
	event=event$disch_cfs,
	fittype='log-normal'
	)