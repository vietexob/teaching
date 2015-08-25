getRoadSegmentData <- function(road_network) {
  ## Returns the road segment data frame from the input road_network shapefile
  ## Original: https://stat.ethz.ch/pipermail/r-sig-geo/2010-December/010264.html
  
  require(rgdal)
  
  ## Build a data frame of road segment end point coordinates
  road_segment <- t(sapply(unlist(coordinates(road_network), recursive = FALSE),
                           FUN = function(x) cbind(x[1, ], x[nrow(x), ])))
  road_segment <- as.data.frame(road_segment)
  names(road_segment) <- c("from.x", "from.y", "to.x", "to.y")
  
  ## Complete the vertex table
  if(nrow(road_network) == nrow(road_segment)) {
    n2 <- cbind(road_network, road_segment)
  } else {
    len <- ifelse(nrow(road_network) < nrow(road_segment), nrow(road_network),
                  nrow(road_segment))
    n2 <- cbind(road_network[1:len, ], road_segment[1:len, ])
  }
  
  v <- unique(rbind(data.frame(X = n2$from.x, Y = n2$from.y),
                    data.frame(X = n2$to.x, Y = n2$to.y)))
  v$ID <- 1:nrow(v)
  
  ## Match back to the original network coordinates to assign vertex IDs to
  ## each feature end point
  n3 <- merge(n2, data.frame(from = v$ID, from.x = v$X, from.y = v$Y),
              by = c("from.x", "from.y"))
  n4 <- merge(n3, data.frame(to = v$ID, to.x = v$X, to.y = v$Y),
              by = c("to.x", "to.y"))
  
  return(n4)
}
