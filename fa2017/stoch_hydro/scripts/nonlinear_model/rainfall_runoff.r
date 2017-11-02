source('check_assumptions.r')

data <- read.csv('Rainfall-Runoff.csv')
attach(data)

png('rainfall_runoff_raw.png')
plot(
	x=Rainfall_mm,
	y=Runoff_mm,
	xlab='Rainfall (mm)',
	ylab='Runoff (mm)',
	main='Rainfall vs. Runoff [Raw Data]')
dev.off()

# Estimate quadratic model
sqRainfall <- (Rainfall_mm)^2
# '0 +' specifies that we want no intercept
qRRmodel <- lm(Runoff_mm ~ 0 + sqRainfall) 
summary(qRRmodel)

# Visualize quadratic model
fakerain <- seq(0,90,0.1)
predictrunoff <- predict(qRRmodel,list(sqRainfall=fakerain^2))
png('rainfall_runoff_quadratic.png')
plot(
	x=Rainfall_mm,
	y=Runoff_mm,
	xlab='Rainfall (mm)',
	ylab='Runoff (mm)',
	main='Rainfall vs. Runoff [Quadratic]'
	)
lines(fakerain,predictrunoff)
dev.off()

# Regression assumptions
# Normality
normality(
	model=qRRmodel,
	path='rainfall_runoff_quadratic_qqplot.png')
# png('rainfall_runoff_quadratic_qqplot.png')
# RR.resid <- resid(qRRmodel)
# qqnorm(RR.resid, ylab='Residuals')
# qqline(RR.resid)
# dev.off()

# Constant Variance & Independence
constvar_indep(
	model=qRRmodel,
	path='rainfall_runoff_quadtratic_constvar_indep.png',
	xdata=sqRainfall,
	xname='Rainfall^2 (mm^2)'
	)
# png('rainfall_runoff_quadtratic_constvar_indep.png')
# plot(sqRainfall,RR.resid,xlab='Rainfall^2 (mm^2)',ylab='Residuals')
# abline(0,0,lwd=1.5)
# dev.off()

# Estimate exponential model
# b = -1 for shifting the exponential model to intersect at (0,0)
# exRRmodel <- nls(Runoff_mm ~ a * exp(Rainfall_mm) + b,
# 	start=list(a=0,b=-1))
exRRmodel <- nls(Runoff_mm ~ a * exp(Rainfall_mm) - 1,
	start=list(a=0))
summary(exRRmodel)

# Visualize exponential model
fakerain <- seq(0,90,0.1)
predictrunoff <- predict(exRRmodel,list(Rainfall_mm=fakerain))
png('rainfall_runoff_exponential.png')
plot(
	x=Rainfall_mm,
	y=Runoff_mm,
	xlab='Rainfall (mm)',
	ylab='Runoff (mm)',
	main='Rainfall vs. Runoff [Exponential]'
	)
lines(fakerain,predictrunoff)
dev.off()

# Regression assumptions
# Normality
normality(
	model=exRRmodel,
	path='rainfall_runoff_exponential_qqplot.png')
# png('rainfall_runoff_exponential_qqplot.png')
# RR.resid <- resid(exRRmodel)
# qqnorm(RR.resid, ylab='Residuals')
# qqline(RR.resid)
# dev.off()

# Constant Variance & Independence
constvar_indep(
	model=exRRmodel,
	path='rainfall_runoff_exponential_constvar_indep.png',
	xdata=Rainfall_mm,
	xname='Rainfall (mm)'
	)
# png('rainfall_runoff_exponential_constvar_indep.png')
# plot(Rainfall_mm,RR.resid,xlab='Rainfall (mm)',ylab='Residuals')
# abline(0,0,lwd=1.5)
# dev.off()

# polyRRmodel <- nls(
# 	Runoff_mm ~ b*Rainfall_mm^a,
# 	start=list(a=2,b=0.05)) # b is basically zero
polyRRmodel <- nls(
	Runoff_mm ~ Rainfall_mm^a,
	start=list(a=2))
summary(polyRRmodel)

fakerain <- seq(0,90,0.1)
predictrunoff <- predict(polyRRmodel,list(Rainfall_mm=fakerain))
png('rainfall_runoff_polynomial.png')
plot(
	x=Rainfall_mm,
	y=Runoff_mm,
	xlab='Rainfall (mm)',
	ylab='Runoff (mm)',
	main='Rainfall vs. Runoff [Polynomial]'
	)
lines(fakerain,predictrunoff)
dev.off()

normality(
	model=polyRRmodel,
	path='rainfall_runoff_polynomial_qqplot.png'
	)

constvar_indep(
	model=polyRRmodel,
	path='rainfall_runoff_polynomial_constvar_indep.png',
	xdata=Rainfall_mm,
	xname='Rainfall (mm)'
	)