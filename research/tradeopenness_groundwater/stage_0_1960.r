# Causal Effect of Trade Openness on Agricultural Variables
# STAGE 0:
# Constructed trade openness
# Akshay Pandit & Paul J. Ruess
# Spring 2019

# Load necessary libraries
library(reshape2)
library(data.table)
library(dplyr)
library(sqldf)
library(data.table)
library(gtools)

# Estimate constructed trade openness
predopen <- function(fo, y_bigeo){
  # y_bigeo = df1_curr
  hat_open <- as.data.frame(predict(fo, newdata = y_bigeo))
  pred <- cbind(y_bigeo[,1:3], hat_open)
  names(pred)[4] <- "log_hat_open"
  pred$hat_open <- exp(pred$log_hat_open)
  hat_totalopen <- sqldf("SELECT iso_o,Year, sum(hat_open)
                         FROM pred
                         GROUP BY iso_o, Year")
  names(hat_totalopen) <- c("ISO", "Year","TO_Hat")
  #write.csv(hat_totalopen,"hat_totalopen.csv", row.names = F)
  return(hat_totalopen)
}

# Read in data
df <- read.csv('results/1960_2010/input_data_clean_stage0.csv') # all input data (from clean_data.r script)
df$iso_o <- as.character(df$iso_o)
df$iso_d <- as.character(df$iso_d)
df = df[df$iso_d!=df$iso_o,]
#df = df[df$iso_o != "LBR" ,]
#df = df[df$iso_o != "LUX" ,]
#df = df[df$iso_d != "LBR" ,]
#df = df[df$iso_d != "LUX" ,]
df = subset(df, select = -c(distcap,landlocked_o, landlocked_d))
df$biopenness[df$biopenness == 0] <- NA
df <-na.omit(df)

df2 <- read.csv('results/1960_2010/input_data_clean_stage_control.csv')
df2 <- na.omit(df2)

df.gwd <- read.csv('results/1960_2010/input_data_clean_stage_gwd.csv')

### Create linear model and calculate constructed trade openness

# Version 1
print('Constructing trade openness instrument, version 1...')
f.1 = "log(biopenness) ~ factor(iso_o) + factor(iso_d) + factor(year) + log(dist)*(log(pop_o) + log(pop_d)) + contig*(log(pop_o) + log(pop_d) + log(dist))"
lm.1 <- lm(formula = f.1, data = df)
hat.to.1 <- predopen(lm.1,df)
colnames(hat.to.1)[colnames(hat.to.1) == 'TO_Hat'] <- 'TO_Hat_v1'

# Version 2
print('Constructing trade openness instrument, version 2...')
f.2 = "log(biopenness) ~ factor(iso_o) + factor(iso_d) + factor(year) + log(dist)*(log(pop_o) + log(pop_d)) + contig*(log(pop_o) + log(pop_d) + log(dist)) + wto_o + wto_d + rta"
lm.2 <- lm(formula = f.2, data = df)
hat.to.2 <- predopen(lm.2,df)
colnames(hat.to.2)[colnames(hat.to.2) == 'TO_Hat'] <- 'TO_Hat_v2'

print('Merging data and saving...')
df2 <- merge(df2,hat.to.1,by= c('ISO', 'Year'))
df2 <- merge(df2,hat.to.2,by= c('ISO', 'Year'))
df2 <- merge(df2,df.gwd,by= c('ISO', 'Year'))
write.csv(df2,file='results/1960_2010/input_data_clean_stage1.csv',row.names = FALSE)
