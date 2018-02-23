### Read in Data

# Read in Crop Water Use Data (Corn)
# bl: Blue; gn_ir: Green, Irrigated; gn_rf: Green, Rainfed
cwu_bl <- read.csv('data/cwu56_bl.csv')[,c('GEOID','NAME','ALAND','mean')]
cwu_bl$GEOID <- formatC( cwu_bl$GEOID, width=5, format='d', flag='0' )
cwu_gn_ir <- read.csv('data/cwu56_gn_ir.csv')[,c('GEOID','NAME','mean')]
cwu_gn_ir$GEOID <- formatC( cwu_gn_ir$GEOID, width=5, format='d', flag='0' )
cwu_gn_rf <- read.csv('data/cwu56_gn_rf.csv')[,c('GEOID','NAME','mean')]
cwu_gn_rf$GEOID <- formatC( cwu_gn_rf$GEOID, width=5, format='d', flag='0' )

# Read in Precipitation Data
precip <- read.csv('data/prism_csvs/prism_ppt_1996-2005.csv')[,c('GEOID','NAME','mean')]
precip$GEOID <- formatC( precip$GEOID, width=5, format='d', flag='0' )

# Read in Mean Temperature Data
temp.mean <- read.csv('data/prism_csvs/prism_tmean_1996-2005.csv')[,c('GEOID','NAME','mean')]
temp.mean$GEOID <- formatC( temp.mean$GEOID, width=5, format='d', flag='0' )

# Read in Minimum Temperature Data
temp.min <- read.csv('data/prism_csvs/prism_tmin_1996-2005.csv')[,c('GEOID','NAME','mean')]
temp.min$GEOID <- formatC( temp.min$GEOID, width=5, format='d', flag='0' )

# Read in Maximum Temperature Data
temp.max <- read.csv('data/prism_csvs/prism_tmax_1996-2005.csv')[,c('GEOID','NAME','mean')]
temp.max$GEOID <- formatC( temp.max$GEOID, width=5, format='d', flag='0' )

# Read in Mean Dewpoint Temperature Data
temp.dew <- read.csv('data/prism_csvs/prism_tdmean_1996-2005.csv')[,c('GEOID','NAME','mean')]
temp.dew$GEOID <- formatC( temp.dew$GEOID, width=5, format='d', flag='0' )

# Read in Minimum Vapor Pressure Data
vapres.min <- read.csv('data/prism_csvs/prism_vpdmin_1996-2005.csv')[,c('GEOID','NAME','mean')]
vapres.min$GEOID <- formatC( vapres.min$GEOID, width=5, format='d', flag='0' )

# Read in Maximum Vapor Pressure Data
vapres.max <- read.csv('data/prism_csvs/prism_vpdmax_1996-2005.csv')[,c('GEOID','NAME','mean')]
vapres.max$GEOID <- formatC( vapres.max$GEOID, width=5, format='d', flag='0' )

# Read in Elevation Data
elev <- read.csv('data/prism_csvs/prism_dem_1981-2010.csv')[,c('GEOID','NAME','mean')]
elev$GEOID <- formatC( elev$GEOID, width=5, format='d', flag='0' )

# Read in Income Data (dollars)
income <- read.csv('data/ACS_12_5YR_S1903/ACS_12_5YR_S1903_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','HC02_EST_VC02')]

# Read in Population Data (people)
popul <- read.csv('data/PEP_2016_PEPANNRES/PEP_2016_PEPANNRES_with_ann.csv',header=T)[-1,c('GEO.id2','GEO.display.label','respop72012')]

# Read in all GEOIDs in the country
codes <- read.csv('data/county_codes.csv')
# Remove 888 (Combined Counties) and 999 (District Counties)
codes <- codes[!(codes$County.ANSI == '888' | codes$County.ANSI == '999'),] 
# Create GEOID column for Data
codes$GEOID <- paste( formatC( codes$State.ANSI, width=2, format='d', flag='0' ), formatC( codes$County.ANSI, width=3, format='d', flag='0' ), sep='' )

# Summarize regressors as a dataframe
lm_path = 'log_results/linear_model_data.csv'

