library(readstata13)

# Start PDF plotting device
pdf('hw1_plots.pdf')

df <- read.dta13('cps_small.dta')

# E[wage]
mean(df[,'wage'])

# E[wage|educ=12]
mean(df[df[,'educ']==12,][,'wage'])

# Conditional Expectation Function for all educ values
agg1 <- aggregate(.~educ,data=df,mean)[,c('educ','wage')]
agg1

# Plot educ vs. wage
plot(df$educ,df$wage)

# Linear regression of educ on wage
m <- lm(wage~educ,data=df)
print(m)
#summary(m)

# Plot linear function
f <- -11.0563 + df$educ*2.1534
lines(df$educ,f,col='red')

# Calculate e[wage|educ=12] from linear model
y <- -11.0563 + (12)*2.1534
y

### PART B ###
df2 <- read.csv('ps1_partb.csv')

# Conditional Expectation Function for all educ values
agg2 <- aggregate(.~educ,data=df2,mean)[,c('educ','wage')]
agg2

# Plot educ vs. wage
plot(df2$educ,df2$wage)

# Linear regression of educ on wage
m2 <- lm(wage~educ,data=df2)
print(m2)
#summary(m2)

# Plot linear function
f2 <- -2 + df2$educ*1
lines(df2$educ,f2,col='red')

# Calculate e[wage|educ=12] from linear model
y2 <- -2 + (12)*1
y2

# End PDF plotting device
dev.off()
