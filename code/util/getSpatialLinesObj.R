getSpatialLinesObj <- function(segment_data = data.frame(), from.x = "from.x",
                               from.y = "from.y", to.x = "to.x", to.y = "to.y",
                               proj4Str = "") {
  ## Returns a SpatialLinesDataFrame object from the input segment_data.
  
  library(rgdal)
  library(plyr)
  
  if(nrow(segment_data) == 0) {
    stop("Empty segment_data passed!")
  }
  
  if(nchar(proj4Str) == 0) {
    stop("Empty proj4Str passed!")
  }
  
  lineList <- list()
  progress_bar <- create_progress_bar("text")
  progress_bar$init(nrow(segment_data))
  for(i in 1:nrow(segment_data)) {
    lineList[[i]] <- Lines(Line(rbind(as.numeric(segment_data[i, c(from.x, from.y)]),
                                      as.numeric(segment_data[i, c(to.x, to.y)]))),
                           ID = as.character(i))
    progress_bar$step()
  }
  
  segmentLines <- SpatialLines(lineList, proj4string = CRS(proj4Str))
  segmentLinesDF <- SpatialLinesDataFrame(segmentLines, segment_data, match.ID = FALSE)
  return(segmentLinesDF)
}
