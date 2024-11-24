library(Ball)
library(R.matlab)

Xk = readMat("E:/RL_data/AlarmDataMat.mat")
data = Xk$AlarmData
p = ncol(data)
CC = matrix(rep(0,p*p),p,p)

for (i in (1:(p-1))){
  for (j in ((i+1):p)){
    CC[i,j] = bcov.test(x=data[,i],y=data[,j])$p.value
    # CC[j,i] = CC[i,j]
  }
}
writeMat("E:/RL_data/AlarmDataMatPval.mat",pvalMatrix=CC)

