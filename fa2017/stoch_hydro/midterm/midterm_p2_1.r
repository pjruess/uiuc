# Read in csv data to dataframe
# Region, REGION
# Country, COUNTRY
# Infant mortality rate (2009), INFMORT [deaths per 1000 live births]
# Per capita freshwater withdrawal (2000), PCWITH [m 3 /person/yr]
# Percent of population with access to improved drinking water (2008), IMDRINK [%]
# Percent of population with access to improved sanitation (2008), IMSAN [%]

# Source file with my functions
source('~/windows/Users/Paul/OneDrive/uiuc/generic_scripts/stat_check_assumptions.r')

data <- read.csv(
	'WorldWaterStats.csv'
	)

### CREATE LINEAR MODEL ###
# specific energy consumption
model <- lm(data=data,
	INFMORT~as.numeric(REGION)+IMDRINK+IMSAN
	)
summary(model) # note mean should be ~0 (since we're minimizing)

### PLOT DATA ###
check.residuals(
	xdata=fitted(model),
	ydata=data$INFMORT,
	path='midterm_p2_1_residuals.png',
	title='Residual Plot for INFMORT\n[deaths per 1000 live births]'
	)

### CHECK ASSUMPTIONS ###
# Check normality
library(nortest)
check.normality(
	data=rstandard(model),
	path='midterm_p2_1_normality.png',
	title='Normal Q-Q Plot of\nInfant Mortality [deaths per 1000 live births]',
	tests=TRUE
	)

# Constant Variance
# Visualize constant variance, manually
png('midterm_p2_1_constantvariance.png')
model.res <- resid(model)
plot(data$INFMORT,model.res,
	main='Constant Variance Plot of Infant Mortality\nvs. Residuals [deaths per 1000 live births]')
abline(0,0,lwd=1.5)
dev.off()

# Quantitative (and visual) check for Constant Variance
# Tukey test... 
# Ho: Quadratic term in trend line is zero... a*x^2 + b*x + c, a = 0
# Ha: Quadratic term is not zero <-- heteroscedastic, a != 0
library(MASS)
library(car)
png('midterm_p2_1_residualplots.png')
residualPlots(model) # this returns resid plot for all variables, & Tukey p-values
dev.off()

# Independence (ie. lack of trends)
# Can re-use residualPlots() to search for Indepedence
# Autocorrelation: Lack of Independence

png('midterm_p2_1_independence.png')
plot(data$INFMORT,model.res)
abline(0,0,lwd=1.5)
dev.off()

# Quantitative check for Independence
# Durbin-Watson test...
# Ho: Autocorrelation = 0
# Ha: Autocorrelation != 0
library(lmtest)
dwtest(model,alternative='two.sided') # two.sided, greater, or less
# Variance Inflation Factor
vif(model) # Relationship between variables. Want low values; high means variables
		 # are very related and are likely redundant