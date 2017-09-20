# Start PDF plotting device
pdf('hw1_p2.pdf', height=5, width=5)

usgs.disch <- read.csv('usgs_08068720_daily_streamflow.csv')

dates <- as.Date(as.character(usgs.disch$date),'%Y-%m-%d') #reformat to make plot prettier

plot(dates,usgs.disch$flow_cfs,
	xlab='Date',ylab='Daily Mean Streamflow (CFS)',
	main='Scatter Plot: Daily Mean Streamflow at Brays Bayou,
	\n Houston, TX from 9/17/2016 - 9/16/2017')

hist(usgs.disch$flow_cfs,
	xlab='Daily Mean Streamflow (CFS)',
	prob=FALSE,breaks=100, #100 breaks to make plot prettier
	main='Histogram: Daily Mean Streamflow at Brays Bayou,
	\n Houston, TX from 9/17/2016 - 9/16/2017')

# Compute confidence interval
mean <- mean(usgs.disch$flow_cfs,na.rm=TRUE) #remove NA values
stdev <- sd(usgs.disch$flow_cfs,na.rm=TRUE) #remove NA values
n <- length(usgs.disch$flow_cfs[!is.na(usgs.disch$flow_cfs)]) #remove NA values
alpha = 0.05
t <- qt(1-(alpha)/2, df=n-1) #t-statistic using qt() function to read from table
error <- t*stdev/sqrt(n)
l <- mean-error
u <- mean+error

cat('Sample Mean: ', mean, '\n')
cat('Standard Deviation: ', stdev, '\n')
cat('Number of Samples: ', n, '\n')
cat('Alpha Value: ', alpha, '\n')
cat('T Value: ', t, '\n')
cat('Error: ', error, '\n')
cat('CI Lower: ', l, '\n')
cat('CI Upper: ', u, '\n')

# End PDF plotting device
dev.off()