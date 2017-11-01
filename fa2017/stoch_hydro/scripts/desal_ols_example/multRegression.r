rawdata<-read.csv("EnergyforDesal-literature.csv", header=TRUE)
attach(rawdata)
thedata<-data.frame(EQKWHE, RWM3D, PWM3D, INVR1, RWTDS, PWTDS, P, ER, TEMP)
Labels<-names(thedata)[2:length(thedata)]
multRegress<-function(mydata){
numVar<<-NCOL(mydata)
Variables<<- names(mydata)[2:numVar]
# print(mydata)
# print('----------------')
mydata<-cor(mydata, use="complete.obs")
# print(mydata)
# stop()
RXX<-mydata[2:numVar,2:numVar]
RXY<-mydata[2:numVar,1]

RXX.eigen<-eigen(RXX)
D<-diag(RXX.eigen$val)
delta<-sqrt(D)

lambda<-RXX.eigen$vec%*%delta%*%t(RXX.eigen$vec)
lambdasq<-lambda^2
beta<-solve(lambda)%*%RXY
rsquare<<-sum(beta^2)

RawWgt<-lambdasq%*%beta^2
import<-(RawWgt/rsquare)*100

result<<-data.frame(Variables, Raw.RelWeight=RawWgt, Rescaled.RelWeight=import)
}


multBootstrap<-function(mydata, indices){
	mydata<-mydata[indices,]
	multWeights<-multRegress(mydata)
	return(multWeights$Raw.RelWeight)
}

multBootrand<-function(mydata, indices){
	mydata<-mydata[indices,]
	multRWeights<-multRegress(mydata)
	multReps<-multRWeights$Raw.RelWeight
	randWeight<-multReps[length(multReps)]
	randStat<-multReps[-(length(multReps))]-randWeight
	return(randStat)
}

#bootstrapping
# install.packages("boot")
library(boot)

mybootci<-function(x){
	boot.ci(multBoot,conf=0.95, type="bca", index=x)
}

runBoot<-function(num){
	INDEX<-1:num
	test<-lapply(INDEX, FUN=mybootci)
	test2<-t(sapply(test,'[[',i=4)) #extracts confidence interval
	CIresult<<-data.frame(Variables, CI.Lower.Bound=test2[,4],CI.Upper.Bound=test2[,5])
}
myRbootci<-function(x){
	boot.ci(multRBoot,conf=0.95,type="bca",index=x)
}

runRBoot<-function(num){
	INDEX<-1:num
	test<-lapply(INDEX,FUN=myRbootci)
	test2<-t(sapply(test,'[[',i=4))
CIresult<<-data.frame(Labels,CI.Lower.Bound=test2[,4],CI.Upper.Bound=test2[,5])
}

myCbootci<-function(x){
	boot.ci(multC2Boot,conf=0.95,type="bca",index=x)
}

runCBoot<-function(num){
	INDEX<-1:num
	test<-lapply(INDEX,FUN=myCbootci)
	test2<-t(sapply(test,'[[',i=4))
CIresult<<-data.frame(Labels2,CI.Lower.Bound=test2[,4],CI.Upper.Bound=test2[,5])
}

myGbootci<-function(x){
	boot.ci(groupBoot,conf=0.95,type="bca",index=x)
}

runGBoot<-function(num){
	INDEX<-1:num
	test<-lapply(INDEX,FUN=myGbootci)
	test2<-t(sapply(test,'[[',i=4))
CIresult<<-data.frame(Labels,CI.Lower.Bound=test2[,4],CI.Upper.Bound=test2[,5])
}



multRegress(thedata)
RW.Results<-result

RSQ.Results<-rsquare


#Bootstrapped Confidence interval around the individual relative weights
#Please be patient -- This can take a few minutes to run
multBoot<-boot(thedata, multBootstrap, 10000)
multci<-boot.ci(multBoot,conf=0.95, type="bca")
runBoot(length(thedata[,2:numVar]))
CI.Results<-CIresult

#Bootstrapped Confidence interval tests of Significance
#Please be patient -- This can take a few minutes to run
randVar<-rnorm(length(thedata[,1]),0,1)
randData<-cbind(thedata,randVar)
multRBoot<-boot(randData,multBootrand, 10000)
multRci<-boot.ci(multRBoot,conf=0.95, type="bca")
runRBoot(length(randData[,2:(numVar-1)]))
CI.Significance<-CIresult


#R-squared For the Model
RSQ.Results


#The Raw and Rescaled Weights
RW.Results
#BCa Confidence Intervals around the raw weights
CI.Results
#BCa Confidence Interval Tests of significance
#If Zero is not included, Weight is Significant
CI.Significance



