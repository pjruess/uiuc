marseilles=read.csv("illinoisMarseilles.csv")
marseilles$datetime=strptime(as.character(marseilles$datetime),format = "%m/%d/%y")
marseilles$datetime=as.Date(marseilles$datetime,format="%Y/%m/%d")


#Aggregate data to monthly data
library(lubridate)

marseillesDaily=aggregate(marseilles$flowCFS, by=list(marseilles$datetime), FUN=mean, na.rm=TRUE)
marseillesDaily$Week=week(marseillesDaily$Group.1)
marseillesDaily$Month=month(marseillesDaily$Group.1)
marseillesDaily$Year=year(marseillesDaily$Group.1)
marseillesDaily=marseillesDaily[marseillesDaily$Year < 2009,] #records after 2008 have gaps
marseillesMonthly=aggregate(marseillesDaily$x, by=list(marseillesDaily$Month,marseillesDaily$Year), FUN=mean, na.rm=TRUE)

# Create series object 
marseillesTS=ts(marseillesMonthly$x,frequency = 12,start=c(1993,9))
plot.ts(marseillesTS, main="Illinois River at Marseilles Monthly Average Flows", ylab="flow CFS")

source('nonparametricReps.R')

#  kNN Bootstrap method: Lall, U. and Sharma, A., 1996. A nearest neighbor bootstrap for resampling hydrologic time series. Water Resources Research, 32(3), pp.679-693.


replicates <- nonparametricReps(marseillesTS, reps = 5)
plot.ts(replicates)

summary(replicates)
summary(marseillesTS)
