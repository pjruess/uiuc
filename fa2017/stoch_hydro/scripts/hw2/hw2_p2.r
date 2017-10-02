# Critically analyze the sediment dataset used in class (Sediment_example.csv on
# the class Compass site). As a water resources engineer, would you be
# comfortable using this dataset, as combined from three different measurement
# methods, for detailed analysis and design? Perform an analysis of variance of
# the SedimentTPD data to justify your decision. In making your decision,
# consider the following:
# a. Should the data be transformed?
# b. Do other measured parameters influence the variance?
# c. Are the residual assumptions satisfied? If not, what might you change to
# meet those assumptions?
# d. What additional information would be useful?

# Start PDF plotting device
pdf('hw2_p2.pdf',height=5,width=5)

sed <- read.csv('../sediment_example/Sediment_example.csv')


### NORMAL FIT TEST ###

sed.aov <- aov(SedimentTPD ~ Method, data=sed) #sediment as a function of method
summary(sed.aov)

# # CHECK ASSUMPTIONS

# Normality
# Does not look normal
qqnorm(resid(sed.aov),
	main='Q-Q Plot of normal\nSedimentTPD data')
qqline(resid(sed.aov)) # puts line on top

# Constant variance
# Variance looks very different between the three method groups (ie. not constant)
plot(sqrt(abs(resid(sed.aov)))~fitted(sed.aov),
	main='S-L Plot of normal\nSedimentTPD data',
	xlab='Fitted Residuals (TPD)',
	ylab='Square-root of residuals (TPD^(1/2))') # plot sqrt(abs(resid)) as function of fitted values

# Independence
# Not really independent. Should be spread around zero with similar spread
# in both the positive and negative directions
plot(resid(sed.aov)~fitted(sed.aov),
	main='Residual Plot of normal\nSedimentTPD data',
	xlab='Fitted Residuals (TPD)',
	ylab='Residuals (TPD)')


### LOG-NORMAL FIT TEST ###

zero_rule <- apply(sed[5], 1, function(row) all(row !=0 )) #rule for selecting all non-zero rows
sed_nozero <- sed[zero_rule,] #indexing by non-zero rows (ie. removing zeros)

sed.aov.log <- aov(log(SedimentTPD) ~ Method, data=sed_nozero) #sediment as a function of method
summary(sed.aov.log)

# CHECK ASSUMPTIONS

# Normality
qqnorm(resid(sed.aov.log),
	main='Q-Q Plot of log-transformed\nSedimentTPD data')
qqline(resid(sed.aov.log)) # puts line on top

# Constant variance
plot(sqrt(abs(resid(sed.aov.log)))~fitted(sed.aov.log),
	main='S-L Plot of log-transformed\nSedimentTPD data',
	xlab='Fitted Residuals (TPD)',
	ylab='Square-root of residuals (TPD^(1/2))') # plot sqrt(abs(resid)) as function of fitted values

# Independence
plot(resid(sed.aov.log)~fitted(sed.aov.log),
	main='Residual Plot of log-transformed\nSedimentTPD data',
	xlab='Fitted Residuals (TPD)',
	ylab='Residuals (TPD)')


### Testing influence of other parameters on sediment variance

sed$nMethod = as.numeric(sed$Method)

# Method+Month uses variables only, with no interaction
# Method*Month uses both variables and interaction
# Method:Month uses only interaction
sed.aov.log2 <- aov(log(SedimentTPD)~FlowCFS*Month,data=sed_nozero)
summary(sed.aov.log2)

# CHECK ASSUMPTIONS

# Normality
qqnorm(resid(sed.aov.log2),
	main='Q-Q Plot of Two-Way\nSedimentTPD~FlowCFS*Month data')
qqline(resid(sed.aov.log2)) # puts line on top

# Constant variance
plot(sqrt(abs(resid(sed.aov.log2)))~fitted(sed.aov.log2),
	main='S-L Plot of Two-Way\nSedimentTPD~FlowCFS*Month data',
	xlab='Fitted Residuals (TPD)',
	ylab='Square-root of residuals (TPD^(1/2))') # plot sqrt(abs(resid)) as function of fitted values

# Independence
plot(resid(sed.aov.log2)~fitted(sed.aov.log2),
	main='Residual Plot of Two-Way\nSedimentTPD~FlowCFS*Month data',
	xlab='Fitted Residuals (TPD)',
	ylab='Residuals (TPD)')

# model.tables(sed.aov.log2)

# End pdf plotting device
dev.off()