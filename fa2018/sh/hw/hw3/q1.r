c43 <- read.csv('catch43.csv',header=FALSE)
c322 <- read.csv('catch322.csv',header=FALSE)
c393 <- read.csv('catch393.csv',header=FALSE)

names(c43) <- c('Year','Month','Day','P','Ep','Q','Qs','Qu')
names(c393) <- c('Year','Month','Day','P','Ep','Q','Qs','Qu')
names(c322) <- c('Year','Month','Day','P','Ep','Q','Qs','Qu')

# Create datetime columns
datetime <- function(df) {
    df$datetime <- paste(df$Year,formatC(df$Month,width=2,format='d',flag='0'),formatC(df$Day,width=2,format='d',flag='0'),sep='')
    df[,!(names(df) %in% c('Year','Month','Day'))]
}

c43 <- datetime(c43)
c22 <- datetime(c322)
c393 <- datetime(c393)

# Create FDC
fdc <- function(df,lab) {
    n <- length(unique(df[['datetime']]))
    df$rank <- rank(-df$Q)
    df$p <- 100 * ( df$rank / (n + 1) )
    print(max(df$p))
    print(min(df$p))
    #print(head(-order(df$rank)))
    png(lab)
    plot(df$p,df$Q)
    dev.off()
    print(head(df))


}

print(head(c43))
fdc(c43,'c43.png')

