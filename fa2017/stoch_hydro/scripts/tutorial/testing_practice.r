# testing_practice.r - Code to create the figures 1-5 in the R tutorial slides



# ==============================================================================
# IMPORT DATA
# ==============================================================================

f.stats <- read.csv("us_fatality_data.csv")
fuel.price <- read.csv("us_pump_fuel_prices.csv")

# Already an effective data frame



# ==============================================================================
# CREATE FIRST DEMO PLOT
# ==============================================================================

# Use high-level plot command with built-in labels
# Other types are p, l, b, c, o, h, n
# lwd (line width), cex (point size)
plot(f.stats$year, f.stats$deaths, xlab="Year", ylab="Deaths", las=1, type="l", main="US Road Fatalities, 1976-2011")



# ==============================================================================
# CREATE SECOND DEMO PLOT
# ==============================================================================

# Use high-level plot command; turn off x-axis and y-axis markings
# Color blue and remove axes
plot(f.stats$year, f.stats$deaths, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=4, col="blue")

# Insert x-axis (axis 1) ticks and title
axis(1, seq(min(f.stats$year), max(f.stats$year), 5), las=2) # years by fives, vertical label
title(xlab="Year", cex.lab=1.25) # increase font size

# Insert y-axis (axis 2) ticks and title
axis(2, seq(35e3,55e3,5e3), seq(35,55,5), las=1) # axis, ticks, titles, rotation
title(ylab="Highway deaths (thousands)", cex.lab=1.25)



# ==============================================================================
# CREATE THIRD DEMO PLOT
# ==============================================================================

# Define plot margins
par(mar=c(5,4,1,1))

# Use high-level plot command; turn off x-axis and y-axis markings
plot(f.stats$year, f.stats$deaths, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=4, col="blue")

# Insert x-axis ticks and title
axis(1, seq(min(f.stats$year), max(f.stats$year), 5), las=2)
title(xlab="Year", cex.lab=1.25, line=3.9)

# Insert y-axis ticks and title
axis(2, seq(35e3,55e3,5e3), seq(35,55,5), las=1)
title(ylab="Highway deaths (thousands)", cex.lab=1.25)



# ==============================================================================
# CREATE FOURTH DEMO PLOT
# ==============================================================================

# Define plot margins
par(mar=c(4,4,1,5))

# Use high-level plot command; turn off x-axis and y-axis markings
plot(f.stats$year, f.stats$deaths, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=4, col="blue")

# Insert x-axis ticks and title
axis(1, seq(min(f.stats$year), max(f.stats$year), 5), las=1)
title(xlab="Year", cex.lab=1.25, line=2.9)

# Insert y-axis ticks and title
axis(2, seq(35e3,55e3,5e3), seq(35,55,5), las=1)
title(ylab="Highway deaths (thousands)", cex.lab=1.25)

# Use new=TRUE to be able to use another high-level plot command in the
# same plot region
par(new=TRUE)

# Add second set of data
plot(f.stats$year, f.stats$vmt.bn, xlab="", ylab="", xaxt="n", yaxt="n", pch=1, col="red", lwd=2, cex=1.3, ylim=c(1400,3200), bty="n")

# Insert RH y-axis ticks and title
axis(4,seq(1500,3000,250), las=1)
mtext("Vehicle miles traveled (billions p.a.)", side=4, line=3.9, cex=1.25)

# Insert legend
legend("topright", c("Highway deaths", "Vehicle miles traveled"), bty="n", lwd=c(4,2), pch=c(NA,1), lty=c(1,NA), pt.cex=1.3, col=c("blue","red"), cex=1.1)



# ==============================================================================
# CREATE FIFTH DEMO plot
# ==============================================================================

# Start PDF plotting device
pdf("fifth_figure.pdf", height=5, width=6)

# Define figure layout
layout(matrix(c(1,2), nrow=2))

# Define plot margins
par(mar=c(0,0,0,0), oma=c(2.9,3.5,1,4))

# First plot area -----------------------------

# Use high-level plot command; turn off x-axis and y-axis markings
plot(f.stats$year, f.stats$deaths, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=4, col="blue")

# Insert y-axis ticks and title
axis(2, seq(35e3,55e3,5e3), seq(35,55,5), las=1, cex.axis=0.75)
mtext("Highway deaths (thousands)", 2, cex=0.75, line=2.75)

# Use new=TRUE to be able to use another high-level plot command in the
# same plot region
par(new=TRUE)

# Add second set of data
plot(f.stats$year, f.stats$vmt.bn, xlab="", ylab="", xaxt="n", yaxt="n", pch=1, col="red", lwd=2, cex=0.9, ylim=c(1400,3200), bty="n")

# Insert RH y-axis ticks and title
axis(4, seq(1500,3000,250), las=1, cex.axis=0.75)
mtext("VMT (billions p.a.)", side=4, line=2.9, cex=0.75)

# Insert legend
legend("top", c("Highway deaths", "Vehicle miles traveled"), bty="n", lwd=c(4,2), pch=c(NA,1), lty=c(1,NA), pt.cex=0.85, col=c("blue","red"), cex=0.75)


# Second plot area ----------------------------

# Prepare labels for barplot
bar.labels <- c(seq(min(f.stats$year), max(f.stats$year), 5), rep(NA,(length(f.stats$year))*0.8+4))
bar.labels <- as.vector(matrix(bar.labels, ncol=8, byrow=T))
n.labels <- length(bar.labels)
bar.labels <- bar.labels[-((n.labels-3):n.labels)]

# Add barplot in second plot area
barplot(fuel.price$unleaded_2005_dollars, xlab="", ylab="", yaxt="n", col="darkseagreen2", ylim=c(0,3.5), names.arg=bar.labels, cex.names=0.75, mgp=c(3,0.25,0))
box()

# Insert x-axis title for barplot
mtext("Year", 1, cex=0.75, line=1.9)

# Insert y-axis ticks and title for barplot
axis(2, seq(0.5,3,0.5), c("0.50","1.00","1.50","2.00","2.50","3.00"), las=1, cex.axis=0.75)
mtext("Unleaded Fuel Price ($2005)", 2, cex=0.75, line=2.75)

# End PDF plotting device
dev.off()



