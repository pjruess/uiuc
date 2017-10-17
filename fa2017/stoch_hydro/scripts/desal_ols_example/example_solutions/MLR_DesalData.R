# Use car package for regression diagnostics
library(car)
library(MASS)

# Import data with all parameters
Energy = read.csv("../EnergyforDesal-DesalData.csv")

# Display data
Energy

# Multiple linear regression using all variables - SEC = specific energy consumption
SEC = lm(EQKWHE ~ YR + RWTDS + PWTDS, data = Energy)
summary(SEC)

# Predicted values
EQKWHE_hat <- fitted(SEC)
as.data.frame(EQKWHE_hat)
as.data.frame(Energy$EQKWHE)
par(mar=c(5.1,5.1,4.1,2.1))
plot(EQKWHE_hat, Energy$EQKWHE, xlab = expression(paste("Predicted SEC (kWh/m"^"3",")")), ylab = expression(paste("Observed SEC (kWh/m"^"3",")")), main = "Observed vs. Predicted Specific Energy Consumption", xlim = c(0,7), ylim = c(0,7), pch = 19, cex.lab = 1.3, cex.main = 1.3, cex.axis = 1.1, cex = 1.1)
mtext(expression(paste("Municipal-Scale Model (product flow: 2500 to 368,000 m"^"3","/day); n = 38")), cex = 1.2, col = "blue")
abline(0,1)


# Regression diagnostics

	# Normal probability plot of residuals - checking for non-normality
	SEC.stdres = rstandard(SEC)
	qqnorm(SEC.stdres, ylab = "Standardized Residuals", xlab = "Normal Scores", main = "Normal Probability Plot of Specific Energy Consumption")
	qqline(SEC.stdres)
	shapiro.test(SEC.stdres)

	# Plot of residuals - checking for heteroskedasticity and autocorrelation
# Residuals
residualPlots(SEC)

# Manual plot of residuals
	SEC.res = resid(SEC)

par(oma=c(0,0,3,0))
layout(matrix(c(1,2,3), nrow=1, byrow=TRUE))

	YR_res <- plot(Energy$YR, SEC.res, ylab = "Residuals", xlab = "Year", main = "Year")
	abline(0, 0, lwd = 1.5)

	RWTDS_res <- plot(Energy$RWTDS, SEC.res, ylab = "Residuals", xlab = "Raw Water TDS (mg/L)", main = "Raw Water TDS")
	abline(0, 0, lwd = 1.5)

	PWTDS_res <- plot(Energy$PWTDS, SEC.res, ylab = "Residuals", xlab = "Product Water TDS (mg/L)", main = "Product Water TDS")
	abline(0, 0, lwd = 1.5)

title(expression(paste("Municipal-Scale Model (product flow: 2500 to 368,000 m"^"3","/day); n = 38")), outer=TRUE, cex=2)

	# Autocorrelation - Durbin-Watson statistic
	library(lmtest)
	dwtest(SEC, alternative="two.sided")


	# Multicollinearity - check if VIF > 10
	vif(SEC) # variance inflation factors


## Some additional visualization of residuals
	qqPlot(SEC, main = "QQ Plot")
	sresid <- studres(SEC)
	hist(sresid, freq = FALSE, main = "Distribution of Studentized Residuals")
	xfit <- seq(min(sresid), max(sresid), length = 40)
	yfit <- dnorm(xfit)
	plot(xfit, yfit)
