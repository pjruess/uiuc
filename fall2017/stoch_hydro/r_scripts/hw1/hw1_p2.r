# Start PDF plotting device
pdf('hw1_p2.pdf', height=5, width=5)

usgs.disch <- read.csv('usgs_08068720_daily_streamflow.csv')

plot(usgs.disch$date,usgs.disch$flow_cfs,
	xlab='Date',ylab='Daily Mean Streamflow (CFS)',
	# xaxt='n',#yaxt='n',
	main='Daily Mean Streamflow at Brays Bayou,\n Houston, TX from 9/17/2016 - 9/16/2017')

# xts package saved to /tmp/RtmpCnm0nY/downloaded_packages

# Insert x-axis (axis 1) ticks and title
# axis(1, seq(min(usgs.disch$Date), max(usgs.disch$Date), 12), las=2) # years by fives, vertical label
# ticks <- axTicksByTime(usgs.disch$Date,'months',format.labels='%b-%Y')
# axis(1,at = .index(usgs.disch$Date)[ticks], labels = names(ticks),mgp=c(0,0.5,0))
# title(xlab="Date")#, cex.lab=1.25) # increase font size

hist(usgs.disch$flow_cfs,
	xlab='Daily Mean Streamflow (CFS)',
	prob=FALSE,breaks=100)

# Is this mean correct? Ignores NA values
mean <- mean(usgs.disch$flow_cfs,na.rm=TRUE)
stdev <- sd(usgs.disch$flow_cfs,na.rm=TRUE)
n <- length(usgs.disch$flow_cfs[!is.na(usgs.disch$flow_cfs)]) # Ignore NA values
error <- qnorm(0.975)*stdev/sqrt(n)
l <- mean-error
r <- mean+error

# Report data
# plot(0:10, type = "n", xaxt="n", yaxt="n", bty="n", xlab = "", ylab = "")
text(5,8,cat('Mean: ', mean, '\n'))
text(5,7,cat('Standard Deviation: ', stdev, '\n'))
text(5,6,cat('Confidence Interval, Lower: ', l, '\n'))
text(5,5,cat('Confidence Interval, Upper: ', r, '\n'))



# End PDF plotting device
dev.off()