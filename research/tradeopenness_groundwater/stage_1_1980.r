# Causal Effect of Trade Openness on Agricultural Variables
# STAGE 1:
# Estimation of Real trade openness
# Akshay Pandit & Paul J. Ruess
# Spring 2019

# Load necessary libraries
library(sqldf)
library(AER)
library(MASS)
library(gtools)
library(stringr)
library(stargazer)
library(xtable)
library(reshape2)
library(glue)

# Estimate significant figures
significant <- function(x){
  if(!is.na(x) & x < 0.1){
    if (x < 0.05) {
      if ( x < 0.01) {
        y = "***"
      }
      else 
        y = " **"
    }
    else
      y = "  *"
  }
  else
    y = ""
  return (y)
}

# Wrapper function to take formula and dataframe, solve IV regression, and neatly present results
iv_solve <- function(f,df){
    lm <- ivreg(formula = f, data = df)
    res <- data.frame(summary(lm)$coefficient)
    colnames(res) <- c("coef", "sd", "t", "p")
    res$sig <- sapply(res$p, significant)
    res <- res[2,c(1:2,5)]
    return(res)
}

# Read in data
df <- read.csv('results/1980_2010/input_data_clean_stage1.csv')

lenError <- tryCatch({
    df$GWD[df$GWD==0] <- NA
}, error=function(e) e)

if(inherits(lenError,'error')) {
    print('Not enough data')
    next
}

df <- subset(df, !( (is.na(GWD)) |  (is.na(Population)) | (is.na(Rainfall)) | (is.na(Temperature)) | (is.na(lperP))  | (is.na(ckperP))  |(is.na(TO)) )  )

obs <- nrow(df)
print(glue('Observations: {obs}'))

if (length(unique(df$ISO)) == 1) {
    print('Not enough data')
    next
}

# OLS
m <- lm(log(GWD)~TO,data=df)
print('OLS...')
print(summary(m))
print('---')

# IV, Version 1
f.1 <- "log(GWD) ~ TO + log(lperP) + log(ckperP) + log(Population) + Rainfall + Temperature + factor(ISO) + factor(Year) | . -TO + TO_Hat_v1"
f.2 = "log(GWD) ~ TO*log(lperP) + TO*log(ckperP) + log(Population) + Rainfall + Temperature + factor(ISO) + factor(Year) | . - TO*log(lperP) - TO*log(ckperP)  + TO_Hat_v2*log(lperP) + TO_Hat_v2*log(ckperP)"
print('IV version 1...')
res.v1 <- iv_solve(f.1,df)
print(res.v1)
print('---')

# IV, Version 2
print('IV version 2...')
res.v2 <- iv_solve(f.2,df)
print(res.v2)
print('---')

print('----------')
