library(readstata13)

df <- read.dta13('nsduh_tables_replication.dta')

print(head(df,20))

# Plot alcohol vs. age
png('parta_alc.png')
plot(df$age,df$alc,col='blue')#,ylim=c(min(c(df$alc,df$mj)),max(c(df$alc,df$mj))))
dev.off()

# Plot marijuana vs. age
png('parta_mj.png')
plot(df$age,df$mj,col='red')
dev.off()

# Regression setup
df$over21 <- ifelse(df$age>=21,1,0)
df$agetilde <- df$age - 21

print(head(df[(df$age >= 18) & (df$age <= 24),],20))

# Regression of agetilde on alcohol bandwidth 3
print('Agetilde on Alcohol, Bandwidth: 3')
m1 <- lm(alc~over21+agetilde+over21*agetilde,data=df[(df$age >= 18) & (df$age <= 24),])
summary(m1)

# Regression of agetilde on marijuana bandwidth 3
print('Agetilde on Marijuana, Bandwidth: 3')
m2 <- lm(mj~over21+agetilde+over21*agetilde,data=df[(df$age >= 18) & (df$age <= 24),])
summary(m2)

# Regression of age on alcohol bandwidth 3
print('Age on Alcohol, Bandwidth: 3')
m3 <- lm(alc~over21+age+over21*age,data=df[(df$age >= 18) & (df$age <= 24),])
summary(m3)

# Regression of age on marijuana bandwidth 3
print('Age on Marijuana, Bandwidth: 3')
m4 <- lm(mj~over21+age+over21*age,data=df[(df$age >= 18) & (df$age <= 24),])
summary(m4)

# Regression of agetilde on alcohol bandwidth 5
print('Agetilde on Alcohol, Bandwidth: 5')
m5 <- lm(alc~over21+agetilde+over21*agetilde,data=df[(df$age >= 16) & (df$age <= 26),])
summary(m5)

# Regression of agetilde on marijuana bandwidth 5
print('Agetilde on Marijuana, Bandwidth: 5')
m6 <- lm(mj~over21+agetilde+over21*agetilde,data=df[(df$age >= 16) & (df$age <= 26),])
summary(m6)

# Regression of agetilde on alcohol bandwidth 4
print('Agetilde on Alcohol, Bandwidth: 4')
m7 <- lm(alc~over21+agetilde+over21*agetilde,data=df[(df$age >= 17) & (df$age <= 23),])
summary(m7)

# Regression of agetilde on marijuana bandwidth 4
print('Agetilde on Marijuana, Bandwidth: 4')
m8 <- lm(mj~over21+agetilde+over21*agetilde,data=df[(df$age >= 17) & (df$age <= 23),])
summary(m8)

# Regression of agetilde on alcohol bandwidth 2
print('Agetilde on Alcohol, Bandwidth: 2')
m9 <- lm(alc~over21+agetilde+over21*agetilde,data=df[(df$age >= 19) & (df$age <= 23),])
summary(m9)

# Regression of agetilde on marijuana bandwidth 2
print('Agetilde on Marijuana, Bandwidth: 2')
m10 <- lm(mj~over21+agetilde+over21*agetilde,data=df[(df$age >= 19) & (df$age <= 23),])
summary(m10)

# Regression of agetilde on alcohol bandwidth 1
print('Agetilde on Alcohol, Bandwidth: 1')
m11 <- lm(alc~over21+agetilde+over21*agetilde,data=df[(df$age >= 20) & (df$age <= 22),])
summary(m11)

# Regression of agetilde on marijuana bandwidth 1
print('Agetilde on Marijuana, Bandwidth: 1')
m12 <- lm(mj~over21+agetilde+over21*agetilde,data=df[(df$age >= 20) & (df$age <= 22),])
summary(m2)
