convertSPLines <- function(input.data=data.frame(), has.attributes=TRUE) {
  ## Converts an input segment data frame into spatial lines data.
  library(sp)
  
  ## Specify the coordinates of the ending points
  begin.coord <- data.frame(lon = input.data$from.x, lat = input.data$from.y)
  end.coord <- data.frame(lon = input.data$to.x, lat = input.data$to.y)
  
  ## Road attributes
  if(has.attributes) {
    indicator <- input.data$indicator
    travel_time <- round(input.data$travel_time, 2)
    attribute.data <- data.frame(indicator = indicator,
                                 travel_time = travel_time, stringsAsFactors = FALSE)
  } else {
    attribute.data <- data.frame(id = 1:nrow(input.data))
  }
  
  l <- vector("list", nrow(begin.coord))
  for (i in seq_along(l)) {
    l[[i]] <- Lines(list(Line(rbind(begin.coord[i, ], end.coord[i,]))), as.character(i))
  }
  output <- SpatialLines(l)
  final.output <- SpatialLinesDataFrame(output, data = attribute.data)
  
  return(final.output)
}
