# Start PDF plotting device
pdf('sediment_example.pdf',height=5,width=5)

# Data collection method varies over time
# Assume stationarity

# H0: mu_method1 = mu_method2 = mu_method3
# alpha = 0.05 (95%)

sed <- read.csv('Sediment_example.csv')


# ~ is a linear relationship: y = mx + b... where y = first and x = second argument
sed.anova <- aov(SedimentTPD ~ Method, data=sed) #sediment as a function of method
summary(sed.anova)

#              Df    Sum Sq   Mean Sq F value Pr(>F)
# Method        2 1.848e+11 9.241e+10   0.279  0.757
# Residuals   162 5.363e+13 3.310e+11 

# P-value = 0.757 >>> alpha = 0.05
# So fairly confident that all means are the same, 
# meaning all three methods are the same

# CHECK ASSUMPTIONS

# Normality
# Does not look normal
qqnorm(resid(sed.anova))
qqline(resid(sed.anova)) # puts line on top

# Constant variance
# Variance looks very different between the three method groups (ie. not constant)
plot(sqrt(abs(resid(sed.anova)))~fitted(sed.anova)) # plot sqrt(abs(resid)) as function of fitted values

# Independence
# Not really independent. Should be spread around zero with similar spread
# in both the positive and negative directions
plot(resid(sed.anova)~fitted(sed.anova))

# End pdf plotting device
dev.off()