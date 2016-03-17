findIntersections <- function(sp_geom1, sp_geom2 = NULL, width = 10, top = 3) {
  ## Finds the intersections between the two input spatial data frames. The second
  ## spatial geometry is padded with a 'buffer' if needed. If there are multiple intersections,
  ## only the 'top' nearest ones are included. The returned list is mapping between the
  ## row indices of the second geometry with those of the intersected first one.
  
  library(rgdal)
  library(rgeos)
  library(plyr)
  
  if(is.null(sp_geom2)) {
    stop("Invalid input arguments!")
  }
  
  ## Add a small buffer of width (meters) around the poins to make them have areas
  if(width > 0) {
    sp_geom2 <- gBuffer(sp_geom2, byid = TRUE, width = width)
  }
  
  ## Find all intersections between the points and lines
  spIntersections <- gIntersects(sp_geom1, sp_geom2, byid = TRUE)
  nIntersections <- 0
  sp2_sp1_rowIndices <- new.env() # map each POI to its nearest matched segment
  progress_bar <- create_progress_bar("text")
  progress_bar$init(nrow(spIntersections))
  for(i in 1:nrow(spIntersections)) {
    nMatches <- sum(spIntersections[i, ])
    if(nMatches > 0) {
      matchedIndices <- as.numeric(which(spIntersections[i, ] == TRUE))
      if(length(matchedIndices) == 1) {
        sp2_sp1_rowIndices[[toString(i)]] <- matchedIndices
      } else {
        distVector <- gDistance(sp_geom2[i, ], sp_geom1[matchedIndices, ], byid = TRUE)
        sortedIndices <- order(distVector)
        sp1_rowIndices <- rownames(distVector)[sortedIndices]
        len <- ifelse(length(sp1_rowIndices) > top, top, length(sp1_rowIndices))
        sp2_sp1_rowIndices[[toString(i)]] <- as.numeric(sp1_rowIndices)[1:len]
      }
      
      nIntersections <- nIntersections + 1
    }
    progress_bar$step()
  }
  pctIntersections <- round(nIntersections / nrow(sp_geom2) * 100, 2)
  print(paste("Width =", width, "; Percentage =", pctIntersections))
  
  return(sp2_sp1_rowIndices)
}
