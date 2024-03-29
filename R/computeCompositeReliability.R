#' computeCompositeReliability: multivariate generalizability theory approach to estimate the composite reliability of student performance across different types of assessments.
#'
#' @param mydata A dataframe containing columns ID, Type, Score (numeric)
#' @param n A vector containing for each Type the number of scores or assessments, e.g. averages, requirements.
#' @param weights A vector containing for each Type the weight assigned to it. The sum of weights should be equal to 1.
#' @param optimizeSEM Boolean, if TRUE, the weights are adjusted in order to minimize the Standard Error of Measurement (SEM)
#'
#' @return A list containing the composite reliability coefficient, the SEM and the distribution of weights. If 'optimizeSEM' is set to TRUE, the vector of weights minimizes the SEM.
#' @export
#'
#' @examples
#' compRel <- computeCompositeReliability(mydata, n=c("A"=10, "B"=5, "C"=2),
#'                             weights=c("A"=1/3,"B"=1/3, "C"=1/3), optimizeSEM=TRUE)
#' compRel$reliability
#' compRel$SEM
#' compRel$weights

computeCompositeReliability <- function(mydata, n, weights, optimizeSEM) {
  checkDatasets(mydata, n, weights)
  varCovMatrix <- calculateVarCov(mydata, n)

  types <- sort(unique(mydata$Type))

  if(optimizeSEM) {
      weights[types[1]] = 1/(varCovMatrix$S_delta[types[1],types[1]] * sum(diag(1/varCovMatrix$S_delta)))
      for(t in 2:length(types)) {
        weights[types[t]] = weights[types[1]] * varCovMatrix$S_delta[types[1],types[1]]/varCovMatrix$S_delta[types[t],types[t]]
      }
  }

  weightMatrix <- weights %*% t(weights)

  w_S_p <- varCovMatrix$S_p * weightMatrix
  w_S_delta <- varCovMatrix$S_delta * weightMatrix

  sigma2_C_t = sum(w_S_p)
  sigma2_C_Delta = sum(w_S_delta)
  E_rho2 = sigma2_C_t/(sigma2_C_t+sigma2_C_Delta)
  SEM = sqrt(sigma2_C_Delta)

  return(list("reliability"=E_rho2, "SEM"=SEM, "weights"=weights))
}
