library(R.matlab)
library(PCOR)

Xk = readMat("./DataGen3_250/SPDXdistMetrilogm3_250.mat")
data = Xk$CS
p = dim(data)[3]

CP = matrix(rep(0,p*p),p,p)
for (i in (1:(p-1))){
  for(j in ((i+1):p)){
    dx = data[,,i]
    dy = data[,,j]
    CP[i,j] = pcor(dx,dy)
    CP[j,i] = CP[i,j]
  }
}

writeMat("./DataGen3_250/ProjCorrlogm3_250.mat",ProjCorrlogm3_250=CP)
