get_graph_from_road_network <- function(road_network, road_segment_data = data.frame(),
                                        attributeStr = '') {
  ## Returns an igraph object from the input road_network shapefile.
  ## The returned object has vertices as the intersections and edges as road segments.
  ## Each edge has its attributes inherited from those in the shapefile.
  
  require(rgdal)
  require(igraph)
  require(plyr)
  
  source("./code/util/getRoadSegmentData.R")
  
  if(nrow(road_segment_data) == 0) {
    road_segment_data <- getRoadSegmentData(road_network)
  }
  
  if(nchar(attributeStr) > 0) {
    if(attributeStr %in% names(road_segment_data)) {
      subset_roadSegment <- subset(road_segment_data, road_segment_data[, attributeStr] > 0)
      mean_attribute <- mean(subset_roadSegment[, attributeStr])
      print(mean_attribute)
      progress_bar <- create_progress_bar("text")
      progress_bar$init(nrow(road_segment_data))
      for(i in 1:nrow(road_segment_data)) {
        if(road_segment_data[i, attributeStr] == 0) {
          road_segment_data[i, attributeStr] <- mean_attribute
        }
        progress_bar$step()
      }
    } else {
      stop(paste('Attribute', attributeStr, 'does not exist!'))
    }
  }
  
  ## Finally, create an igraph object. Remember: igraph indices are zero-based
  edge_list <- cbind(road_segment_data[, c("from", "to")],
                     road_segment_data[, grep("^(from|to)$",
                                              names(road_segment_data), invert = TRUE)])
  edge_list$from <- edge_list$from - 1 # zero-based conversion
  edge_list$to <- edge_list$to - 1
  ## All the shapefile attributes are now edge attributes
  g <- graph.data.frame(edge_list, directed = FALSE)
  
  return(g)
}
