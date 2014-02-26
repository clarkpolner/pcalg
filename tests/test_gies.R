#' Tests the causal inference algorithms for interventional data:
#' GIES, GES, DP
#' 
#' @author Alain Hauser
#' $Id: test_gies.R 224 2014-02-06 14:23:53Z alhauser $

cat("Testing the causal inference algorithms for interventional data:\n")

library(pcalg)

load("test_bicscore.rda") # in directory tests/ i.e., typically *not* installed
str(gauss.data)
p <- ncol(gauss.data)

(doExtras <- pcalg:::doExtras())
DBG <- if(doExtras) TRUE else FALSE # no debugging by default
## Tolerance for numerical comparison
tol <- sqrt(.Machine$double.eps) # = default for all.equal()

fcns <- c(GIES = gies, GDS = gds)
nreps <- 10

for (nf in names(fcns)) {
  cat(if(doExtras)"\n\n", nf, if(doExtras)":\n" else ": ... ",
      if(doExtras) paste0(paste(rep("=", nchar(nf)), collapse=""), "\n"),
      sep = "")
  for (cpp in c(FALSE, TRUE)) {
    ## Randomly permute data
    for (i in 1:nreps) {
      perm <- 1:nrow(gauss.data)
      if (i > 1) {
        set.seed(i)
        perm <- sample(perm)
      }
      score <- new("GaussL0penIntScore", 
                   targets = gauss.targets, 
                   target.index = gauss.target.index[perm], 
                   data = gauss.data[perm, ],
                   use.cpp = cpp)
      est.graph <- fcns[[nf]](p, gauss.targets, score, verbose = DBG)
      for (i in 1:p) {
        if(doExtras) cat("  use.cpp = ", cpp,"; i = ", i, "\n", sep="")
        if (!isTRUE(all.equal(est.graph$essgraph$.in.edges[[i]],
                              gauss.parents[[i]], tolerance = tol)))
          stop("Parents are not estimated correctly.")
      }
      print(proc.time())
    }
  }
  cat("[Ok]\n")
}

cat(if(doExtras) "\n", "Done.\n")