library(readstata13)

df <- read.dta13('cps_small.dta')

print(head(df,20))

# First regression comparing all education variables to the omitted education variable (educ==9)
m1 <- lm(wage~exper+union+exper*union,data=df)
summary(m1)

# Create necessary variables
df$explow <- ifelse(df$exper<10,1,0)
df$expmed <- ifelse((df$exper>=10 & df$exper<20),1,0)
df$exphi <- ifelse(df$exper>=20,1,0)

# Regression comparing exper categories with omitted explow category (exp<10)
m2 <- lm(wage~expmed+exphi+educ + expmed*educ + exphi*educ,data=df)
summary(m2)

break

# Conditional Expectation Function for all educ values
agg1 <- aggregate(.~educ,data=df,mean)[,c('educ','wage')]
agg1

# Create necessary variables
df$edu9 <- ifelse(df$educ==9,1,0)
df$edu10 <- ifelse(df$educ==10,1,0)
df$edu11 <- ifelse(df$educ==11,1,0)
df$edu12 <- ifelse(df$educ==12,1,0)
df$edu13 <- ifelse(df$educ==13,1,0)
df$edu14 <- ifelse(df$educ==14,1,0)
df$edu16 <- ifelse(df$educ==16,1,0)
df$edu18 <- ifelse(df$educ==18,1,0)

# First regression comparing all education variables to the omitted education variable (educ==9)
m1 <- lm(wage~edu10+edu11+edu12+edu13+edu14+edu16+edu18,data=df)
print(m1)

# Regression omitting educ==12 and holding gender and experience constant
m2 <- lm(wage~edu9+edu10+edu11+edu13+edu14+edu16+edu18+exper+female,data=df)
print(m2)

# Test that educ==16 > ( 13<=educ<=15 ) w/ gender and exper constant
# Note educ=/15, so ignore this value
df$edu9_12 <- rowSums(df[,c('edu9','edu10','edu11','edu12')])
df$edu13_15 <- rowSums(df[,c('edu13','edu14')])
df$edu16_18 <- rowSums(df[,c('edu16','edu18')])
print(head(df))

# Regression omitting educ>=16 and holding gender and experience constant
m3 <- lm(wage~edu9_12+edu16_18+exper+female,data=df)
print(m3)

# Create necessary variables
df$explow <- ifelse(df$exper<10,1,0)
df$expmed <- ifelse((df$exper>=10 & df$exper<20),1,0)
df$exphi <- ifelse((df$exper>=20 & df$exper<30),1,0)
df$expvehi <- ifelse(df$exper>=30,1,0)

# Regression comparing exper categories with omitted explow category (exp<10)
m4 <- lm(wage~expmed+exphi+expvehi,data=df)
print(m4)

# Regression comparing exper categories with omitted expvehi category (exp<10)
m5 <- lm(wage~explow+expmed+exphi,data=df)
print(m5)

# Regression comparing exper categories with omitted expmed category (exp<10)
m6 <- lm(wage~explow+exphi+expvehi,data=df)
print(m6)

# Create necessary variables
df$exp10plus <- ifelse(df$exper>=10,1,0)
df$exp20plus <- ifelse(df$exper>=20,1,0)
df$exp30plus <- ifelse(df$exper>=30,1,0)

# Regression comparing exper categories with omitted lowexp category (exp<10)
# and overlapping categories
m7 <- lm(wage~exp10plus+exp20plus+exp30plus,data=df)
print(m7)