if(!file.exists(lm_path)){ # If file containing data summary doesn't exist, create it
	data <- data.frame(GEOID=character(),CWU_BL=numeric(),CWU_GN_IR=numeric(),CWU_GN_RF=numeric(),CWU_BL_LOG=numeric(),CWU_GN_IR_LOG=numeric(),CWU_GN_RF_LOG=numeric(),LANDAREA=numeric(),PRECIPITATION=numeric(),MEANTEMP=numeric(),MINTEMP=numeric(),MAXTEMP=numeric(),DEWPOINT=numeric(),MINVAPORPRES=numeric(),MAXVAPORPRES=numeric(),ELEVATION=numeric())
	for (g in unique(codes$GEOID)){
		# Retrieve variables
		cb <- as.numeric(cwu_bl[cwu_bl$GEOID==g,]$mean) # Crop Water Use, Blue
		cgi <- as.numeric(cwu_gn_ir[cwu_gn_ir$GEOID==g,]$mean) # Crop Water Use, Green, Irrigated
		cgr <- as.numeric(cwu_gn_rf[cwu_gn_rf$GEOID==g,]$mean) # Crop Water Use, Green, Rainfed
		cblog <- log(as.numeric(cwu_bl[cwu_bl$GEOID==g,]$mean)) # Crop Water Use, Blue
		cgilog <- log(as.numeric(cwu_gn_ir[cwu_gn_ir$GEOID==g,]$mean)) # Crop Water Use, Green, Irrigated
		cgrlog <- log(as.numeric(cwu_gn_rf[cwu_gn_rf$GEOID==g,]$mean)) # Crop Water Use, Green, Rainfed
		a <- as.numeric(cwu_bl[cwu_bl$GEOID==g,]$ALAND) #Land Area
		prcp <- as.numeric(precip[precip$GEOID==g,]$mean) # Precipitation
		tmean <- as.numeric(temp.mean[temp.mean$GEOID==g,]$mean) # Mean Temp
		tmin <- as.numeric(temp.min[temp.min$GEOID==g,]$mean) # Min Temp
		tmax <- as.numeric(temp.max[temp.max$GEOID==g,]$mean) # Max Temp
		dew <- as.numeric(temp.dew[temp.dew$GEOID==g,]$mean) # Mean Dewpoint Temp
		vapmin <- as.numeric(vapres.min[vapres.min$GEOID==g,]$mean) # Min Vapor Pressure
		vapmax <- as.numeric(vapres.max[vapres.max$GEOID==g,]$mean) # Max Vapor Pressure
		e <- as.numeric(elev[elev$GEOID==g,]$mean) # Elevation
		# inc <- as.numeric(income[income$GEO.id2==g,]$HC02_EST_VC02) # Median Household Income
		# pop <- as.numeric(popul[popul$GEO.id2==g,]$respop72012) # Total Population

		# Change any zero values to 'NA' to allow dataframe writing
		cb <- ifelse(length(cb)==0,NA,cb)
		cgi <- ifelse(length(cgi)==0,NA,cgi)
		cgr <- ifelse(length(cgr)==0,NA,cgr)
		cblog <- ifelse(length(cblog)==0,NA,cblog)
		cgilog <- ifelse(length(cgilog)==0,NA,cgilog)
		cgrlog <- ifelse(length(cgrlog)==0,NA,cgrlog)
		a <- ifelse(length(a)==0,NA,a)
		prcp <- ifelse(length(prcp)==0,NA,prcp)
		tmean <- ifelse(length(tmean)==0,NA,tmean)
		tmin <- ifelse(length(tmin)==0,NA,tmin)
		tmax <- ifelse(length(tmax)==0,NA,tmax)
		dew <- ifelse(length(dew)==0,NA,dew)
		vapmin <- ifelse(length(vapmin)==0,NA,vapmin)
		vapmax <- ifelse(length(vapmax)==0,NA,vapmax)
		e <- ifelse(length(e)==0,NA,e)
		# inc <- ifelse(length(inc)==0,NA,inc)
		# pop <- ifelse(length(pop)==0,NA,pop)

		# Add items to dataframe
		temp <- data.frame(GEOID=g, CWU_BL=cb, CWU_GN_IR=cgi, CWU_GN_RF=cgr, CWU_BL_LOG=cblog, CWU_GN_IR_LOG=cgilog, CWU_GN_RF_LOG=cgrlog, LANDAREA=a, PRECIPITATION=prcp, MEANTEMP=tmean, MINTEMP=tmin, MAXTEMP=tmax, DEWPOINT=dew, MINVAPORPRES=vapmin, MAXVAPORPRES=vapmax, ELEVATION=e)
		data <- rbind( data, temp )
	}
	write.csv(data, lm_path, row.names=FALSE)
} else { # If file containing data summary already exists, read it in
	data <- read.csv(lm_path)
	print('Data already exists; read in from current file')
}

