loess.plot <- function(model,xval,yval,degree,span,xname,yname,title,path){
	model.loess <- loess.smooth(
								x=ww_stats[,xval],
								y=ww_stats[,yval],
								degree=degree, # 1 = linear, 2 = quadratic
								span=span # 0 < span < 1
								)
	png(path)
	plot(
		 x=model[,xval],
		 y=model[,yval],
		 xlab=xval,
		 ylab=yval,
		 main=title
		 )
	lines( # points() or lines() adds to same plot
		 x=model.loess$x,
		 y=model.loess$y,
		 col='red',
		 lwd=1.5
		 )
	dev.off()
}

# Read in data
ww_stats <- read.csv('WorldWaterStats.csv')

x = 'IMSAN'
y = 'INFMORT'
degree = 1
if (degree -- 2) {degname = 'Linear'}
if (degree == 2) {degname = 'Quadratic'}
span = 0.3

loess.plot(
		   model=ww_stats,
		   xval=x,
		   yval=y,
		   degree=degree,
		   span=span,
		   title=sprintf('Loess Line Plot, %s vs. %s,\nDegree=%s, Span=%s',x,y,degname,span),
		   path='ww_stats_loess_line.png'
		   )