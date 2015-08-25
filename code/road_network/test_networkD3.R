rm(list = ls())

library(rgdal)
library(rgeos)
library(sp)
library(ggplot2)
library(networkD3)
library(magrittr)

source('./code/util/getRoadSegmentData.R')

## Read the road network shapefile
road.network <- readOGR(dsn = './data/shapefiles/pgh/StreetCenterlines',
                        layer = 'StreetCenterlines', stringsAsFactors = FALSE)
## Reproject the road network
road.network <- spTransform(road.network, CRS('+proj=longlat +datum=WGS84'))
road.network.data <- fortify(road.network)
## Retrieve the segment data frame from the road network
road.segment <- getRoadSegmentData(road.network)

## Select only the top few percentage road segmnets to visualize
## Otherwise, it becomes too big to be displayed
top <- 0.005
num.segments <- round(top * nrow(road.segment))
src <- road.segment$from[1:num.segments]
target <- road.segment$to[1:num.segments]
network.data <- data.frame(src, target)

## Visualize (and save) the network using D3
simpleNetwork(network.data) %>% saveNetwork(file = 'pgh_road_network_reduced.html')

## TODO: Use the new segment_speed data to visualize the network on a Shiny app!

