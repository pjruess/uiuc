df <- read.csv('corn_alldata.csv')
df$State <- sprintf('%02d',df$State) # format with leading zeros

# Try different combinations of climate variables
f1 <- 'Yield ~ Pcp.sum*T.mean'
f2 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq'
f3 <- 'Yield ~ Pcp.sum*T.mean + T.mean.Sq'
f4 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq + T.mean.Sq'
f5 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'
f6 <- 'Yield ~ Pcp.sum*T.mean + Pcp.sum.Sq + Pcp.sum.Sq:T.mean.Sq'
m1 <- lm(f1,df)
m2 <- lm(f2,df)
m3 <- lm(f3,df)
m4 <- lm(f4,df)
m5 <- lm(f5,df)
m6 <- lm(f6,df)
anova(m1,m2,m3,m4,m5,m6) # lowest RSS is best
AIC(m1,m2,m3,m4,m5,m6) # lowest AIC is best
BIC(m1,m2,m3,m4,m5,m6) # lowest BIC is best
# highest log likelihood is best (lowest absolute value; smallest negative value)
logLik(m1)
logLik(m2)
logLik(m3)
logLik(m4)
logLik(m5)
logLik(m6)

# Best model for me is model 5 for all tests

# Add export data to the best model, and compare to the regular OLS without export
f7 <- 'Yield ~ Export + Pcp.sum*T.mean + Pcp.sum.Sq*T.mean.Sq'

# Regular OLS
m7 <- lm(formula=f7,data=df)

# Check dif models as regular OLS
anova(m5,m7)
AIC(m5,m7)
BIC(m5,m7)
logLik(m5)
logLik(m7)

# Export makes the model better by all tests (for my data), so include export
# if your export version is worse, just write in your paper
# that you kept exports because you wanted to see its relationship

# Try fixed effects models 
library(plm)

# Space AND time fixed effects
fe.all <- plm(formula=f7,data=df,index=c('State','Year'),model='within',effect='twoways')
summary(fe.all)

# Compare FE to OLS (sig p-val means its better than OLS)
pFtest(fe.all,m7)
