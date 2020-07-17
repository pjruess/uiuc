df <- read.csv('results/1960_2010/input_data_clean_stage1.csv')

years <- 1960:2010

y.vals <- list()

for (year in years) {
    temp.df <- df[df$Year == year,]
    temp.df <- temp.df[temp.df$GWD != 0,]
    y <- nrow(temp.df)
    y.vals <- append(y.vals,y)
}

plot(years,y.vals,type='p',col='blue',lwd=3,cex=1,pch=16,xlab='Year',ylab='# Observations',main='Annual number of observations')
