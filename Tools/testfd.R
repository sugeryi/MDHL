library(Ball)
library(R.matlab)
Xk = readMat("./sz1_pre_fd.mat")
data = Xk$X
p = length(data)
CC = matrix(rep(0,p*p),p,p)
for (i in (1:(p-1))){
  for(j in ((i+1):p)){
    dx = fda.usc::metric.lp(data[[i]][[1]], lp = 0)
    dy = fda.usc::metric.lp(data[[j]][[1]], lp = 0)
    CC[i,j] = bcov.test(x=dx,y=dy,num.permutations=99,distance=TRUE)$p.value
    CC[j,i] = CC[i,j]
  }
}
writeMat("./pvalMatrix2.mat",pvalMatrix2=CC)