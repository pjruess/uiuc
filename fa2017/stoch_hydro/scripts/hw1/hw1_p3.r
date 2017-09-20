#usgsdown.disch <- read.csv('usgs_08068740_daily_streamflow.csv')
usgsup.disch <- read.csv('usgs_08068720_daily_streamflow.csv')

# Perform two-sided t-test to determine if means are different
t.test(x=usgsdown.disch$flow_cfs[!is.na(usgsdown.disch$flow_cfs)],
	y=usgsup.disch$flow_cfs[!is.na(usgsup.disch$flow_cfs)],
	alternative='two.sided',var.equal=FALSE)

# Perform one-sided "greater than" t-test to determine if downstream > upstream
t.test(x=usgsdown.disch$flow_cfs[!is.na(usgsdown.disch$flow_cfs)],
	y=usgsup.disch$flow_cfs[!is.na(usgsup.disch$flow_cfs)],
	alternative='greater',var.equal=FALSE)