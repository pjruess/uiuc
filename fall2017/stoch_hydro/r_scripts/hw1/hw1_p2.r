# Start PDF plotting device
pdf("hw1_p2.pdf", height=5, width=5)

usgs.disch <- read.csv("usgs_08074000_daily_streamflow.csv")

plot(usgs.disch$datetime,usgs.disch$streamflow_cfs)

hist(usgs.disch$streamflow_cfs)

# End PDF plotting device
dev.off()