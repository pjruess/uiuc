### Read in Data

# Read in Production Survey Data (Corn, 2012)
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [AUTAUGUA]
# County.ANSI: Last 3 digits of 5-digit GEOID [001]
# Value: Total Production, Bushels, Corn, 2012: [34,810]
prod <- read.csv('county_production_corn_2012_survey.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]
head(prod)

# Read in Yield Survey Data (Corn, 2012)
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [BULLOCK]
# County.ANSI: Last 3 digits of 5-digit GEOID [011]
# Value: Total Production, Bushels, Corn, 2012: [142.0]
yield <- read.csv('county_yield_corn_2012.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]
head(yield)

# Read in Crop Water Use Data (Corn)
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Crop Water Use, Corn, m3/ha/yr [2032.05924479]
cwu <- read.csv('cwu56_bl.csv')[,c('GEOID','NAME','ALAND','mean')]
head(cwu)

# Read in Income Data
# GEO.id2: 5-digit US GEOID [01001]
# GEO.display.label: County name [Autauga County, Alabama]
# HC02_EST_VC02: Median Income (dollars); Estimate; Households [53773]
income <- read.csv('ACS_12_5YR_S1903/ACS_12_5YR_S1903_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','HC02_EST_VC02')] # note that [-1,...] skips first line. header=T makes sure header is read in before this skip
head(income)

# Read in Population Data
# GEO.id2: 5-digit US GEOID [01001]
# GEO.display.label: County name [Autauga County, Alabama]
# respop72012: Population Estimate (total) (as of July 1) - 2012 [55027]
popul <- read.csv('PEP_2016_PEPANNRES/PEP_2016_PEPANNRES_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','respop72012')]
head(popul)

