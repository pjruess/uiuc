# WaterML R package tutoral at https://cran.r-project.org/web/packages/WaterML/vignettes/WaterML-Tutorial.html

#import required libraries
library(WaterML)

#get the list of supported CUAHSI HIS services
services <- GetServices()
View(services)

#point to an CUAHSI HIS service and get a list of the variables and sites
server <- "http://hydroportal.cuahsi.org/ipswich/cuahsi_1_1.asmx?WSDL"
variables <- GetVariables(server)
sites <- GetSites(server)

#get full site info for all sites using the GetSiteInfo method
siteinfo <- GetSiteInfo(server, "IRWA:FB-BV")

View(siteinfo)

#get full site info for all sites using the GetSiteInfo method
Temp <- GetValues(server,siteCode="IRWA:FB-BV",variableCode="IRWA:Temp")
DO <- GetValues(server, siteCode="IRWA:FB-BV",variableCode="IRWA:DO")

plot(DataValue~time, data=Temp, col="red")
points(DataValue~time, data=DO, col="blue")

years <- strftime(DO$time, "%Y")
months <- strftime(DO$time, "%m")
days <- strftime(DO$time, "%d")
hours <- strftime(DO$time, "%h")
minutes <- strftime(DO$time, "%M")
seconds <- strftime(DO$time, "%s")

#merge our two tables based on the time column
data <- merge(DO, Temp, by="time")
#rename the column DataValue.x in the merged table to "DO"
names(data)[names(data)=="DataValue.x"] <- "DO"
#rename the column DataValue.y in the merged table to "Temp"
names(data)[names(data)=="DataValue.y"] <- "Temp"

plot(DO~Temp, data=data)

# Perform a linear regression on the dissolved oxygen vs. temperature values
model <- lm(DO~Temp, data=data)

summary(model)
abline(model)


