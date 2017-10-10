library(car)
library(MASS)

### HYPOTHESES TESTS ###
# Hypothesis (Model)
# Ho: EQKWHE = mean(EQKWHE) + error <-- p > alpha
# Ha: EQKWHE = f(x_i) <-- p < alpha
# ------------------
# Hypothesis (Parameters) (B = beta; B_i = parameters)
# Ho: B_i = 0 <-- p > alpha
# Ha: B_i != 0 <-- p < alpha

### READ IN DATA ###
# Data from desal database
data <- read.csv('EnergyforDesal-DesalData.csv')
# Data from literature review
lit <- read.csv('EnergyforDesal-literature.csv')

### CREATE LINEAR MODEL ###
# specific energy consumption
SEC <- lm(data=lit,
	EQKWHE~ RWM3D + PWM3D + INVR1 + RWTDS + PWTDS + P + TEMP + ER
	)
summary(SEC) # note mean should be ~0 (since we're minimizing)
# R-squared = 0.85 --> 85% variation in dep var is explained by the indep vars

### PLOT DATA ###
EQKWHE_hat <- fitted(SEC)
as.data.frame(EQKWHE_hat)
as.data.frame(lit$EQKWHE)

plot(x=EQKWHE_hat,y=lit$EQKWHE)
abline(0,1)

### TEST FOR NORMALITY ###
# Visualize Normality
SEC.stdres <- rstandard(SEC) # standard residuals
qqnorm(SEC.stdres)
qqline(SEC.stdres)

# Quantitative Check for Normality
# Shapiro test... 
# Ho: resid~N(0,sigma)
# Ha: resid not normally distributed
shapiro.test(SEC.stdres) # p < alpha --> do not reject null (resid normally dist)

# Constant Variance
# Visualize constant variance, manually
SEC.res <- resid(SEC)
plot(lit$RWM3D,SEC.res)
abline(0,0,lwd=1.5)

# Quantitative (and visual) check for constant variance
# Tukey test... 
# Ho: Quadratic term in trend line is zero
# Ha: Quadratic term is not zero <-- heteroscedastic
residualPlots(SEC) # this returns Tukey test p-values
