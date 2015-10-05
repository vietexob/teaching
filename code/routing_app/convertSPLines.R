library(sp)

convertSPLines <- function(input.data=data.frame()) {
  ## Specify the coordinates of the ending points
  begin.coord <- data.frame(lon = input.data$from.x, lat = input.data$from.y)
  end.coord <- data.frame(lon = input.data$to.x, lat = input.data$to.y)
  
  ## Road attributes
  indicator <- input.data$indicator
  st.name <- input.data$st.name
  seg.len <- round(input.data$seg.len, 2)
  speed <- round(input.data$speed, 2)
  attribute.data <- data.frame(indicator = indicator, st.name = st.name,
                               seg.len = seg.len, speed = speed, stringsAsFactors = FALSE)
  
  l <- vector("list", nrow(begin.coord))
  for (i in seq_along(l)) {
    l[[i]] <- Lines(list(Line(rbind(begin.coord[i, ], end.coord[i,]))), as.character(i))
  }
  output <- SpatialLines(l)
  final.output <- SpatialLinesDataFrame(output, data = attribute.data)
  return(final.output)
}
