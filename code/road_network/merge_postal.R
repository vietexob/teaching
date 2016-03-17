rm(list = ls())

## Merge the postal codes (buildings) with the nodes of the SIN road network.

library(rgdal)
library(ggplot2)
library(igraph)

source("./code/util/getRoadSegmentData.R")
source("./code/util/getSpatialLinesObj.R")
source("./code/util/findIntersections.R")

## Read the postal CSV file
postal <- read.csv(file = './data/sin_postal.csv')

## Read the road network graphml
road_network <- readOGR(dsn = "./data/shapefiles/sin/", layer = "RoadSectionLine",
                        stringsAsFactors = FALSE)
## Transform into the "right" coordinate system
road_network <- spTransform(road_network, CRS("+proj=longlat +datum=WGS84"))
proj4string(road_network) <- CRS("+init=epsg:4326")

## Get the road segment data from road network
road_network_data <- fortify(road_network)
road_segment <- getRoadSegmentData(road_network)

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
                                           width = 250, top = 1)
## Create a data frame that connect postal codes and road segments

## Read the road subgraph (giant component)
filename <- './data/networks/sin_road_subgraph.graphml'
road_subgraph <- read.graph(file = filename, format = 'graphml')



