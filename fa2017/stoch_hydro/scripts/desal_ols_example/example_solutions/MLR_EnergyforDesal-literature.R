# Use car package for regression diagnostics
library(car)
library(MASS)

# Import data with all parameters
Energy = read.csv("../EnergyforDesal-literature.csv")

# Display data
Energy

# Multiple linear regression using all variables - SEC = specific energy consumption
SEC = lm(EQKWHE ~ RWM3D + PWM3D + INVR1 + RWTDS + P + ER + PWTDS + TEMP, data = Energy)
summary(SEC)

# Predicted values
EQKWHE_hat <- fitted(SEC)
as.data.frame(EQKWHE_hat)
as.data.frame(Energy$EQKWHE)
par(mar=c(5.1,5.1,4.1,2.1))
plot(EQKWHE_hat, Energy$EQKWHE, xlab = expression(paste("Predicted SEC (kWh/m"^"3",")")), ylab = expression(paste("Observed SEC (kWh/m"^"3",")")), main = "Observed vs. Predicted Specific Energy Consumption", xlim = c(0,15), ylim = c(0,15), pch = 19, cex.lab = 1.3, cex.main = 1.3, cex.axis = 1.1, cex = 1.1)
mtext(expression(paste("Small-Scale Model (product flow: 0.7 to 220 m"^"3","/day); n = 45")), cex = 1.2, col = "blue")
abline(0,1)


# Regression diagnostics

	# Normal probability plot of residuals - checking for non-normality
	SEC.stdres = rstandard(SEC)
	qqnorm(SEC.stdres, ylab = "Standardized Residuals", xlab = "Normal Scores", main = "Normal Probability Plot of Specific Energy Consumption")
	qqline(SEC.stdres)
	shapiro.test(SEC.stdres)

	# Plot of residuals - checking for heteroskedasticity and autocorrelation
# Residuals with Tukey test
residualPlots(SEC)

# Manual plot of residuals
	SEC.res = resid(SEC)

par(oma=c(0,0,3,0))
layout(matrix(c(1,2,3,4,5,6,7,8), nrow=2, byrow=TRUE))

	RWM3D_res <- plot(Energy$RWM3D, SEC.res, ylab = "Residuals", xlab = expression(paste("Raw Water (m"^"3","/day)")), main = "Raw Water Flow")
	abline(0, 0, lwd = 1.5)

	PWM3D_res <- plot(Energy$PWM3D, SEC.res, ylab = "Residuals", xlab = expression(paste("Product Water (m"^"3","/day)")), main = "Product Water Flow")
	abline(0, 0, lwd = 1.5)

	INVR1_res <- plot(Energy$INVR1, SEC.res, ylab = "Residuals", xlab = "Inverse Recovery", main = "Inverse Recovery")
	abline(0, 0, lwd = 1.5)

	RWTDS_res <- plot(Energy$RWTDS, SEC.res, ylab = "Residuals", xlab = "Raw Water TDS (mg/L)", main = "Raw Water TDS")
	abline(0, 0, lwd = 1.5)

	PWTDS_res <- plot(Energy$PWTDS, SEC.res, ylab = "Residuals", xlab = "Product Water TDS (mg/L)", main = "Product Water TDS")
	abline(0, 0, lwd = 1.5)

	P_res <- plot(Energy$P, SEC.res, ylab = "Residuals", xlab = "Pressure (bar)", main = "Pressure")
	abline(0, 0, lwd = 1.5)

	ER_res <- plot(Energy$ER, SEC.res, ylab = "Residuals", xlab = "Energy Recovery", main = "Energy Recovery")
	abline(0, 0, lwd = 1.5)

	TEMP_res <- plot(Energy$TEMP, SEC.res, ylab = "Residuals", xlab = expression(paste("Temperature (",degree,"C)")), main = "Temperature")
	abline(0, 0, lwd = 1.5)

title(expression(paste("Small-Scale Model (product flow: 0.7 to 220 m"^"3","/day); n = 45")), outer=TRUE, cex=2)

	# Autocorrelation - Durbin-Watson statistic
	library(lmtest)
	dwtest(SEC, alternative="two.sided")


	# Multicollinearity - check if VIF > 10
	vif(SEC) # variance inflation factors


## Some additional residiual visualization
	qqPlot(SEC, main = "QQ Plot")
	sresid <- studres(SEC)
	hist(sresid, freq = FALSE, main = "Distribution of Studentized Residuals")
	xfit <- seq(min(sresid), max(sresid), length = 40)
	yfit <- dnorm(xfit)
	plot(xfit, yfit)
