## Install bootstrap package ##

x <- c(94, 38, 23, 197, 99, 16, 141)

## Estimate standard error ##
x.stderror <- sd(x)/sqrt(length(x))
x.stderror

## Or take the bootstrap approach ##
boot.sample <- sample(x, size=length(x), replace=T)
boot.mean <- mean(boot.sample)
boot.mean <- numeric()

# Sample B times and take mean of all samples, adding to boot.mean array
B <- 10000
for(i in 1:B){
	boot.sample <- sample(x, size=length(x), T)
	boot.mean[i] <- mean(boot.sample) #add boot.sample to array of means
}

boot.se <- sd(boot.mean) #average sd of B boot.mean samples
boot.se

## Use bootstrap function ##
# Identical to code above, simply built into a function
require(bootstrap)
boot.mean <- bootstrap(x, 2000, mean)
sd(boot.mean$thetastar)