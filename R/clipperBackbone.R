# Copyright 2012 Paolo Martini <paolo.martini@unipd.it>
#
#
# This file is part of clipper.
#
# clipper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License
# version 3 as published by the Free Software Foundation.
#
# clipper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with clipper. If not, see <http://www.gnu.org/licenses/>.

cmpLists <- function(l1,l2) {
  if (length(l1) != length(l2))
    return(FALSE)
  all(sapply(1:length(l1), function(i) all(l1[[i]]==l2[[i]])))
}

consecutiveFragments <- function(indexes, maxGap) {
  edges <- c(0, which(indexes[-1]-head(indexes, n=-1) > (maxGap+1))) + 1
  upperBound <- c(indexes[edges-1], tail(indexes, n=1))
  lowerBound <- indexes[edges]
  lapply(seq_along(upperBound), function(i) c(lowerBound[i]:upperBound[i]))
}

bestFragment <- function(pvalueInverted, signs, fragmentList){
  if (is.null(names(pvalueInverted)))
    stop("In bestFragment: no names provided in pvaluesInverted.")
  
  theBest <- -Inf
  ind=NA
  for (idx in fragmentList){
    wayPvalues = pvalueInverted[idx]
    waySigns   = signs[idx]
    cumulative <- cumsum(-log(wayPvalues)*waySigns)
    names(cumulative) <- names(wayPvalues)
    
    if (max(theBest) < max(cumulative)){
      theBest <- cumulative
      ind=idx
    }
  }
  return(list(best=theBest, indices=ind))
}

bestFragmentOnPath <- function(pvalues, trZero, thr, gaps){
  if (any(is.na(pvalues)))
    return(list(best=NA, indices=NA))
  
  l <- length(pvalues)
  pvalues[pvalues < trZero] <- trZero
  signs <- rep(-1,length(pvalues))
  signs[pvalues <= thr] <- 1
  
  pvalueInverted <- pvalues
  pvalueInverted[pvalues > thr] <- 1-pvalues[pvalues > thr]
  
  startingPoints <- which(pvalues <= thr)
  
  if (length(startingPoints) == 0)
    return(list(best=NA, indices=paste("No cliques with pvalue <= ", thr, sep="")))
  
  bestFragment(pvalueInverted, signs, consecutiveFragments(startingPoints, gaps))
}

completeFormat <- function(subPath, alpha, path, trZero){
  clNames <- names(alpha)
  l <- length(path)
  
  wayCliques <- paste(path, collapse=",")
  wayGenes <- paste(clNames[path], collapse=",")
  
  if (any(is.na(subPath$best)))
    return(c(path[1],tail(path,1),NA,l,NA,NA,NA,NA,NA,
             wayCliques,NA,wayGenes))

  cumulative <- subPath$best
  indices    <- subPath$indices
  maxScore <- max(cumulative)
  idxMax <- match(maxScore,cumulative)

  score <- maxScore * idxMax / l
  averageScore <- maxScore / l
  impactOnPath <- l / length(alpha)
  teoricalScore <- -log(trZero) * l

  involvedCliques <- paste(path[indices], collapse=",")
  involvedGenes <- paste(clNames[path[indices]], collapse=";")
  
  c(path[1],
    tail(path,1),
    idxMax,
    l,
    score,
    averageScore,
    score/teoricalScore,
    impactOnPath,
    involvedCliques,
    wayCliques,
    involvedGenes,
    wayGenes)
}


formatBestSubPath <- function(alpha, path, trZero, thr, maxGap) {
  subPath <- bestFragmentOnPath(alpha[path], trZero, thr, maxGap)
  completeFormat(subPath, alpha, path, trZero)
}
