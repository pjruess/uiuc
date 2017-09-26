require(hydroTSM)

fdc.data <- read.csv('Boneyard_1948todate.csv')

fdc(fdc.data$FlowCFS,
	ylab='Streamflow (cfs)',xlab='Exceedance Probability (%)',
	lQ.thr=0.9,hQ.thr=0.1)

