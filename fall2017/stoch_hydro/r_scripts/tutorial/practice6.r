# practice6.r - Use paste to automate plot creation

# 17 May 2013

# ===========================================================================
# ===========================================================================
# IMPORT DATA

# Add for loop for importing data

fuel <- read.csv("us_pump_fuel_prices.csv")


# ===========================================================================
# ===========================================================================
# UPDATE DATA

# This is only necessary because I didn't prepare the input data identically

# Revise US price data ----------------------------------------------

# Remove years 1976 to 1978
fuel <- fuel[-(1:3),]

# Rename columns
colnames(fuel) <- c("year","motor.gas.2005","motor.gas.nominal")

# # Revise UK price data ----------------------------------------------
# vec <- 1:50

# # Combine RON97 (LRP) and RON95 prices
# fuel2$motor.gas.nominal <- rowMeans(cbind(fuel2$RON97,fuel2$RON95), na.rm=T)



# ===========================================================================
# ===========================================================================
# CREATE PLOTS

# Define y-axis titles


# Define main plot titles


# Add for loop for plot creation

# UNCOMMENT THIS INSIDE FOR LOOP
# # More rigmarole because the data weren't cleaned up earlier...
# # x values
# years <- get(paste("fuel", i, sep=""))[,names(get(paste("fuel", i, sep=""))) == "year"]
# # y values
# fuel.price <- get(paste("fuel", i, sep=""))[,names(get(paste("fuel", i, sep=""))) == "motor.gas.nominal"]

# Start PDF figure device
pdf("us_price.pdf", height=3, width=3.5)

# Define plot margins and axis tick label placement
par(mar=c(3,3.3,2,0.1), mgp=c(3,0.8,0))

# Generate plot
plot(fuel$year, fuel$motor.gas.nominal, xlab="", ylab="", las=1, main="US Nominal Unleaded Retail Price", cex.axis=0.8, cex.main=0.9, pch=16)

# Add x-axis title
title(xlab="Year", line=2, cex.lab=0.9)

# Add y-axis title
title(ylab="Retail Unleaded Fuel ($/gal)", line=2.3, cex.lab=0.9)

# End figure device
dev.off()



