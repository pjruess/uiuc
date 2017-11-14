# Read in plotting library
library(ggplot2)

# Read in data
c02.data <- read.csv('county_outputs/final_data_2002.csv')
c07.data <- read.csv('county_outputs/final_data_2007.csv')
c12.data <- read.csv('county_outputs/final_data_2012.csv')
s02.data <- read.csv('state_outputs/final_data_2002.csv')
s07.data <- read.csv('state_outputs/final_data_2007.csv')
s12.data <- read.csv('state_outputs/final_data_2012.csv')

plot.bars <- function(geography, id, label) {
	c02 <- data.frame(group='County, 2002',value=c02.data[,id])
	c07 <- data.frame(group='County, 2007',value=c07.data[,id])
	c12 <- data.frame(group='County, 2012',value=c12.data[,id])
	s02 <- data.frame(group='State, 2002',value=s02.data[,id])
	s07 <- data.frame(group='State, 2007',value=s07.data[,id])
	s12 <- data.frame(group='State, 2012',value=s12.data[,id])

	if (geography == 'all') plot.data <- rbind(c02,c07,c12,s02,s07,s12)
	if (geography == 'county') plot.data <- rbind(c02,c07,c12)
	if (geography == 'state') plot.data <- rbind(s02,s07,s12)

	# Make plot
	ggplot(plot.data, aes(x=group,y=value,fill=group)) + 
		geom_boxplot() +
		labs(title=sprintf('%s for %s', id, toupper(geography)),
		     x='',
		     y='') +
		theme(axis.text.x = element_text(angle=90,hjust=1))
	path <- sprintf('boxplots/boxplot_%s_%s.pdf', geography, label)
	ggsave(path)
	print(sprintf('Plot saved to %s',path))
}

identifiers <- c('Storage_Bu','Percent_Harvest','Yield_Bu_per_Acre','Production_Bu','VWC_m3ha','VWS_m3_yield','VWS_m3_prod')
labels <- c('storage','percent_harvest','yield','production','vwc','vws_yield','vws_production')
df <- data.frame(identifiers, labels)

for (i in 1:nrow(df)){
	for (geography in c('county','state','all')) {
		id <- toString(df$identifiers[[i]])
		label <- toString(df$labels[[i]])
		
		# Plot data
		# tryCatch({
		plot.bars(geography, id, label)
		# }, error=function(e){cat('ERROR: ',conditionMessage(e),'\n')})
	}
}