# Read in On-Farm Grain Storage Data
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [AUTAUGUA]
# County.ANSI: Last 3 digits of 5-digit GEOID [001]
# Value: Total Storage, Bu, All Grains, 2012: [356,763]
stor <- read.csv('usda_county_storage_2012.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]
head(stor)

# Read in Precipitation Data


# Read in all GEOIDs in the country
codes <- read.csv('county_codes.csv')
# Remove 888 (Combined Counties) and 999 (District Counties)
codes <- codes[!(codes$County.ANSI == '888' | codes$County.ANSI == '999'),] 
head(codes)

# Remove Counties with NA value ('Other Counties' data) from Data
prod <- prod[complete.cases(prod),]
stor <- stor[complete.cases(stor),]
yield <- yield[complete.cases(yield),]

# Create GEOID column for Data
prod$GEOID <- paste( formatC( prod$State.ANSI, width=2, format='d', flag='0' ), formatC( prod$County.ANSI, width=3, format='d', flag='0' ), sep='' )
stor$GEOID <- paste( formatC( stor$State.ANSI, width=2, format='d', flag='0' ), formatC( stor$County.ANSI, width=3, format='d', flag='0' ), sep='' )
yield$GEOID <- paste( formatC( yield$State.ANSI, width=2, format='d', flag='0' ), formatC( yield$County.ANSI, width=3, format='d', flag='0' ), sep='' )
codes$GEOID <- paste( formatC( codes$State.ANSI, width=2, format='d', flag='0' ), formatC( codes$County.ANSI, width=3, format='d', flag='0' ), sep='' )
income$GEOID <- formatC( income$GEO.id2, width=5, format='d', flag='0' )
popul$GEOID <- formatC( popul$GEO.id2, width=5, format='d', flag='0' )

if(!file.exists('linear_model_data.csv')){ # If file containing data summary doesn't exist, create it
	data <- data.frame(GEOID=character(),PRODUCTION=numeric(),YIELD=numeric(),CWU=numeric(),LANDAREA=numeric(),INCOME=numeric(),POPULATION=numeric(),STORAGE=numeric(),VWC=numeric())
	for (g in unique(codes$GEOID)){
		# Retrieve variables
		p <- as.numeric(prod[prod$GEOID==g,]$Value) # Production
		y <- as.numeric(yield[yield$GEOID==g,]$Value) # Yield
		c <- as.numeric(cwu[cwu$GEOID==g,]$mean) # CWU
		a <- as.numeric(cwu[cwu$GEOID==g,]$ALAND) #Land Area
		i <- as.numeric(income[income$GEO.id2==g,]$HC02_EST_VC02) # Median Household Income
		pop <- as.numeric(popul[popul$GEO.id2==g,]$respop72012) # Total Population
		s <- as.numeric(stor[stor$GEOID==g,]$Value) # Storage
		
		# VWC [m^3] = Production [Bu] * Yield^-1 [Ac/Bu] * CWU [m^3/Ha] * Conversion [Ha/Ac]
		u <- 0.404686 # [Ha/Ac]
		v <- p / y * c * u # Virtual Water Content of Production
		
		# Change any zero values to 'NA' to allow dataframe writing
		p <- ifelse(length(p)==0,NA,p)
		y <- ifelse(length(y)==0,NA,y)
		c <- ifelse(length(c)==0,NA,c)
		a <- ifelse(length(a)==0,NA,a)
		v <- ifelse(length(v)==0,NA,v)
		i <- ifelse(length(i)==0,NA,i)
		pop <- ifelse(length(pop)==0,NA,pop)
		s <- ifelse(length(s)==0,NA,s)
	
		# Add items to dataframe
		temp <- data.frame(GEOID=g, PRODUCTION=p, YIELD=y, CWU=c, LANDAREA=a, INCOME=i, POPULATION=pop, STORAGE=s,VWC=v)
		data <- rbind( data, temp )
	}
	write.csv(data, 'linear_model_data.csv', row.names=FALSE)
} else { # If file containing data summary already exists, read it in
	data <- read.csv('linear_model_data.csv')
	print('Data already exists; read in from current file')
}

data <- data[complete.cases(data),]
head(data)

vars = c('YIELD','CWU','LANDAREA','INCOME','POPULATION','STORAGE')
coms <- combn( vars, 2 )
coms

cat( 'ANOVA Test Results', file='anova_results.doc')
print('Running ANOVA Tests...')
for (i in seq( from=1, to=length(coms)/2) ) {
	f <- paste( 'PRODUCTION~', paste( coms[1,i], coms[2,i], sep='*' ), sep='' )
	print(f)
	# Two-way ANOVA to test significance of variables
	# H1: Mean (first-term) is equal for all counties
	# H2: Mean (second-term) is equal for all counties
	# H3: There is no interaction between (first-term) and (second-term)
	data.aov <- aov( data=data, formula=as.formula(f) )
	# cat('\n\n', file='anova_results.txt', append=TRUE)
	cat( paste( '\nFormula: ', f,'\n'), file='anova_results.doc', append=TRUE )
	capture.output(summary(data.aov), file='anova_results.doc', append=TRUE)
	cat('\n', file='anova_results.doc', append=TRUE)
	# print(summary(data.aov))
}
print('ANOVA Tests Completed.')
# NORMALIZE OVER AREA


# Define Linear Model
library(car)
linear.model <- function(f,path){
	print('Running Linear Model...')
	print(f)
	LM <<- lm(data=data,formula=as.formula(f)) # assign as global variable
	cat('Linear Model Test Results\n', file=path)
	cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
	capture.output(summary(LM), file=path, append=TRUE)
	print('Linear Model Created.')
}

# First Linear Model
f = 'PRODUCTION~0+INCOME+STORAGE+CWU+YIELD+LANDAREA+YIELD:CWU+YIELD:INCOME+YIELD:STORAGE+CWU:LANDAREA+CWU:INCOME+CWU:STORAGE+LANDAREA:INCOME+INCOME:STORAGE'
path = 'lm_results.doc'
linear.model(f,path)

# Define Linear Model, Edited
f = 'PRODUCTION~0+INCOME+STORAGE+CWU+LANDAREA+YIELD:LANDAREA+CWU:INCOME+CWU:STORAGE+LANDAREA:INCOME'
path='lm_edit_results.doc'
linear.model(f,path)

# Define Linear Model, Edited v2
f = 'PRODUCTION~0+INCOME+STORAGE+CWU+LANDAREA+YIELD:LANDAREA+CWU:INCOME'
path = 'lm_edit_v2_results.doc'
linear.model(f,path)

summary(LM) # final LM to be used

# Plot Residuals
production.hat <- fitted(LM)
invisible(as.data.frame(production.hat))
invisible(as.data.frame(data$PRODUCTION))

png('residuals.png')
plot(x=production.hat,y=data$PRODUCTION,xlab='PRODUCTION Model Results',ylab='PRODUCTION Raw Data',main='Residual Plot of PRODUCTION')
abline(0,1,col='blue')
dev.off()

### TEST FOR NORMALITY ###
# Visualize Normality
png('normality.png')
LM.stdres <- rstandard(LM) # standard residuals
qqnorm(LM.stdres)
qqline(LM.stdres)
dev.off()

# Quantitative Check for Normality
# Shapiro test... 
# Ho: resid~N(0,sigma)
# Ha: resid not normally distributed
capture.output(shapiro.test(LM.stdres), file='shapiro_test.doc') # p < alpha --> do not reject null (resid normally dist)

# Constant Variance
# Visualize constant variance, manually
png('manual_constvar.png')
LM.res <- resid(LM)
plot(data$PRODUCTION,LM.res)
abline(0,0,lwd=1.5)
dev.off()

# Quantitative (and visual) check for Constant Variance
# Tukey test... 
# Ho: Quadratic term in trend line is zero... a*x^2 + b*x + c, a = 0
# Ha: Quadratic term is not zero <-- heteroscedastic, a != 0
png('residual_plots.png')
capture.output(residualPlots(LM), file='tukey_test.doc') # this returns resid plot for all variables, & Tukey p-values
dev.off()

# Quantitative check for Independence
# Durbin-Watson test...
# Ho: Autocorrelation = 0
# Ha: Autocorrelation != 0
library(lmtest)
capture.output(dwtest(LM,alternative='two.sided'),file='dwtest.doc') # two.sided, greater, or less
# Variance Inflation Factor
vif(LM)
capture.output(vif(LM),'vif.doc') # Relationship between variables. Want low values; high means variables
		 # are very related and are likely redundant
