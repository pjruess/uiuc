library(glue)

df <- read.csv('results/input_data_clean_stage1_v1.csv')

for (y in 2000:2014) {

    y <- 2000

    df <- df[df$Year == y,]
    
    df = df[df$ISO != 'BEL' ,]
    df = df[df$ISO != 'NLD' ,]
    df = df[df$ISO != 'LUX' ,]
    df = df[df$ISO != 'MYS' ,]
    df = df[df$ISO != 'CHE' ,]
    
    pdf(glue('actual_vs_constructed_trade_openness_{y}.pdf'))
    plot(TO~openness_hat,main=glue('Actual vs. Constructed Trade Openness, {y}'),ylab='Actual Trade Openness',xlab='Constructed Trade Openness (Instrument)',data=df,pch=16,col='black',cex=0.7)
    with(df,text(TO~openness_hat,labels=df$ISO,pos=3,cex=0.7))
    abline(0,1,col='blue')
    dev.off()
    break
}
