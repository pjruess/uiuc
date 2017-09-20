# practice7f.r - Preparing plot creation to easily transform plots between
# 				 publication and presentation-ready formatting

# 17 May 2013

# ===========================================================================
# ===========================================================================
# IMPORT DATA

f.stats <- read.csv("us_fatality_data.csv")
fuel.price <- read.csv("us_pump_fuel_prices.csv")



# ===========================================================================
# ===========================================================================
# COMMON PLOT PARAMETERS

# COMMON COLORS -----------------------------------------------------

red = rgb(0.894,0.090,0,1)
orange = rgb(1,0.612,0,1)
yellow = rgb(0.926,0.580,0.039,1)
ltgreen = rgb(0.365,1,0,1)
green = rgb(0.380,0.753,0.314,1)
ltblue = rgb(0,0.730,1,1)
mdblue = rgb(0.192,0.384,0.847,1)
blue = rgb(0.157,0.478,0.878,1)
dkblue = rgb(0.129,0,0.996,1)
purple = rgb(0.623,0.369,1,1)
brown = rgb(0.494,0.271,0.145,1)
grey50 = rgb(0.5,0.5,0.5,1)
grey25 = rgb(0.25,0.25,0.25,1)

# PUBLICATION FORMATS -----------------------------------------------

# Font sizes
lab.size <- 0.9
axis.size <- 0.75

# Device background color
bg.col <- "white"

# Foreground colors
fg.col <- axis.col <- lab.col <- main.col <- "black"

# Figure dimensions (in inches)
fig.ht <- 3
fig.wd <- 3.5

# Line weight
line.wt <- 2

# PRESENTATION FORMATS ----------------------------------------------

# # Font sizes
# lab.size <- 1.25
# axis.size <- 1

# # Device background color
# bg.col <- "black" # change to "transparent" for actual PPT

# # Foreground colors
# fg.col <- axis.col <- lab.col <- main.col <- "white"

# # Figure dimensions (in inches)
# fig.ht <- 5.5
# fig.wd <- 9.2

# # Line weight
# line.wt <- 2

# -------------------------------------------------------------------



# ===========================================================================
# ===========================================================================
# FIRST PLOT

# Define plot margins
bmar <- 3-0.75+axis.size # Bottom margin (1)
lmar <- 3.3-0.75+axis.size # Left margin (2)
tmar <- 0.1 # Top margin (3)
rmar <- 4-0.75+axis.size # Right margin (4)

# Start PDF figure device
pdf("testfig1.pdf", height=fig.ht, width=fig.wd)

# Define plot margins and axis tick label placement
par(mar=c(bmar,lmar,tmar,rmar), mgp=c(3,0.8,0))

# Define background, foreground and object colors
par(bg=bg.col, fg=fg.col, col.axis=axis.col, col.lab=lab.col, col.main=main.col)

# High-level plot of unadjusted fatality counts
plot(f.stats$year, f.stats$deaths, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=line.wt, col=blue)

# Add x-axis ticks and title text
axis(1, c(1980,1990,2000,2010), las=1, cex.axis=axis.size, padj=-0.5)
title(xlab="Year", cex.lab=lab.size, line=bmar-1)

# Add y-axis ticks and title text
axis(2, seq(35e3,55e3,5e3), seq(35,55,5), las=1, cex.axis=axis.size)
title(ylab="Highway deaths (thousands)", cex.lab=lab.size, line=lmar-lab.size)

# Add new data to plot using par(new=T) so that high-level command can be
# used again in the same plot area
par(new=TRUE)

# High level plot of total annual VMTs (in billion miles)
plot(f.stats$year, f.stats$vmt.bn, xlab="", ylab="", xaxt="n", yaxt="n", type="l",  col=red, lwd=line.wt, ylim=c(1400,3300), bty="n")

# Add RH y-axis ticks and title text to support new data
axis(4,seq(1500,3250,250), las=1, cex.axis=axis.size)
mtext("VMT (billions p.a.)", side=4, line=rmar-lab.size-0.1, cex=lab.size)

# Insert legend
legend("topright", c("Highway deaths", "Vehicle miles traveled"), bty="n", lwd=c(2,2), col=c(blue,red), cex=0.7)

# End figure device
dev.off()



# ===========================================================================
# ===========================================================================
# SECOND PLOT

# Define plot margins
bmar <- 3.2-0.75+axis.size # Bottom margin (1)
lmar <- 4-0.75+axis.size # Left margin (2)
tmar <- 0.1 # Top margin (3)
rmar <- 0.1 # Right margin (4)

# Develop vector of plot labels for barplot
bar.labels <- c(seq(min(f.stats$year), max(f.stats$year), 5), rep(NA,(length(f.stats$year))*0.8+4))
bar.labels <- as.vector(matrix(bar.labels, ncol=8, byrow=T))
n.labels <- length(bar.labels)
bar.labels <- bar.labels[-((n.labels-3):n.labels)]

# Start PDF figure device
pdf("testfig2.pdf", height=fig.ht, width=fig.wd)

# Define plot margins
par(mar=c(bmar,lmar,tmar,rmar))

# Define background, foreground and object colors
par(bg=bg.col, fg=fg.col, col.axis=axis.col, col.lab=lab.col, col.main=main.col)

# High-level barplot of fuel prices
barplot(fuel.price$unleaded_2005_dollars, xlab="", ylab="", yaxt="n", col=green, ylim=c(0,3.5), names.arg=bar.labels, cex.names=axis.size, mgp=c(3,0.25,0), las=2, border=NA)

# Add box around plot area
box()

# Add x-axis title text
mtext("Year", 1, cex=lab.size, line=bmar-1)

# Add y-axis ticks and title text
axis(2, seq(0.5,3,0.5), c("0.50","1.00","1.50","2.00","2.50","3.00"), las=1, cex.axis=axis.size, mgp=c(3,0.8,0))
mtext("Unleaded Fuel Price ($2005)", 2, cex=lab.size, line=lmar-lab.size)

# End figure device
dev.off()



