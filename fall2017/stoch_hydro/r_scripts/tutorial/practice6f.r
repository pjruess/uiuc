# practice6.r - Use paste to automate plot creation

# 17 May 2013

# ===========================================================================
# ===========================================================================
# IMPORT DATA

# Country name vector
country.code <- c("us","uk")

# Import data using 'assign' and 'paste'
for (i in 1:2) {
	assign(paste("fuel", i, sep=""), read.csv(paste(country.code[i], "_pump_fuel_prices.csv", sep="")))
	
}




# ===========================================================================
# ===========================================================================
# UPDATE DATA

# This is only necessary because I didn't prepare the input data identically

# Revise US price data ----------------------------------------------

# Remove years 1976 to 1978
fuel1 <- fuel1[-(1:3),]

# Rename columns
colnames(fuel1) <- c("year","motor.gas.2005","motor.gas.nominal")

# Revise UK price data ----------------------------------------------
vec <- 1:50

# Combine RON97 (LRP) and RON95 prices
fuel2$motor.gas.nominal <- rowMeans(cbind(fuel2$RON97,fuel2$RON95), na.rm=T)



# ===========================================================================
# ===========================================================================
# CREATE PLOTS

# Define y-axis titles
y.title <- c("Retail Unleaded Fuel ($/gal)", "Retail Unleaded Fuel (p/liter)")

# Define main plot titles
plot.title <- c("US Nominal Unleaded Retail Price", "UK Nominal Unleaded Retail Price")

for (i in 1:2) {

	# More rigmarole because the data weren't cleaned up earlier...
	# x values
	years <- get(paste("fuel", i, sep=""))[,names(get(paste("fuel", i, sep=""))) == "year"]
	# y values
	fuel.price <- get(paste("fuel", i, sep=""))[,names(get(paste("fuel", i, sep=""))) == "motor.gas.nominal"]

	# Start PDF figure device
	pdf(paste(country.code[i], "_price.pdf", sep=""), height=3, width=3.5)
	
	# Define plot margins and axis tick label placement
	par(mar=c(3,3.3,2,0.1), mgp=c(3,0.8,0))
	
	# Generate plot
	plot(years, fuel.price, xlab="", ylab="", las=1, main=plot.title[i], cex.axis=0.8, cex.main=0.9, pch=16)
	
	# Add x-axis title
	title(xlab="Year", line=2, cex.lab=0.9)
	
	# Add y-axis title
	title(ylab=y.title[i], line=2.3, cex.lab=0.9)
	
	# End figure device
	dev.off()

}

