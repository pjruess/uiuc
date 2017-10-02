# Install packages...
library(exactRankTests)
library(coin)
# Packages saved to /tmp/RtmpjgfBb5/downloaded_packages

x <- c(17.0,4.0,7.0,11.0,21.5,4.0,24.0)

x
rank(x) # default to average tied rankings
rank(x,ties.method='min') # ties.method='min' or 'max' to round ties up or down to nearest integer

# wilcox.test(x,mu=20)

wilcox.exact(x,mu=20)