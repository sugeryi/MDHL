library(clusterGeneration)
library(R.matlab)
size = readMat("./Data/spd2size.mat")
generate_batch_spd <- function(param, p = 3)
{
  sampled_spd <- sapply(param, function(x) {
    clusterGeneration::genPositiveDefMat(dim = p, "eigen", eigenvalue = x)[["Sigma"]]
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
source = readMat("./Data/source.mat")
source = source$source
source = as.numeric(source)
spddata <- generate_batch_spd(source)
writeMat("./Data/SPDdata2.mat",spddata=spddata)