# Keep only counties for which all regressors are available
data <- data[complete.cases(data),]

# Add interaction terms manually (for simplicity later on)
data['TEMPandDEW'] = data$MEANTEMP*data$DEWPOINT
data['MINandMAXVAP'] = data$MINVAPORPRES*data$MAXVAPORPRES

# Re-organize Linear Model Data by steps and print to output .csv 
# data$GEOID <- as.numeric(as.character(data$GEOID))
max.vals <- apply(data[,-1], 2, function(x) max(sapply(x,as.numeric), na.rm=TRUE))
min.vals <- apply(data[-1], 2, function(x) min(sapply(x,as.numeric), na.rm=TRUE))
ranges <- max.vals - min.vals
s <- 50
steps <- ranges / s 
data <- data.frame(cbind(data[1],t(t(data[,-1]) / steps)))
write.csv(data, 'log_results/linear_model_data_steps.csv', row.names=FALSE)

# Run ANOVA test
run_anova <- function(obj,vars,path){
	vars = vars[vars != obj]
	print(vars)
	coms <- combn( vars, 2 )
	cat( 'ANOVA Test Results', file=path)
	print('Running ANOVA Tests...')
	for (i in seq( from=1, to=length(coms)/2) ) {
		f <- paste( obj,'~', paste( coms[1,i], coms[2,i], sep='*' ), sep='' )
		# Two-way ANOVA to test significance of variables
		# H1: Mean (first-term) is equal for all counties
		# H2: Mean (second-term) is equal for all counties
		# H3: There is no interaction between (first-term) and (second-term)
		data.aov <- aov( data=data, formula=as.formula(f) )
		cat( paste( '\nFormula: ', f,'\n'), file=path, append=TRUE )
		capture.output(summary(data.aov), file=path, append=TRUE)
		cat('\n', file=path, append=TRUE)
	}
	print('ANOVA Tests Completed.')
}

# Collect combinations of variables for ANOVA
vars = c('CWU_BL','CWU_GN_IR','CWU_GN_RF','LANDAREA','PRECIPITATION','MEANTEMP','MINTEMP','MAXTEMP','DEWPOINT','MINVAPORPRES','MAXVAPORPRES','ELEVATION')

run_anova(obj='CWU_BL_LOG',vars=vars,path='log_results/anova_cwu_bl.doc')
run_anova(obj='CWU_GN_IR_LOG',vars=vars,path='log_results/anova_cwu_gn_ir.doc')
run_anova(obj='CWU_GN_RF_LOG',vars=vars,path='log_results/anova_cwu_gn_rf.doc')

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
		LM <- dredge(LM, rank=ranker, subset = !(TEMPandDEW&&MEANTEMP) && !(TEMPandDEW&&MINTEMP) && !(TEMPandDEW&&MAXTEMP) && !(TEMPandDEW&&DEWPOINT) && !(DEWPOINT&&MEANTEMP) && !(DEWPOINT&&MINTEMP) && !(DEWPOINT&&MAXTEMP) && !(MINandMAXVAP&&MINVAPORPRES) && !(MINandMAXVAP&&MAXVAPORPRES) && !(MEANTEMP&&MINTEMP) && !(MEANTEMP&&MAXTEMP) && !(MINTEMP&&MAXTEMP) && !(MINVAPORPRES&&MAXVAPORPRES) )
		options(na.action='na.omit')
		# print(coefTable(LM))
		cat('Linear Model Test Results\n', file=path)
		cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
		capture.output(subset(LM,delta<100), file=path, append=TRUE)
	} else { 
		cat('Linear Model Test Results\n', file=path)
		cat( paste( 'Formula: ', f, '\n'), file=path, append=TRUE)
		capture.output(summary(LM), file=path, append=TRUE)
	}
	print(paste('Linear Model Created at',path))
	return(LM)
}

### Create Linear Models with selected variables
library(car)
library(MASS)

# Blue CWU
f = 'CWU_BL_LOG~INCOME+MAXVAPORPRES+MEANTEMP+POPULATION'
path = 'log_results/linear_model_cwu_bl.doc'
LM_BL <- linear.model(f,path,ranker='both')
summary(LM_BL) # final LM to be used
f = 'CWU_BL_LOG~PRECIPITATION+MEANTEMP+MINTEMP+MAXTEMP+DEWPOINT+TEMPandDEW+MINVAPORPRES+MAXVAPORPRES+MINVAPORPRES+MINandMAXVAP+ELEVATION'
linear.model(f,path,ranker='AIC')

