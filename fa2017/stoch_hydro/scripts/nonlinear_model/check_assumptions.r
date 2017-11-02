normality <- function(model,path){
	png(path)
	qqnorm(resid(model),ylab='Residuals')
	qqline(resid(model))
	dev.off()
}

constvar_indep <- function(model,path,xdata,xname){
	png(path)
	plot(
		xdata,
		resid(model),
		xlab=xname,
		ylab='Residuals')
	abline(0,0,lwd=1.5)
	dev.off()
}