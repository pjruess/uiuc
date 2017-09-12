# setwd("/home/paul/windows/Users/Paul/Documents/UIUC/uiuc_scripts/fall2017/stoch_hydro/r_scripts/boneyard_example")

# Start PDF plotting device
pdf("boneyard_ratingcurve.pdf", height=5, width=5)

# Read in the data
bone.data <- read.csv('Boneyard_2012todate.csv')

# Plot the data
# log = 'y' log-transforms the y-axis
plot(bone.data$StageFT,bone.data$FlowCFS,xlab='Stage (ft)',ylab='Flow (cfs)',main='Rating Curve for Boneyard Creek, 2012',log='y')
# abline is a line between the defined points
# lm is linear model
abline(lm(log(bone.data$FlowCFS)~bone.data$StageFT),col='blue',lwd=2)

# Histogram with default settings
# prob is probabiility
# ylim is y-axis boundaries
# breaks defines number of bins
hist(bone.data$StageFT,prob=TRUE,ylim=c(0,3),breaks=45)
# Create density line, remove na values
lines(density(bone.data$StageFT,na.rm=TRUE),col='blue',lwd=2)

# Q-Q Plot
# qqnorm for a regular plot
# qqline adds a line to the plot
qqnorm(log(bone.data$FlowCFS))
qqline(log(bone.data$FlowCFS))

# End PDF plotting device
dev.off()