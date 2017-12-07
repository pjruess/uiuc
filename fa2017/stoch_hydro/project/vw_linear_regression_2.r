### Read in Data

# Read in Production Survey Data (Corn, 2012)
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [AUTAUGUA]
# County.ANSI: Last 3 digits of 5-digit GEOID [001]
# Value: Total Production, Bushels, Corn, 2012 [34,810]
prod <- read.csv('data/county_production_corn_2012_survey.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]

# Read in Yield Survey Data (Corn, 2012)
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [BULLOCK]
# County.ANSI: Last 3 digits of 5-digit GEOID [011]
# Value: Total Production, Bushels, Corn, 2012 [142.0]
yield <- read.csv('data/county_yield_corn_2012.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]

# Read in Fertilizer Survey Data (All crops)
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [BULLOCK]
# County.ANSI: Last 3 digits of 5-digit GEOID [011]
# Value: Total Production, Bushels, Corn, 2012 [142.0]
fert <- read.csv('data/county_fertilizer_2012.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]

# Read in Crop Water Use Data (Corn)
# bl: Blue; gn_ir: Green, Irrigated; gn_rf: Green, Rainfed
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Crop Water Use, Corn, m3/ha/yr [2032.05924479] (blue)
cwu_bl <- read.csv('data/cwu56_bl.csv')[,c('GEOID','NAME','ALAND','mean')]
cwu_bl$GEOID <- formatC( cwu_bl$GEOID, width=5, format='d', flag='0' )
cwu_gn_ir <- read.csv('data/cwu56_gn_ir.csv')[,c('GEOID','NAME','mean')]
cwu_gn_ir$GEOID <- formatC( cwu_gn_ir$GEOID, width=5, format='d', flag='0' )
cwu_gn_rf <- read.csv('data/cwu56_gn_rf.csv')[,c('GEOID','NAME','mean')]
cwu_gn_rf$GEOID <- formatC( cwu_gn_rf$GEOID, width=5, format='d', flag='0' )

# Read in Income Data
# GEO.id2: 5-digit US GEOID [01001]
# GEO.display.label: County name [Autauga County, Alabama]
# HC02_EST_VC02: Median Income (dollars); Estimate; Households [53773]
income <- read.csv('data/ACS_12_5YR_S1903/ACS_12_5YR_S1903_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','HC02_EST_VC02')] # note that [-1,...] skips first line. header=T makes sure header is read in before this skip

# Read in Population Data
# GEO.id2: 5-digit US GEOID [01001]
# GEO.display.label: County name [Autauga County, Alabama]
# respop72012: Population Estimate (total) (as of July 1) - 2012 [55027]
popul <- read.csv('data/PEP_2016_PEPANNRES/PEP_2016_PEPANNRES_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','respop72012')]

# Read in On-Farm Grain Storage Data
# State: State Name [ALABAMA]
# State.ANSI: First 2 digits of 5-digit GEOID [01]
# County: County Name [AUTAUGUA]
# County.ANSI: Last 3 digits of 5-digit GEOID [001]
# Value: Total Storage, Bu, All Grains, 2012 [356,763]
stor <- read.csv('data/usda_county_storage_2012.csv')[,c('State','State.ANSI','County','County.ANSI','Value')]

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
precip <- read.csv('data/prism_precipitation_2012.csv')[,c('GEOID','NAME','mean')]
precip$GEOID <- formatC( precip$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
temp.mean <- read.csv('data/prism_temp_mean_2012.csv')[,c('GEOID','NAME','mean')]
temp.mean$GEOID <- formatC( temp.mean$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
temp.min <- read.csv('data/prism_temp_min_2012.csv')[,c('GEOID','NAME','mean')]
temp.min$GEOID <- formatC( temp.min$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
temp.max <- read.csv('data/prism_temp_max_2012.csv')[,c('GEOID','NAME','mean')]
temp.max$GEOID <- formatC( temp.max$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
temp.dew <- read.csv('data/prism_temp_dewpoint_mean_2012.csv')[,c('GEOID','NAME','mean')]
temp.dew$GEOID <- formatC( temp.dew$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
vapres.min <- read.csv('data/prism_vapor_pressure_min_2012.csv')[,c('GEOID','NAME','mean')]
vapres.min$GEOID <- formatC( vapres.min$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
vapres.max <- read.csv('data/prism_vapor_pressure_max_2012.csv')[,c('GEOID','NAME','mean')]
vapres.max$GEOID <- formatC( vapres.max$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
# STATEFP: First 2 digits of 5-digit GEOID [01]
# COUNTYFP: Last 3 digits of 5-digit GEOID [001]
# GEOID: 5-digit US GEOID [01001]
# NAME: County Name [Autaugua]
# ALAND: Land Area [1539609015]
# mean: Average Total Annual Precipitation, 2012, mm [1353.09273897]
elev <- read.csv('data/prism_elevation_1981-2010.csv')[,c('GEOID','NAME','mean')]
elev$GEOID <- formatC( elev$GEOID, width=5, format='d', flag='0' )

# Read in all GEOIDs in the country
codes <- read.csv('data/county_codes.csv')
# Remove 888 (Combined Counties) and 999 (District Counties)
codes <- codes[!(codes$County.ANSI == '888' | codes$County.ANSI == '999'),] 

# Remove Counties with NA value ('Other Counties' data) from Data
prod <- prod[complete.cases(prod),]
stor <- stor[complete.cases(stor),]
yield <- yield[complete.cases(yield),]
fert <- fert[complete.cases(fert),]

# Create GEOID column for Data
prod$GEOID <- paste( formatC( prod$State.ANSI, width=2, format='d', flag='0' ), formatC( prod$County.ANSI, width=3, format='d', flag='0' ), sep='' )
stor$GEOID <- paste( formatC( stor$State.ANSI, width=2, format='d', flag='0' ), formatC( stor$County.ANSI, width=3, format='d', flag='0' ), sep='' )
yield$GEOID <- paste( formatC( yield$State.ANSI, width=2, format='d', flag='0' ), formatC( yield$County.ANSI, width=3, format='d', flag='0' ), sep='' )
fert$GEOID <- paste( formatC( fert$State.ANSI, width=2, format='d', flag='0' ), formatC( fert$County.ANSI, width=3, format='d', flag='0' ), sep='' )
codes$GEOID <- paste( formatC( codes$State.ANSI, width=2, format='d', flag='0' ), formatC( codes$County.ANSI, width=3, format='d', flag='0' ), sep='' )
income$GEOID <- formatC( income$GEO.id2, width=5, format='d', flag='0' )
popul$GEOID <- formatC( popul$GEO.id2, width=5, format='d', flag='0' )

# Summarize regressors as a dataframe
lm_path = 'results/linear_model_data.csv'

if(!file.exists(lm_path)){ # If file containing data summary doesn't exist, create it
	data <- data.frame(GEOID=character(),PRODUCTION=numeric(),YIELD=numeric(),FERTILIZER=numeric(),CWU_BL=numeric(),CWU_GN_IR=numeric(),CWU_GN_RF=numeric(),LANDAREA=numeric(),INCOME=numeric(),POPULATION=numeric(),STORAGE=numeric(),PRECIPITATION=numeric(),MEANTEMP=numeric(),MINTEMP=numeric(),MAXTEMP=numeric(),DEWPOINT=numeric(),MINVAPORPRES=numeric(),MAXVAPORPRES=numeric(),ELEVATION=numeric(),VWC_BL=numeric(),VWC_GN_IR=numeric(),VWC_GN_RF=numeric())
	for (g in unique(codes$GEOID)){
		# Retrieve variables
		p <- as.numeric(prod[prod$GEOID==g,]$Value) # Production
		y <- as.numeric(yield[yield$GEOID==g,]$Value) # Yield
		f <- as.numeric(fert[fert$GEOID==g,]$Value) # Yield
		cb <- as.numeric(cwu_bl[cwu_bl$GEOID==g,]$mean) # Crop Water Use, Blue
		cgi <- as.numeric(cwu_gn_ir[cwu_gn_ir$GEOID==g,]$mean) # Crop Water Use, Green, Irrigated
		cgr <- as.numeric(cwu_gn_rf[cwu_gn_rf$GEOID==g,]$mean) # Crop Water Use, Green, Rainfed
		a <- as.numeric(cwu_bl[cwu_bl$GEOID==g,]$ALAND) #Land Area
		i <- as.numeric(income[income$GEO.id2==g,]$HC02_EST_VC02) # Median Household Income
		pop <- as.numeric(popul[popul$GEO.id2==g,]$respop72012) # Total Population
		s <- as.numeric(stor[stor$GEOID==g,]$Value) # Storage
		prcp <- as.numeric(precip[precip$GEOID==g,]$mean) # Precipitation
		tmean <- as.numeric(temp.mean[temp.mean$GEOID==g,]$mean) # Mean Temp
		tmin <- as.numeric(temp.min[temp.min$GEOID==g,]$mean) # Min Temp
		tmax <- as.numeric(temp.max[temp.max$GEOID==g,]$mean) # Max Temp
		dew <- as.numeric(temp.dew[temp.dew$GEOID==g,]$mean) # Mean Dewpoint Temp
		vapmin <- as.numeric(vapres.min[vapres.min$GEOID==g,]$mean) # Min Vapor Pressure
		vapmax <- as.numeric(vapres.max[vapres.max$GEOID==g,]$mean) # Max Vapor Pressure
		e <- as.numeric(elev[elev$GEOID==g,]$mean) # Elevation

		# VWC [m^3] = Production [Bu] * Yield^-1 [Ac/Bu] * CWU [m^3/Ha] * Conversion [Ha/Ac]
		u <- 0.404686 # [Ha/Ac]
		vb <- p / y * cb * u # Virtual Water Content of Production
		vgi <- p / y * cgi * u # Virtual Water Content of Production
		vgr <- p / y * cgr * u # Virtual Water Content of Production
		
		# Change any zero values to 'NA' to allow dataframe writing
		p <- ifelse(length(p)==0,NA,p)
		y <- ifelse(length(y)==0,NA,y)
		f <- ifelse(length(f)==0,NA,f)
		cb <- ifelse(length(cb)==0,NA,cb)
		cgi <- ifelse(length(cgi)==0,NA,cgi)
		cgr <- ifelse(length(cgr)==0,NA,cgr)
		a <- ifelse(length(a)==0,NA,a)
		vb <- ifelse(length(vb)==0,NA,vb)
		vgi <- ifelse(length(vgi)==0,NA,vgi)
		vgr <- ifelse(length(vgr)==0,NA,vgr)
		i <- ifelse(length(i)==0,NA,i)
		pop <- ifelse(length(pop)==0,NA,pop)
		s <- ifelse(length(s)==0,NA,s)
		prcp <- ifelse(length(prcp)==0,NA,prcp)
		tmean <- ifelse(length(tmean)==0,NA,tmean)
		tmin <- ifelse(length(tmin)==0,NA,tmin)
		tmax <- ifelse(length(tmax)==0,NA,tmax)
		dew <- ifelse(length(dew)==0,NA,dew)
		vapmin <- ifelse(length(vapmin)==0,NA,vapmin)
		vapmax <- ifelse(length(vapmax)==0,NA,vapmax)
		e <- ifelse(length(e)==0,NA,e)

		# Add items to dataframe
		temp <- data.frame(GEOID=g, PRODUCTION=p, YIELD=y, FERTILIZER=f, CWU_BL=cb, CWU_GN_IR=cgi, CWU_GN_RF=cgr, LANDAREA=a, INCOME=i, POPULATION=pop, STORAGE=s, PRECIPITATION=prcp, MEANTEMP=tmean, MINTEMP=tmin, MAXTEMP=tmax, DEWPOINT=dew, MINVAPORPRES=vapmin, MAXVAPORPRES=vapmax, ELEVATION=e, VWC_BL=vb, VWC_GN_IR=vgi, VWC_GN_RF=vgr)
		data <- rbind( data, temp )
	}
	write.csv(data, lm_path, row.names=FALSE)
} else { # If file containing data summary already exists, read it in
	data <- read.csv(lm_path)
	print('Data already exists; read in from current file')
}

# Keep only counties for which all regressors are available
data <- data[complete.cases(data),]

# Re-organize Linear Model Data by steps and print to output .csv 
# data$GEOID <- as.numeric(as.character(data$GEOID))
max.vals <- apply(data[,-1], 2, function(x) max(sapply(x,as.numeric), na.rm=TRUE))
min.vals <- apply(data[-1], 2, function(x) min(sapply(x,as.numeric), na.rm=TRUE))
ranges <- max.vals - min.vals
s <- 50
steps <- ranges / s 
data <- data.frame(cbind(data[1],t(t(data[,-1]) / steps)))
write.csv(data, 'results/linear_model_data_steps.csv', row.names=FALSE)

# Collect combinations of variables for ANOVA 'VWC_BL','VWC_GN_IR','VWC_GN_RF',
vars = c('PRODUCTION','FERTILIZER','CWU_BL','CWU_GN_IR','CWU_GN_RF','LANDAREA','INCOME','POPULATION','STORAGE','PRECIPITATION','MEANTEMP','MINTEMP','MAXTEMP','DEWPOINT','MINVAPORPRES','MAXVAPORPRES','ELEVATION','VWC_BL','VWC_GN_IR','VWC_GN_RF')
coms <- combn( vars, 2 )

# Run ANOVA test
anova_path = 'results/anova.doc'
cat( 'ANOVA Test Results', file=anova_path)
print('Running ANOVA Tests...')
for (i in seq( from=1, to=length(coms)/2) ) {
	f <- paste( 'YIELD~', paste( coms[1,i], coms[2,i], sep='*' ), sep='' )
	# print(f)
	# Two-way ANOVA to test significance of variables
	# H1: Mean (first-term) is equal for all counties
	# H2: Mean (second-term) is equal for all counties
	# H3: There is no interaction between (first-term) and (second-term)
	data.aov <- aov( data=data, formula=as.formula(f) )
	# cat('\n\n', file='anova_results.txt', append=TRUE)
	cat( paste( '\nFormula: ', f,'\n'), file=anova_path, append=TRUE )
	capture.output(summary(data.aov), file=anova_path, append=TRUE)
	cat('\n', file=anova_path, append=TRUE)
	# print(summary(data.aov))
}
print('ANOVA Tests Completed.')

# library(penalized)
# 
# fit <- penalized(YIELD~0+INCOME+STORAGE+CWU+PRODUCTION+LANDAREA+PRECIPITATION+PRODUCTION:CWU+PRODUCTION:INCOME+PRODUCTION:STORAGE+PRODUCTION:PRECIPITATION+CWU:LANDAREA+CWU:INCOME+CWU:STORAGE+CWU:PRECIPITATION+LANDAREA:PRECIPITATION+INCOME:STORAGE+INCOME:PRECIPITATION+POPULATION:STORAGE+STORAGE:PRECIPITATION, data=data, lambda1=1)
# 
# residuals(fit)
# 
# fitted(fit)
# 
# basesurv(fit)

# Define Linear Model
linear.model <- function(f,path,ranker=NULL){
	print('Running Linear Model...')
	print(f)
	LM <- lm(data=data,formula=as.formula(f)) # assign as global variable
	if ( is.element(ranker, c('both','forward','backward') ) ==TRUE ) {
		path <- paste(strsplit(path,'[.]')[[1]][1],'_',ranker,'.doc',sep='')
		step <- stepAIC(LM, direction=ranker)
		cat('Linear Model Test Results\n', file=path)
		cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
		capture.output(summary(LM), file=path, append=TRUE)
		# capture.output(subset(LM,delta<10), file=path, append=TRUE)
	} else if ( is.element(ranker, c('AIC','BIC') ) == TRUE ) {
		path <- paste(strsplit(path,'[.]')[[1]][1],'_',ranker,'.doc',sep='')
		library(MuMIn)
		options(na.action='na.fail')
		LM <- dredge(LM, rank=ranker)
		print(coefTable(LM))
		# print(subset(LM,delta<5))
		cat('Linear Model Test Results\n', file=path)
		cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
		capture.output(subset(LM,delta<10), file=path, append=TRUE)
	} else { 
		cat('Linear Model Test Results\n', file=path)
		cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
		capture.output(summary(LM), file=path, append=TRUE)
		print(paste('Linear Model Created at',path))
	}
	return(LM)
}

# Select Linear Model Variables
library(car)
library(MASS)
f = 'YIELD~MAXTEMP+DEWPOINT+MAXVAPORPRES+ELEVATION'
path = 'results/linear_model.doc'
linear.model(f,path,ranker='AIC')
# linear.model(f,path,ranker='BIC')

# Step-wise Linear Regression
# f = 'YIELD~MINTEMP+DEWPOINT+MAXVAPORPRES+ELEVATION'
LM <- linear.model(f,path,ranker='both')
# linear.model(f,path,ranker='forward')
# linear.model(f,path,ranker='backward')

# # First Linear Model
# f = 'YIELD~0+PRODUCTION+CWU_BL+CWU_GN_RF+CWU_GN_IR+LANDAREA+INCOME+POPULATION+STORAGE+PRECIPITATION+VWC_BL+VWC_GN_IR+VWC_GN_RF'
# path = 'results/linear_model.doc'
# linear.model(f,path,ranker='AIC')
# 
# # Define Linear Model, v2
# f = 'YIELD~0+INCOME+CWU+LANDAREA+INCOME:PRODUCTION+PRODUCTION:PRECIPITATION+CWU:LANDAREA+CWU:PRECIPITATION+LANDAREA:PRECIPITATION+INCOME:PRECIPITATION+STORAGE:PRECIPITATION'
# path= 'results/linear_model_v2.doc'
# linear.model(f,path)
# 
# # Define Linear Model, v3
# f = 'YIELD~0+INCOME+STORAGE+CWU+LANDAREA+PRODUCTION:LANDAREA+CWU:INCOME'
# path = 'results/linear_model_v3.doc'
# linear.model(f,path)
# 
summary(LM) # final LM to be used

# Plot Residuals
yield.hat <- fitted(LM)
invisible(as.data.frame(yield.hat))
invisible(as.data.frame(data$YIELD))

png('results/residuals.png')
plot(x=yield.hat,y=data$YIELD,xlab='YIELD Model Results',ylab='YIELD Raw Data',main='Residual Plot of YIELD')
abline(0,1,col='blue')
dev.off()

### TEST FOR NORMALITY ###
# Visualize Normality
png('results/normality.png')
LM.stdres <- rstandard(LM) # standard residuals
qqnorm(LM.stdres)
qqline(LM.stdres)
dev.off()

# Quantitative Check for Normality
# Shapiro test... 
# Ho: resid~N(0,sigma)
# Ha: resid not normally distributed
capture.output(shapiro.test(LM.stdres), file='results/shapiro_test.doc') # p < alpha --> do not reject null (resid normally dist)

# Constant Variance
# Visualize constant variance, manually
png('results/manual_constvar.png')
LM.res <- resid(LM)
plot(x=yield.hat, y=LM.res, xlab='YIELD Fitted Data', ylab='Linear Model Residuals', main='Covariance Plot')
abline(0,0,lwd=1.5)
dev.off()

# Quantitative (and visual) check for Constant Variance
# Tukey test... 
# Ho: Quadratic term in trend line is zero... a*x^2 + b*x + c, a = 0
# Ha: Quadratic term is not zero <-- heteroscedastic, a != 0
png('results/residual_plots.png')
capture.output(residualPlots(LM), file='results/tukey_test.doc') # this returns resid plot for all variables, & Tukey p-values
dev.off()

# Quantitative check for Independence
# Durbin-Watson test...
# Ho: Autocorrelation = 0
# Ha: Autocorrelation != 0
library(lmtest)
capture.output(dwtest(LM,alternative='two.sided'),file='results/dwtest.doc') # two.sided, greater, or less
# Variance Inflation Factor
vif(LM)
capture.output(vif(LM),'results/vif.doc') # Relationship between variables. Want low values; high means variables
		 # are very related and are likely redundant
