source('~/windows/Users/Paul/OneDrive/uiuc/generic_scripts/stat_check_assumptions.r')

# Read in csv data to dataframe
data <- read.csv(
	'usgs_06934500_daily_mean_discharge_cfs.csv',
	colClasses=c('Date','integer') # specify column data types
	)

# select post-flood ('pf') data
data_pf <- data[data$datetime >= as.Date('1994-01-01'),]

# Test for normality
check.normality(
	data=data$disch_cfs,
	path='midterm_p1_1_normal_qqplot_alldata.png',
	title='Normal Q-Q Plot of\nStreamflow (cfs), All Data'
	)
check.normality(
	data=data_pf$disch_cfs,
	path='midterm_p1_1_normal_qqplot_post-flood.png',
	title='Normal Q-Q Plot of\nStreamflow (cfs), Post-Flood Data',
	)
check.normality(
	data=log(data$disch_cfs),
	path='midterm_p1_1_lognormal_qqplot_alldata.png',
	title='Log-Normal Q-Q Plot of\nStreamflow (cfs), All Data'
	)
check.normality(
	data=log(data_pf$disch_cfs),
	path='midterm_p1_1_lognormal_qqplot_post-flood.png',
	title='Log-Normal Q-Q Plot of\nStreamflow (cfs), Post-Flood Data',
	)

# T-test
print('NORMAL DISTRIBUTION')
t.test(
	x=data$disch_cfs, # all discharge data
	y=data_pf$disch_cfs, # post-flood discharge data
	alternative='two.sided', # two-sided test
	var.equal=FALSE # Use Welch approximation to degrees of freedom
	)
print('LOG-NORMAL DISTRIBUTION')
t.test(
	x=log(data$disch_cfs), # all discharge data
	y=log(data_pf$disch_cfs), # post-flood discharge data
	alternative='two.sided', # two-sided test
	var.equal=FALSE # Use Welch approximation to degrees of freedom
	)