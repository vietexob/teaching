rm(list = ls())

library(networkD3)
library(magrittr)

## Read the segment speed file
segment.speed <- read.csv(file = './data/traffic/pgh_train_segment_speed_august.csv',
                          stringsAsFactors = FALSE)
# segment.speed <- read.csv(file = './data/traffic/pgh_test_segment_speed_august.csv',
#                           stringsAsFactors = FALSE)
# segment.speed <- read.csv(file = './data/traffic/was_train_segment_speed_august.csv',
#                           stringsAsFactors = FALSE)

## Select only the top few percentage road segmnets to visualize
## Otherwise, it becomes too big to be displayed
top <- 1
num.segments <- round(top * nrow(segment.speed))
src <- segment.speed$from[1:num.segments]
target <- segment.speed$to[1:num.segments]
network.data <- data.frame(src, target)

## Visualize (and save) the network using D3
simpleNetwork(network.data) %>% saveNetwork(file = 'pgh_road_network_train.html')

## TODO: Use the new segment_speed data to visualize the network on a Shiny app!

library(ndtv)
library(network)

## Prepare and edgelist data frame
## Rename each node to 1..n.nodes
nodeId.nodeNum <- new.env()
counter <- 1
for(src.node in src) {
  src.nodeStr <- toString(src.node)
  if(is.null(nodeId.nodeNum[[src.nodeStr]])) {
    nodeId.nodeNum[[src.nodeStr]] <- counter
    counter <- counter + 1
  }
}
for(target.node in target) {
  target.nodeStr <- toString(target.node)
  if(is.null(nodeId.nodeNum[[target.nodeStr]])) {
    nodeId.nodeNum[[target.nodeStr]] <- counter
    counter <- counter + 1
  }
}

src.nodeNum <- vector()
target.nodeNum <- vector()
for(i in 1:num.segments) {
  src.nodeStr <- toString(segment.speed$from[i])
  nodeNum <- nodeId.nodeNum[[src.nodeStr]]
  src.nodeNum[i] <- nodeNum
  
  target.nodeStr <- toString(segment.speed$to[i])
  nodeNum <- nodeId.nodeNum[[target.nodeStr]]
  target.nodeNum[i] <- nodeNum
}
n.nodes <- max(max(src.nodeNum), max(target.nodeNum))

network.data <- cbind(src = src.nodeNum, target = target.nodeNum,
                      avg.speed = round(segment.speed$avg_speed, 2),
                      street.name = segment.speed$street.name)

## Create a network object from edgelist
road.network <- network.edgelist(x = network.data,
                                 g = network.initialize(n.nodes, directed = FALSE),
                                 ignore.eval = FALSE,
                                 names.eval = c('avg.speed', 'street.name'))

## Visualize the network
out.filename <- './data/networks/pgh_train_segments.html'
render.d3movie(road.network, vertex.cex = 0.25, vertex.border = '#FFD700',
               vertex.lwd = 0.05, edge.col = '#808080', edge.lwd = 0.50,
               edge.border = '#FFFFFF',
               edge.tooltip = paste('<b>Name:</b>', (road.network %e% 'street.name'), '<br>',
                                    '<b>Avg. Speed:</b>', (road.network %e% 'avg.speed')),
               main = 'PGH (Train) Road Network',
               launchBrowser=F, filename=out.filename, output.mode='HTML')

## Covert from network to igraph
library(intergraph)
library(igraph)

road.graph <- asIgraph(road.network)
## Give the graph edge weights
E(road.graph)$weight <- E(road.graph)$avg.speed

## Find the shortest path between two given nodes
foo <- shortest_paths(road.graph, from = 313, output = 'both')


