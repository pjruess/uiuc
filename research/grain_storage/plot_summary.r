library(reshape2)
library(ggplot2)
library(data.table)

df <- read.csv( 'final_results/summary.csv' )

df <- melt( df, id.vars = 'Variable' )

df <- with( df, cbind( Variable, colsplit( df$variable, pattern = '\\_', names = c( 'Geography', 'year', 'func' )), value ))

df <- df[ df$func == 'sum', ]

df <- dcast(df, ...~func, value.var = 'value')

df <- df[ (df$Variable == 'Storage_Bu') | (df$Variable == 'VWS_m3' ) | (df$Variable == 'Production_Bu') | (df$Variable == 'Harvest_Ac' ),]

# Normalize variables
#normalize <- function(n){
#    (n - min(n))/(max(n)-min(n))
#}
#
#df <- data.frame(setDT(df)[, .(value=normalize(sum)), by=list(Variable,Geography)])
#print(df)

# States only
s <- df[ df$Geography == 'state', ]
print(s)
ggplot(data=s, aes(x=year, y=sum, color=Variable, group=Variable, shape=Variable)) + 
    geom_point() + geom_line(aes(linetype=Variable)) + 
    scale_x_continuous(breaks=c(2002,2007,2012), minor_breaks=NULL) +# scale_y_continuous(trans='log10') +
    labs(title='Variable Change Over Time',x='Year',y='Value') + 
    theme(plot.title=element_text(hjust=0.5))
ggsave('cot_plot_state.png', width = 7, height = 4.25) # save plot

# Counties only
c <- df[ df$Geography == 'county', ]
print(c)
ggplot(data=c, aes(x=year, y=sum, color=Variable, group=Variable, shape=Variable)) + 
    geom_point() + geom_line(aes(linetype=Variable)) +
    scale_x_continuous(breaks=c(2002,2007,2012), minor_breaks=NULL) + scale_y_continuous(trans='log10') +
    labs(title='Variable Change Over Time',x='Year',y='Value') +
    theme(plot.title=element_text(hjust=0.5))
ggsave('cot_plot_county.png', width = 7, height = 4.25) # save plot

# Both states and counties
df$groups <- interaction(df$Variable,df$Geography)
df
ggplot(data=df, aes(x=year, y=sum, color=Variable, shape=Geography, group=groups)) + 
    geom_point(size=4) + geom_line(aes(linetype=Geography),size=1.5) +
    scale_x_continuous(breaks=c(2002,2007,2012), minor_breaks=NULL) + scale_y_continuous(trans='log10') +
    labs(title='Variable Change Over Time',x='Year',y='Value') +
    theme(plot.title=element_text(hjust=0.5,size=22),
          axis.title=element_text(size=20),
          axis.text=element_text(size=18),
          legend.title=element_text(size=20),
          legend.text=element_text(size=18))
ggsave('cot_plot.png', width = 8.97, height = 5.3) # save plot
