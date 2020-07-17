library(Metrics)

# Read and clean PCR mirca
df <- read.csv('irri_areas_states_summary_edit.csv')
df$STATEFP <- formatC(df$STATEFP,width=2,format='d',flag='0')
df$mirca2000 <- as.numeric(as.character(df$mirca2000))
df$mirca2010 <- as.numeric(as.character(df$mirca2010))
df$usda2002 <- as.numeric(as.character(df$usda2002))
df$usda2012 <- as.numeric(as.character(df$usda2012))

df02 <- df[,c(1,2,4)]
df12 <- df[,c(1,3,5)]

df <- df12
print(head(df))
colnames(df) <- c('STATEFP','mirca','usda')

# Create linear models
lm <- lm(mirca~usda,data=df)

# R-squared and Adjusted R-squared
r <- summary(lm)$r.squared
r.adj <- summary(lm)$adj.r.squared

# Mean Absolute Error
mae <- mae(df$mirca,df$usda)

# Root Mean Squared Error
rmse <- rmse(df$mirca,df$usda)

# Jaccard Coefficient (Binary)
jaccard <- function(x,y) {
    p = sum(x==TRUE & y==TRUE)
    q = sum(x==TRUE & y==FALSE)
    r = sum(x==FALSE & y==TRUE)
    return ( p / ( p + q + r ) ) 
}

bin <- df
bin[,c('mirca','usda')] <- ifelse(bin[,c('mirca','usda')]>0,TRUE,FALSE)

jac <- jaccard(bin$mirca, bin$usda)

# Simple Matching Coefficient
smc <- function(x,y) {
    p = sum(x==TRUE & y==TRUE)
    q = sum(x==TRUE & y==FALSE)
    r = sum(x==FALSE & y==TRUE)
    s = sum(x==FALSE & y==FALSE)
    return ( ( p + s ) / ( p + q + r + s ) ) 
}

smc <- smc(bin$mirca, bin$usda)

res <- data.frame(r,r.adj,mae,rmse,jac,smc)

colnames(res) <- c('R-Squared','Adjusted R-Squared','Mean Absolute Error','Root Mean Squared Error','Jaccard Coefficient','Simple Matching Coefficient')

print(res)
write.csv(res,'fit_metrics.csv',row.names=F)
