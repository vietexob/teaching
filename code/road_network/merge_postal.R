rm(list = ls())

## Merge the postal codes (buildings) with the nodes of the SIN road network.
library(rgdal)
library(igraph)

source("./code/util/getSpatialLinesObj.R")
source("./code/util/findIntersections.R")
source("./code/util/earthDist.R")

## Read the postal CSV file
postal <- read.csv(file = './data/sin_postal.csv')

## Read the road subgraph graphml
filename <- './data/networks/sin_road_subgraph.graphml'
road_subgraph <- read.graph(file = filename, format = 'graphml')
## Convert from igraph object to edge data frame
road_segment <- get.data.frame(road_subgraph, what = 'edges')

## Read the road network shapefile
road_network <- readOGR(dsn = "./data/shapefiles/sin/", layer = "RoadSectionLine",
                        stringsAsFactors = FALSE)
## Transform into the "right" coordinate system
road_network <- spTransform(road_network, CRS("+proj=longlat +datum=WGS84"))
proj4string(road_network) <- CRS("+init=epsg:4326")

## Create spatial data frame to represent the road segments
segmentLinesDF <- getSpatialLinesObj(segment_data = road_segment,
                                     proj4Str = proj4string(road_network))

## Create a spatial data frame to represent the postal codes
postal_codes <- data.frame(x = postal$lon.js, y = postal$lat.js,
                           id = 'A', stringsAsFactors = FALSE)
coordinates(postal_codes) <- ~ x + y
proj4string(postal_codes) <- proj4string(road_network)
## Transform the points (postal codes) and segments into UTM (metric system)
## Singapore's UTM zone is 48N
postal_utm <- spTransform(postal_codes,
                          CRS("+proj=utm +north +zone=48 +ellps=WGS84 +datum=WGS84"))
segment_utm <- spTransform(segmentLinesDF,
                           CRS("+proj=utm +north +zone=48 +ellps=WGS84 +datum=WGS84"))

## Find the intersections between postal codes and road segments
postal_segment_rowIdx <- findIntersections(sp_geom1 = segment_utm, sp_geom2 = postal_utm,
                                           width = 300, top = 1)
## Create a data frame that connect postal codes and road segments
postal_segment_data <- data.frame()
for(i in 1:nrow(postal)) {
  postal_row <- postal[i, ]
  segment_rowIdx <- postal_segment_rowIdx[[toString(i)]]
  if(!is.null(segment_rowIdx)) {
    segment_row <- road_segment[segment_rowIdx, ]
    data_row <- cbind(postal_row, segment_row)
    postal_segment_data <- rbind(postal_segment_data, data_row)
  }
}
postal_segment_data$RD_CD_DESC <- NULL # drop that column

## Find the distance between each postal code point and end points of each segment
node_idx <- vector()
for(i in 1:nrow(postal_segment_data)) {
  postal_lon <- postal_segment_data$lon.js[i]
  postal_lat <- postal_segment_data$lat.js[i]
  from_lon <- postal_segment_data$from.x[i]
  from_lat <- postal_segment_data$from.y[i]
  from_dist <- earthDist(postal_lon, postal_lat, from_lon, from_lat)
  
  to_lon <- postal_segment_data$to.x[i]
  to_lat <- postal_segment_data$to.y[i]
  to_dist <- earthDist(postal_lon, postal_lat, to_lon, to_lat)
  
  if(from_dist == min(from_dist, to_dist)) {
    node_name <- postal_segment_data$from[i]
  } else {
    node_name <- postal_segment_data$to[i]
  }
  
  node_idx[i] <- which(V(road_subgraph)$name == node_name) - 1
}
postal_segment_data$node_idx <- node_idx

out_filename <- "./data/sin_postal_node_idx.csv"
write.csv(postal_segment_data, file = out_filename, row.names = FALSE)
print(paste("Written to file:", out_filename))
