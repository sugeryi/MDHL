
library(R.matlab)
library(energy)
#library(Ball)


Xk = readMat("./DataGen4_250_3/SPDXdistMetri4_alarm_250.mat")
data = Xk$CS
p = dim(data)[3]
CC = matrix(rep(0,p*p),p,p)
for (i in (1:(p-1))){
  for(j in ((i+1):p)){
    dx = data[,,i]
    dy = data[,,j]
    CC[i,j] = dcor(dx, dy)
    #CC[i,j] = bcor(dx, dy)
    CC[j,i] = CC[i,j]
  }
}

writeMat("./DataGen4_250_3/dcorMatrix4_alarm_250.mat",dcorMatrix4_alarm_250=CC)

