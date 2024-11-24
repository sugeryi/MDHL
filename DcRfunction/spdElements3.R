library(clusterGeneration)
library(R.matlab)
size = readMat("./ChainData/GenData1000/spd1size.mat")
size = size$nSamples
generate_batch_spd <- function(param, p = 2)
{
  sampled_spd <- sapply(param, function(x) {
    clusterGeneration::genPositiveDefMat(dim = p, "eigen", lambdaLow = x[1],
                                         ratioLambda = x[2])[["Sigma"]]
  }, simplify = "array")
  symApply <- apply(sampled_spd, 3, Matrix::isSymmetric, 
                    tol = sqrt(.Machine$double.eps))
  if (all(symApply)) {
  } else {
    sampled_spd <- sapply(param, function(x) {
      clusterGeneration::genPositiveDefMat(dim = p, "eigen", lambdaLow = 1,
                                           ratioLambda = 10)[["Sigma"]]
    }, simplify = "array")
  }
  sampled_spd
}
eigenvalue <- data.frame(t(data.frame(rep(1, size), rep(10, size))))
spddata <- generate_batch_spd(eigenvalue)
writeMat("./ChainData/GenData1000/SPDdata1.mat",spddata=spddata)
