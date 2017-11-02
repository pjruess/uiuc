# NORMALITY
check.normality <- function(data,path,title,tests=FALSE) {
	# Plots qq-plot and qq-line for specified data and saves
	# as plot at path location with specified title
	
	# data: data to be tested (series or list)
	# path: file path where plot will be saved
	# title: title of plot
	# tests: specifies whether to print shapiro and lilliefors test outputs
	png(path)
	qqnorm((data),
		main=title)
	qqline((data))
	dev.off()
	if (tests) {
		print(shapiro.test(data))
		print(lillie.test(data))
	}
}

# CONSTANT VARIANCE
check.constantvariance <- function(data,path,title,tests) {
	png(path)
	plot(sqrt(abs(resid(data)))~fitted(data),
		main=title)
	abline(0,0)
	dev.off()
	if (tests) {
		print(residualPlots(model))
	}
}

# INDEPENDENCE 
check.independence <- function(data,path,title) {
	png(path)
	plot(resid(data)~fitted(data),
		main=title)
	abline(0,0)
	dev.off()
}

# RESIDUALS
check.residuals <- function(xdata,ydata,path,title) {
	png(path)
	as.data.frame(xdata)
	as.data.frame(ydata)
	plot(
		x=xdata,
		y=ydata,
		main=title
		)
	abline(0,1)
	dev.off()	
}