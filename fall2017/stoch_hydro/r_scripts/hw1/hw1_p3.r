# Start PDF plotting device
# pdf('hw1_p3.pdf', height=5, width=5)

# Null hypothesis: Means are the same
# Alternative hypothesis: Means are different (downstream is greater)

usgsdown.disch <- read.csv('usgs_08068740_daily_streamflow.csv')
usgsup.disch <- read.csv('usgs_08068720_daily_streamflow.csv')

# Downstream - Upstream != 0
t.test(x=usgsdown.disch$flow_cfs[!is.na(usgsdown.disch$flow_cfs)],
	y=usgsup.disch$flow_cfs[!is.na(usgsup.disch$flow_cfs)],
	alternative='two.sided',var.equal=FALSE)

# P-value is 0.1567, meaning that we do not reject null hypothesis for 
# alpha = 0.10 (90%), but we would NOT reject for alpha = 0.05 (95%).

# Is this mean correct? Ignores NA values
# mean <- mean(usgs.disch$flow_cfs,na.rm=TRUE)
# stdev <- sd(usgs.disch$flow_cfs,na.rm=TRUE)
# n <- length(usgs.disch$flow_cfs[!is.na(usgs.disch$flow_cfs)]) # Ignore NA values

# End PDF plotting device
# dev.off()