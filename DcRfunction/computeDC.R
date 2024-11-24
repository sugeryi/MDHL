library(R.matlab)
library(energy)
Xk = readMat("./DataGen4_water_250/SPDXdistMetri4_water_250.mat")
data = Xk$CS
p = dim(data)[3]

CC = matrix(rep(0,p*p),p,p)
for (i in (1:(p-1))){
  for(j in ((i+1):p)){
    dx = data[,,i]
    dy = data[,,j]
    CC[i,j] = dcov.test(dx,dy,R=99)$p.value
    CC[j,i] = CC[i,j]
  }
}

writeMat("./DataGen4_water_250/DistCorr4_water_250.mat",DistCorr4_water_250=CC)
