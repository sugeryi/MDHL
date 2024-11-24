
library(R.matlab)
library(Ball)

Xk = readMat("./ChainData/GenData100/SpdChain100DataOrign.mat")
data = Xk$CS
p = length(data)
CC = matrix(rep(0,p*p),p,p)
for (i in (1:(p-1))){
  for(j in ((i+1):p)){
    dx = CovTools::CovDist(data[[i]][[1]])
    dy = CovTools::CovDist(data[[j]][[1]])
    CC[i,j] = bcov.test(x=dx,y=dy,num.permutations=99,distance=TRUE)$p.value
    # CC[i,j] = dcov.test(x=dx,y=dy,num.permutations=99)$p.value
  }
}
# p = ncol(data)/3
# CC = matrix(rep(0,p*p),p,p)
# # CC[1,8] = bcov.test(x=data[,1],y=data[,8])$p.value
# for (i in (1:(p-1))){
#   for (j in ((i+1):p)){
#     dx = nhdist(data[,c(3*i-2,3*i-1,3*i)],method="geodesic")
#     dy = nhdist(data[,c(3*j-2,3*j-1,3*j)],method="geodesic")
#     CC[i,j] = bcov.test(x=dx,y=dy,num.permutations=99,distance=TRUE)$p.value
#   }
# }
# writeMat("D:/program/matlab/spddag20.mat",ManifoldCC=CC)
# writeMat("D:/program/matlab/alarmSPD.mat",ManifoldCC=CC)
# writeMat("E:/causal-learn-zy/NEHL-main/Data/pvalMatrix1.mat",pvalMatrix1=CC)
writeMat("./ChainData/GenData100/pvalMatrixOrign.mat",pvalMatrix1=CC)

