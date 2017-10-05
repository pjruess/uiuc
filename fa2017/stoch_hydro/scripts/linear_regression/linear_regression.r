library(car)

# Runoff is dependent variable (y)
# Rainfall is independent variable (x)
# Runoff = Bo + B1*Rainfall + Error

# Ho: Runoff^ = mean(Runoff) + Error
# Ha: Runoff^ = Bo^ + B1^*Rainfall

# Read in data
rr <- read.csv('Rainfall-Runoff.csv')

# Estimate linear model

rr_model <- lm(formula=Runoff_mm~Rainfall_mm,data=rr)

# Lose a degree of freedom for each estimate
# So 36 data points - Bo - B1 = 34 df
# Resulting values are empirically related and unit-dependent
# Result: Runoff^ = -9.05 + 1.27*Rainfall
# R-squared: 0.70, Adjusted: 0.69
# p-value: 1.79e-10 (alpha = 0.05)
# Reject null, meaning rainfall is useful (better than using only average runoff)
summary(rr_model)

# Checking coefficients...
# Ho: Bi = 0
# Ha: Bi != 0 (two-tailed test)
# Bo p-value: 0.002 --> reject null (alpha = 0.05)
# B1 p-value: 1.79e-10 --> reject null (alpha = 0.05)
# Both coefficients are statistically non-zero, 
# meaning they are useful to the model

# Confidence intervals
confint(rr_model,level=0.95) # rainfall always positive; good sign

# Investigate Residuals (residual plot)
# Fitted values...
run_hat <- fitted(rr_model) # calculated residuals between model and actual values
as.data.frame(run_hat) # approximated values; convert to dataframe to review
as.data.frame(rr$Runoff_mm) # actual values
plot(run_hat,rr$Runoff_mm,xlab='Predicted',ylab='Actual') # compare model to actual
abline(0,1) # 1:1 relationship; start at 0, slope of 1
# ^ Very bad fit

# Residuals
rr_res <- resid(rr_model)
plot(rr$Rainfall_mm,rr_res,xlab='Rainfall (mm)',ylab='Residuals')
abline(0,0) # start at 0, slope of 0
residualPlots(rr_model) # residual plots; quadratic fit default using Tukey test
# Trend means autocorrelation, which is bad

# Plot data
plot(rr$Rainfall,rr$Runoff)
abline(rr_model) # Plot linear model, same as abline(-9.05,1.27)