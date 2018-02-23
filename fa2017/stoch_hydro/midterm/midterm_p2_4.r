data <- read.csv(
	'WorldWaterStats.csv'
	)

print('IMDRINK Results')
imdrink <- aov(IMDRINK~as.numeric(REGION),data=data)
summary(imdrink)

print('IMSAN Results')
imsan <- aov(IMSAN~as.numeric(REGION),data=data)
summary(imsan)

means <- aggregate(data[,5:6],list(data$REGION),mean)

png('midterm_p2_4_boxplot_imdrink.png')
boxplot(means$IMDRINK,
	main='Boxplot of IMDRINK Regional Means')
dev.off()

png('midterm_p2_4_boxplot_imsan.png')
boxplot(means$IMSAN,
	main='Boxplot of IMSAN Regional Means')
dev.off()