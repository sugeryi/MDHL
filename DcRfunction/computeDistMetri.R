library(R.matlab)
Xk = readMat("./DataGen3/alarmSPD3.mat")

data = Xk$X

p = length(data)
pr=dim(data[[1]][[1]])[3]
datt = array(rep(0,pr*pr*p),dim=c(pr,pr,p))

for (i in (1:p)){
  datt[,,i] = CovTools::CovDist(data[[i]][[1]],method="LERM")
}

writeMat("./DataGen3/waterSPDXdistMetri3.mat",waterSPDXdistMetri3=datt)
