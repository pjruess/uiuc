
data <- read.csv(
	'WorldWaterStats.csv'
	)

M <- data.matrix(data)
X <- M[,c(1,5,6)]
X <- cbind(rep(1,nrow(X)),X)
Y <- M[,c(3)]

B_hat <- solve(t(X)%*%X)%*%(t(X)%*%Y)
B_hat




