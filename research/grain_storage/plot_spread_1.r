# Read in plotting library
library(ggplot2)
library(data.table)

# Read in data
c02.data <- read.csv('county_outputs/final_data_2002.csv')
c07.data <- read.csv('county_outputs/final_data_2007.csv')
c12.data <- read.csv('county_outputs/final_data_2012.csv')
s02.data <- read.csv('state_outputs/final_data_2002.csv')
s07.data <- read.csv('state_outputs/final_data_2007.csv')
s12.data <- read.csv('state_outputs/final_data_2012.csv')

plot.bars <- function(commodity, geography, identifier, label) {

	# Define path to save to
	path <- sprintf('boxplots/boxplot_%s_%s_%s.png', geography, label, tolower(commodity))
	print(path)
	# If storage path already exists (since commodity is irrelevant), skip this plot
	if (identifier == 'Storage_Bu') {
		if (commodity != 'ALL'){ next }
	}

	# Create dataframe for plotting
	c02 <- data.frame(group='County, 2002',commodity=c02.data$Commodity,value=c02.data[,identifier],state=substr(sprintf('%05d',c02.data$GEOID),1,2))
	c07 <- data.frame(group='County, 2007',commodity=c07.data$Commodity,value=c07.data[,identifier],state=substr(sprintf('%05d',c07.data$GEOID),1,2))
	c12 <- data.frame(group='County, 2012',commodity=c12.data$Commodity,value=c12.data[,identifier],state=substr(sprintf('%05d',c12.data$GEOID),1,2))
	s02 <- data.frame(group='State, 2002',commodity=s02.data$Commodity,value=s02.data[,identifier],state=sprintf('%02d',s02.data$State.ANSI))
	s07 <- data.frame(group='State, 2007',commodity=s07.data$Commodity,value=s07.data[,identifier],state=sprintf('%02d',s07.data$State.ANSI))
	s12 <- data.frame(group='State, 2012',commodity=s12.data$Commodity,value=s12.data[,identifier],state=sprintf('%02d',s12.data$State.ANSI))

	# Select relevant data
	if (geography == 'all') plot.data <- rbind(c02,c07,c12,s02,s07,s12)
	if (geography == 'county') plot.data <- rbind(c02,c07,c12)
	if (geography == 'state') plot.data <- rbind(s02,s07,s12)

	# If commodity is not ALL, select subset 
	if (commodity != 'ALL') {
		plot.data <- plot.data[ which( plot.data$commodity == commodity ), ]
	}

	# If states, aggregate sum of plot.data df by State.ANSI
	if (geography == 'state') {
		plot.data <- aggregate( value ~ state+group+commodity, plot.data, FUN=sum)
		# plot.data <- setDT(plot.data)[, lapply(.SD, sum, na.rm=TRUE), by=.(State.ANSI,Storage_Bu), .SDcols=c('Harvest_Acre','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')]
	}

	# Convert zeros to NA
	plot.data[plot.data<=0] <- NA

	# Make plot
	ggplot(plot.data, aes(x=group,y=value,fill=group)) + 
		geom_boxplot() +
		labs(title=sprintf('%s for %s, %s', identifier, tolower(geography), tolower(commodity)),
		     x='',
		     y='') +
		theme(axis.text.x = element_text(angle=90,hjust=1))
	ggsave(path)
	print(sprintf('Plot saved to %s',path))
}

# Select only by certain commodity
commodities <- c('BARLEY','CORN','OATS','RICE','RYE','SORGHUM','WHEAT','ALL')

identifiers <- c('Storage_Bu','Harvest_Acre','Yield_Bu_per_Acre','Production_Bu','CWU_bl_m3ha','CWU_gn_ir_m3ha','CWU_gn_rf_m3ha','VWS_bl_m3_yield','VWS_gn_ir_m3_yield','VWS_gn_rf_m3_yield','VWS_bl_m3_prod','VWS_gn_ir_m3_prod','VWS_gn_rf_m3_prod')
labels <- c('storage','harvest','yield','production','cwu_blue','cwu_green_irrigated','cwu_green_rainfed','vws_yield_blue','vws_yield_green_irrigated','vws_yield_green_rainfed','vws_production_blue','vws_production_green_irrigated','vws_production_green_rainfed')


# commodities <- c('ALL')
# identifiers <- c('Storage_Bu','CWU_bl_m3ha')
# labels <- c('storage','cwu_blue')

df <- data.frame(identifiers, labels)

for (c in commodities) {
	for (i in 1:nrow(df)) {
		for (geography in c('county','state','all')) {
			id <- toString(df$identifiers[[i]])
			label <- toString(df$labels[[i]])
			
			# Plot data
			tryCatch({
				plot.bars(c, geography, id, label)
			}, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
		}
	}
}
