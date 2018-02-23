# # WaterML R package tutoral at https://cran.r-project.org/web/packages/WaterML/vignettes/WaterML-Tutorial.html
# 
# #import required libraries
# library(WaterML)
# 
# #get the list of supported CUAHSI HIS services
# services <- GetServices()
# View(services)
# 
# #point to an CUAHSI HIS service and get a list of the variables and sites
# server <- "http://192.31.21.100/czo_merced/cuahsi_1_1.asmx?WSDL"
# variables <- GetVariables(server)
# sites <- GetSites(server)
# 
# #get full site info for all sites using the GetSiteInfo method
# siteinfo <- GetSiteInfo(server, "czo_merced:LowBull_Met")
# 
# View(siteinfo)
# 
# #get full site info for all sites using the GetSiteInfo method
# snow <- GetValues(server,siteCode="czo_merced:LowBull_Met",variableCode="czo_merced:Snowdepth3")
# temp <- GetValues(server, siteCode="czo_merced:LowBull_Met",variableCode="czo_merced:Temperature2")
# 
# print(snow)
# print(temp)
# 
# write.csv(snow,'snow_df.csv')
# write.csv(temp,'temp_df.csv')
# 
# years <- strftime(temp$time, "%Y")
# months <- strftime(temp$time, "%m")
# days <- strftime(temp$time, "%d")
# hours <- strftime(temp$time, "%h")
# minutes <- strftime(temp$time, "%M")
# seconds <- strftime(temp$time, "%s")

# #merge our two tables based on the time column
# df <- merge(temp, snow, by="time")
# #rename the column DataValue.x in the merged table to "temp"
# names(df)[names(df)=="DataValue.x"] <- "temp"
# #rename the column DataValue.y in the merged table to "snow"
# names(df)[names(df)=="DataValue.y"] <- "snow"
# 
# write.csv(df,'combined_df.csv')
library(data.table)

df <- fread('combined_df.csv',select=c('time','snow','temp'))
df <- as.data.frame(df)
df$time <- as.Date(as.character(df$time))

png('raw_data.png')

par(mar=c(5,5,4,4) + 0.1)

with(df, plot(time, temp, type='l', col='lightgrey', #lty=2, 
	      ylab='Temperature', ylim=c( min(temp), max(temp) )))

par(new=T)
with(df, plot(time, snow, type='l', col='blue', 
	      axes=F, xlab=NA, ylab=NA, cex=1.2))
axis(side=4)
mtext(side=4, line=3, 'Snow')
legend('topleft',
       legend=c('Temperature','Snow'),
       lty=c(1,1), col=c('lightgrey','blue'))

# plot(df$time, df$snow, axes=F, xlab='',ylab='',type='l',lty=1,col='black',lwd=2,main='',
#      ylim=c(min(df$snow),max(df$snow)), xlim=c(min(df$time),max(df$time)))
# # col="blue", xlab='Datetime', ylab='', main='Snow and Temperature over Time' )
# axis(2, ylim=c(min(df$snow),max(df$snow)),col='black',lwd=2)
# mtext(2, text='Snow',line=2)
# 
# par(new=T)
# plot(df$time, df$temp, axes=F, xlab='',ylab='',type='l',lty=2,col='black',lwd=2,main='',
#      ylim=c(min(df$temp),max(df$temp)), xlim=c(min(df$temp),max(df$temp)))
# # lines(temp~time, data=df, col="red", ylab='')
# axis(4, ylim=c(min(df$temp),max(df$temp)),col='black',lwd=2)
# mtext(4, text='Temperature',line=2)
# 
# # X-axis
# axis(1, pretty(range(df$time),10))
# mtext('Datetime', side=1, col='black', line=2)
# 
# # Legend
# legend(x=7000,y=100,legend=c('Snow','Temperature'), lty=c(1,2,3))

dev.off()

png('snow_vs_temp.png')
plot(temp~snow, data=df)

# Perform a linear regression on the temp vs. snow values
model <- lm(formula(snow~temp), data=df)

summary(model)
abline(model)

dev.off()

# ARIMA model with p=2 and q=1 w/ temp as external regressor
arima(df$snow, order=c(2,0,1), xreg=df$temp)

# ARIMA model w/ p=1, d=1, and q=1
arima(df$snow, order=c(1,1,1))

# Automatically fit ARIMA
library(fpp)
auto.arima(df$snow,trace=TRUE)





