plotSegments <- function(mean_lon=0, mean_lat=0, segment_data=data.frame(),
                         aesStr=aes_string(), zoom=12, alpha=0.80, color='red',
                         is_quiet=TRUE, lwd=1.50, titleStr='Untitled', out_filename="",
                         poi_data = data.frame(), poi_aesStr = aes_string()) {
  ## Retrieve a map from OSM and overlays the line segments from segment_data over it.
  library(ggplot2)
  library(ggmap)
  
  source("./code/util/fivethirtyeight_theme.R")
  
  if(mean_lon==0 | mean_lat==0 | nrow(segment_data)==0 | length(aesStr)==0) {
    stop("Invalid params passed!")
  }
  
  ## Remove the axis labels when called in the plot
  x_quiet <- scale_x_continuous("", breaks = NULL)
  y_quiet <- scale_y_continuous("", breaks = NULL)
  quiet <- list(x_quiet, y_quiet)
  
  segment_map <- get_map(location = c(lon = mean_lon, lat = mean_lat),
                         zoom = zoom, source = 'osm')
  segment_map <- ggmap(segment_map) +
    geom_segment(data = segment_data, aesStr,
                 alpha = alpha, col = color, lwd = lwd) + ggtitle(titleStr) +
    fivethirtyeight_theme()
  
  if(nrow(poi_data) > 0) {
    segment_map <- segment_map + geom_point(data = poi_data, poi_aesStr,
                                            color = 'blue', shape = 20)
  }
  
  if(is_quiet) {
    segment_map <- segment_map + quiet
  }
  
  print(segment_map)
  
  if(nchar(out_filename) > 0) {
    ggsave(filename = out_filename, scale = 4, dpi = 400)
    print(paste("Saved plot to file:", out_filename))
  }
}
