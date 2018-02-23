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
shapiro.test(SEC.stdres) # p < alpha --> reject null (resid NOT normally dist)

# Constant Variance
# Visualize constant variance, manually
SEC.res <- resid(SEC)
plot(lit$RWM3D,SEC.res)
abline(0,0,lwd=1.5)

# Quantitative (and visual) check for Constant Variance
# Tukey test... 
# Ho: Quadratic term in trend line is zero... a*x^2 + b*x + c, a = 0
# Ha: Quadratic term is not zero <-- heteroscedastic, a != 0
residualPlots(SEC) # this returns resid plot for all variables, & Tukey p-values
# Low p-values --> reject null --> heteroscedastic (unequal resid variance). BAD. 

# Boxcox raises to lambda power to decrease heteroscedasticity
boxcox(SEC) # determines lambda values

# Independence (ie. lack of trends)
# Can re-use residualPlots() to search for Indepedence
# Autocorrelation: Lack of Independence

# Quantitative check for Independence
# Durbin-Watson test...
# Ho: Autocorrelation = 0
# Ha: Autocorrelation != 0
library(lmtest)
dwtest(SEC,alternative='two.sided') # two.sided, greater, or less
# Variance Inflation Factor
vif(SEC) # Relationship between variables. Want low values; high means variables
		 # are very related and are likely redundant
