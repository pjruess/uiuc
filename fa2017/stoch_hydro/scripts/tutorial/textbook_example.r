# In-class example from textbook

TP <- c(8.91,4.76,10.30,2.32,12.47,4.49,3.11,9.61,6.35,5.84,3.30,12.38,8.99,7.79,7.58,6.70,8.13,5.47,5.27,3.52)

s <- sum(TP)
s

l <- length(TP)
l

mean.calc <- sum(TP)/length(TP)
mean.calc

mean.default <- mean(TP)
mean.default

# Create a function
my.mean <- function(x){
	total <- sum(x)
	n <- length(x)
	return(total/n)
}

print('my.mean...')
my.mean(TP)

# Argument
violation <- TP>10
violation
mean(violation)

# Write to csv
# Can also write to table using write.table()
write.csv(TP,file='test.csv')

# Plot with plot(), barplot(), and hist()
# Plot commands use col (color), main/xlab/ylab (plot and axis titles)
# names.arg (bar names), beside (stack bars), na.action (NA handler)