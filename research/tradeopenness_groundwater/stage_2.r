# Causal Effect of Trade Openness on Agricultural Variables
# STAGE 2:
# Final regression on variable of interest
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

# Load in functions from copies of Qian's scripts


# Read in all data
df <- read.csv('results/input_data_clean_stage2.csv') # all data AND calculated AND estimated trade openness (from stage_1.r)
nutrients<-read.csv('cleandata/main_df2_wq_all.csv')
nutrients<-nutrients[-c(3:5)]
df<-merge(df,nutrients,by.x=c('iso_o','year'),by.y=c('ISO','Year'))
df<-na.omit(df)
df<-df[which(df[c(13)]!=0),]
pa_formula1_2 = "log(N) ~ hat_realopen + log(AperP) + log(ckperP) + log(pop_o) + rainfall + temperature + factor(iso_o) + factor(year) |. -TO + hat_realopen"
ver1_step2<- ivreg(formula = pa_formula1_2, data = df)

# Regress agricultural variables on estimated real trade openness + control variables, country and time fixed effects, and error (same as stage 1)


# Save as new .csv file
df.to_csv('results/stage_2_results.csv')
