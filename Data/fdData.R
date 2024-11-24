library(R.matlab)
sourcecoef = readMat("./Data/sourcecoef.mat")
sourcecoef = sourcecoef$sourcecoef
sourcecoef = as.numeric(sourcecoef)
observe_point <- seq(0, 8 * pi, length.out = 17)
fourier.base <- fda::create.fourier.basis(rangeval = c(0, 8 * pi), 
                                          nbasis = 3,
                                          period = 2 * pi)
fourier.fd <- fda::fd(coef = matrix(sourcecoef, nrow = 3), 
                        basisobj = fourier.base)
fdadata <- t(fda::eval.fd(evalarg = observe_point, 
                                  fdobj = fourier.fd))
writeMat("./Data/FDdata.mat",fdadata=fdadata)