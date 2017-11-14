## CEE 598SH: Stochastic Hydrology, Prof. Ashlynn S. Stillwell
## hydroTSM Example: Time Series Modeling

# Call hydroTSM and waterData libraries; add them, if you haven't already.
library(hydroTSM)
library(waterData)
library(zoo)

# # Read data
# rawdata <- importDVs("03337000", code="00060") # Replace "gage" with the USGS gage number of your choice; code corresponds to the variable of interest.
# # Be patient - this might take a while.
# flowM3S <- rawdata$val*0.028316847 # Converts USGS flow data from cfs to m3/s.
# dates <- rawdata$date
# flow <- data.frame(dates, flowM3S) # Creates a list of the variable of date and variable of interest. Note that flow from USGS is in cfs and the hydroTSM package processes in m3/s.
# write.csv(flow,'usgs_03337000_00060.csv',row.names=FALSE)

flow <- read.csv('usgs_03337000_00060.csv')
flowTS <- vector2zoo(flow$flowM3S, flow$dates)

# Monthly values
mflow <- daily2monthly(flowTS, FUN=mean)
datesTS <- time(flow$dates)
nyears <- yip(from=start(flowTS), to=end(flowTS))

# Exploratory data analysis
smry(flowTS)
hydroplot(flowTS, var.type="Flow", main = "at USGS gage", pfreq="dma") # dma: daily-monthly-annual

# Daily zoo to monthly zoo data conversion
m <- daily2monthly(flowTS, FUN=mean, na.rm=TRUE)

# Monthly analysis
monthlyfunction(m, FUN=median, na.rm=TRUE)
cmonth <- format(time(m), "%b")
months <- factor(cmonth, levels=unique(cmonth), ordered=TRUE)
boxplot(coredata(m) ~ months, col="lightblue", main="Monthly Flow", ylab="Flow (m3/s)", xlab="Month")

# Seasonal analysis
seasonalfunction(flowTS, FUN=mean, na.rm=TRUE) / nyears
DJF <- dm2seasonal(flowTS, season="DJF", FUN=mean)
MAM <- dm2seasonal(m, season="MAM", FUN=mean)
JJA <- dm2seasonal(m, season="JJA", FUN=mean)
SON <- dm2seasonal(m, season="SON", FUN=mean)
hydroplot(flowTS, pfreq="seasonal", FUN=mean, stype="default")

# Moving average plot 
# Plotting the monthly values
plot(m, xlab="Time", ylab="Flow (m3/s)")

## Plotting the annual moving average in station 'x'
lines(ma(m, win.len=12), col="blue", lwd=1.5)
