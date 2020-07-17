library('reshape2')
library('ggplot2')

# Start PDF plotting device
pdf('us_to_china_trade_plots.pdf')

unc <- read.csv('comtrade_usa_to_china_allyears.csv')[,c('Exporter','Importer','Resource','Year','Value_1000USD','Weight_1000kg')]

faf <- read.csv('faf4_usa_states_to_china_allyears.csv')

# Aggregate FAF
faf_agg <- aggregate(cbind(Total_KTons,Total_MUSD) ~ Year + SCTG2, data = faf, sum, na.rm=TRUE)

#unc_short <- unc[,c('Year','Resource','Value_1000USD')]
#unc_cast <- cast(unc_short, Year ~ Resource)

# Remove useless resources for cleaner visualization


# UNC Convert to SCTG2
cw <- read.csv('unc_faf_crosswalk.csv')
unc <- merge(x=unc,y=cw,by.x='Resource',by.y='UNC',all=TRUE)
unc[,'Value_MUSD'] <- unc[,'Value_1000USD']/1000

# Clean and Aggregate UNC
unc <- unc[!(unc$SCTG2 == 'Nan'),] # Remove the rubber from UNC data
unc_agg <- aggregate(cbind(Value_MUSD,Weight_1000kg) ~ Year + SCTG2, data = unc, sum, na.rm=TRUE)

# Clean FAF
faf[,'SCTG2'][faf[,'SCTG2'] == 'Milled grain prods.'] <- 'Cereal grains'

# Plot both on same plot
ggplot() + 
    geom_line(data=unc_agg, aes(Year,Value_MUSD,col=SCTG2)) + 
    geom_line(data=faf_agg, aes(Year,Total_MUSD,col=SCTG2),linetype='dashed') 

# Plot
ggplot(unc_agg, aes(Year,Value_MUSD,col=SCTG2)) + 
    geom_point() + 
    geom_line()
    #stat_smooth()

# Plot
ggplot(faf_agg, aes(Year,Total_MUSD,col=SCTG2)) + 
    geom_point() + 
    geom_line()

# End PDF plotting device
dev.off()
