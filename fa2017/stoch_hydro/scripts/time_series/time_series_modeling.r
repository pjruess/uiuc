# ARIMA(p,d,q)
# P how many lags
# Q moving average process (orders for moving average lags)
# D is degree of differencing (how many times differencing is required for stationarity)

#Read and format data
marseilles=read.csv("illinoisMarseilles.csv")
marseilles$datetime=strptime(as.character(marseilles$datetime),format = "%m/%d/%y")
marseilles$datetime=as.Date(marseilles$datetime,format="%Y/%m/%d")
print('--------------RAW DATA------------')
marseilles

#Aggregate data to monthly data
library(lubridate)
marseillesDaily=aggregate(marseilles$flowCFS, by=list(marseilles$datetime), FUN=mean, na.rm=TRUE)
marseillesDaily$Week=week(marseillesDaily$Group.1)
marseillesDaily$Month=month(marseillesDaily$Group.1)
marseillesDaily$Year=year(marseillesDaily$Group.1)
marseillesDaily=marseillesDaily[marseillesDaily$Year < 2009,] #records after 2008 have gaps
marseillesMonthly=aggregate(marseillesDaily$x, by=list(marseillesDaily$Month,marseillesDaily$Year), FUN=mean, na.rm=TRUE)
print('--------------DATA AGGREGATED BY DATE------------')
marseilles

# Create mean-centered time series object with stabilized variance 
marseillesTS=ts(log(marseillesMonthly$x)-mean(log(marseillesMonthly$x)),frequency = 12,start=c(1993,9))
pdf('ts_plot.pdf')
plot.ts(marseillesTS, main="Illinois River at Marseilles Monthly Average Flows", ylab="flow CFS")
dev.off()

#Test for stationarity
library(fpp)
adf.test(marseillesTS, alternative="stationary")
kpss.test(marseillesTS)

#Select candidate model
acf(marseillesTS, lag.max = 24)
pacf(marseillesTS, lag.max = 24)

#Try an ARIMA(1,0,0) model
m1=arima(marseillesTS,order=c(1,0,0),include.mean = FALSE)

#Check residuals for normality
pdf('m1_qqnorm_plot.pdf')
qqnorm(m1$residuals)
qqline(m1$residuals)
dev.off()

library(nortest)
lillie.test(m1$residuals)
shapiro.test(m1$residuals)

#Check residuals for constant variance
pdf('m1_residuals_plot.pdf')
plot.ts(m1$residuals)
dev.off()

#Check residuals for autocorrelation
Box.test(m1$residuals) #Box-Pierce test. Null hypothesis is independence of residuals. 

#Hyndman and Khandakar algorithm
m2=auto.arima(marseillesTS, trace=TRUE)

#Compare m1 and m2
print('-----------------COMPARISON OF M1 and M2------------')
m1
m2

#Check residuals for normality
pdf('m2_qqnorm_plot.pdf')
qqnorm(m2$residuals)
qqline(m2$residuals)
dev.off()
shapiro.test(m2$residuals)
lillie.test(m2$residuals)

#Check residuals for constant variance
pdf('m2_residuals_plot.pdf')
plot.ts(m2$residuals)
dev.off()

#Check residuals for autocorrelation
Box.test(m2$residuals) 

