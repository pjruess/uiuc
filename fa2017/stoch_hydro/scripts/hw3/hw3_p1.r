# Start PDF plotting device
pdf('hw3_p1.pdf',height=5,width=5)

require(hydroTSM)

# Data from https://waterdata.usgs.gov/ca/nwis/dv?cb_00060=on&format=rdb&site_no=11143250&referred_module=sw&period=&begin_date=1962-08-01&end_date=2017-10-04
carmel <- read.csv('usgs_11143250_mean_daily_streamflow.csv') # Carmel, CA

fdc(carmel$discharge_cfs,
	xlab='Exceedance Probability (%)',
	ylab='Streamflow (cfs)',
	main='Flow Duration Curve from fdc() Function',
	lQ.thr=0.9,hQ.thr=0.1)

# Order data from largest to smallest
x <- carmel$discharge_cfs

# Calculate exceedance probability
p <- 100*rank(-x)/(length(x)+1) # rank(-x) is decreasing order

plot(p,x,
	xlab='Exceedance Probability (%)',
	xlim=c(-5,65),
	ylab='Discharge (cfs)',
	main='Flow Duration Curve from Custom Script',
	log='y')

# End pdf plotting device
dev.off()