# Green, Irrigated CWU
f = 'CWU_GN_IR_LOG~PRECIPITATION+DEWPOINT+MINVAPORPRES'
path = 'log_results/linear_model_cwu_gn_ir.doc'
LM_GN_IR <- linear.model(f,path,ranker='both')
summary(LM_GN_IR) # final LM to be used
f = 'CWU_GN_IR_LOG~PRECIPITATION+MEANTEMP+MINTEMP+MAXTEMP+DEWPOINT+TEMPandDEW+MINVAPORPRES+MAXVAPORPRES+MINVAPORPRES+MINandMAXVAP+ELEVATION'
linear.model(f,path,ranker='AIC')

# Green, Rainfed CWU
f = 'CWU_GN_RF_LOG~PRECIPITATION+DEWPOINT+MINVAPORPRES'
path = 'log_results/linear_model_cwu_gn_rf.doc'
LM_GN_RF <- linear.model(f,path,ranker='both')
summary(LM_GN_RF) # final LM to be used
f = 'CWU_GN_RF_LOG~PRECIPITATION+MEANTEMP+MINTEMP+MAXTEMP+DEWPOINT+TEMPandDEW+MINVAPORPRES+MAXVAPORPRES+MINVAPORPRES+MINandMAXVAP+ELEVATION'
linear.model(f,path,ranker='AIC')

### Check Assumptions
check.assumptions <- function(LM,ext){
	# Plot Residuals
	cwu.hat <- fitted(LM)
	invisible(as.data.frame(cwu.hat))
	invisible(as.data.frame(data[[ext]]))
	
	png(paste('log_results/residuals_',ext,'.png',sep=''))
	plot(x=cwu.hat,y=data[[ext]],xlab=paste(ext,'Model Results'),ylab=paste(ext,'Raw Data'),main=paste('Residual Plot of',ext))
	abline(0,1,col='blue')
	dev.off()
	
	### TEST FOR NORMALITY ###
	# Visualize Normality
	png(paste('log_results/normality_',ext,'.png',sep=''))
	LM.stdres <- rstandard(LM) # standard residuals
	qqnorm(LM.stdres)
	qqline(LM.stdres)
	dev.off()
	
	# Quantitative Check for Normality
	# Shapiro test... 
	# Ho: resid~N(0,sigma)
	# Ha: resid not normally distributed
	capture.output(shapiro.test(LM.stdres), file=paste('log_results/shapiro_test_',ext,'.doc',sep='')) # p < alpha --> do not reject null (resid normally dist)
	
	### TEST FOR CONSTANT VARIANCE ###
	# Visualize constant variance, manually
	LM.res <- resid(LM)
	vars <- c('ELEVATION','MAXTEMP','MAXVAPORPRES','PRECIPITATION')
	for (var in vars) {
		png(paste('log_results/manual_constvar_',ext,'_',var,'.png',sep=''))
		plot(x=data[[var]], y=LM.res, xlab=paste(ext,var), ylab='Linear Model Residuals', main='Covariance Plot')
		abline(0,0,lwd=1.5)
		dev.off()
	}

	# Quantitative (and visual) check for Constant Variance
	# Tukey test... 
	# Ho: Quadratic term in trend line is zero... a*x^2 + b*x + c, a = 0
	# Ha: Quadratic term is not zero <-- heteroscedastic, a != 0
	png(paste('log_results/residual_plots_',ext,'.png',sep=''))
	capture.output(residualPlots(LM), file=paste('log_results/tukey_test_',ext,'.doc',sep='')) # this returns resid plot for all variables, & Tukey p-values
	dev.off()
	
	### TEST FOR INDEPENDENCE ###
	# Quantitative check for Independence
	# Durbin-Watson test...
	# Ho: Autocorrelation = 0
	# Ha: Autocorrelation != 0
	library(lmtest)
	capture.output(dwtest(LM,alternative='two.sided'),file=paste('log_results/dwtest_',ext,'.doc',sep='')) # two.sided, greater, or less
	# Variance Inflation Factor
	vif(LM)
	capture.output(vif(LM),paste('log_results/vif_',ext,'.doc',sep='')) # Relationship between variables. Want low values; high means variables
			 # are very related and are likely redundant
}

check.assumptions(LM_BL,'CWU_BL_LOG')
check.assumptions(LM_GN_IR,'CWU_GN_IR_LOG')
check.assumptions(LM_GN_RF,'CWU_GN_RF_LOG')
