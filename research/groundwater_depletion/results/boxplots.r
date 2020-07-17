library(ggplot2)
library(reshape2)
library(glue)

df <- read.csv('DWF_sum.csv')

m <- melt(df,id.vars='STATEFP')

print(head(m))

for ( i in colnames(df)[2:7] ) {

    print(i)

    temp <- m[m$variable==i,]
    print(head(temp))

    n <- strsplit(i,'_')
    flow <- n[[1]][1]
    year <- n[[1]][2]

    ymax <- 0

    if ( n[[1]][1] == 'DWT' ) {
        ymax <- 200.
        col <- 'skyblue4'
        tit <- 'Transfers'
    }
    if ( n[[1]][1] == 'DWE' ) { 
        ymax <- 5.
        col <- 'darkseagreen4'
        tit <- 'Exports'
    }
    if ( n[[1]][1] == 'DWF' ) {
        ymax <- 200.
        col <- 'darkorchid4'
        tit <- 'All Flows'
    }

    print(col)

    ylab <- glue('{flow} [million m3]')
    xlab <- year

    #quants <- quantile(temp$value,probs = c(0.25, 0.75))
    #iqr <- quants[[2]] - quants[[1]]
    #ymax <- quants[[2]] + 1.5 * iqr
    #ymin <- quants[[1]] - 1.5 * iqr

    ggplot(temp,aes(x=variable,y=value)) + 
        geom_boxplot(outlier.shape=NA,fill=col) + 
        ylim(0,ymax) +
        theme(axis.text=element_text(size=30),axis.title=element_text(size=36,face='bold'),axis.text.x=element_blank(),plot.title=element_text(size=44,face='bold',hjust=0.5)) +
        labs(title=tit,y=ylab,x=xlab)

    ggsave(glue('plot_{i}.png'))

}

