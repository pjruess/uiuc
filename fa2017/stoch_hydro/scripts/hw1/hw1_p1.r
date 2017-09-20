# Start PDF plotting device
pdf("hw1_p1.pdf", height=5, width=5)

# Q-Q Plotting Function
my.qqnorm <- function(y=rnorm(100)){
	n <- length(y)
	yq <- ((1:n) - 0.5)/n
	zq <- qnorm(yq, mean=0, sd=1)
	plot(zq, sort(y), xlab='Standard Normal Quantile',
	ylab='Data',main='Q-Q Plot')
	abline(mean(y), sd(y))
	invisible()
	}

# Call function 10 times
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))
my.qqnorm(rnorm(20))

# End PDF plotting device
dev.off()