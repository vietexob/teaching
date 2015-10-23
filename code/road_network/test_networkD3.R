rm(list = ls())

library(networkD3)
library(magrittr)
library(ndtv)
library(network)
library(intergraph)
library(igraph)

is.pgh <- TRUE # is this for Pittsburgh?
## Read the segment speed file
if(is.pgh) {
  segment.speed <- read.csv(file = './data/traffic/pgh_train_segment_speed_august.csv',
                            stringsAsFactors = FALSE)
#   segment.speed <- read.csv(file = './data/traffic/pgh_test_segment_speed_august.csv',
#                             stringsAsFactors = FALSE)
} else {
  segment.speed <- read.csv(file = './data/traffic/was_train_segment_speed_august.csv',
                            stringsAsFactors = FALSE)
#   segment.speed <- read.csv(file = './data/traffic/was_test_segment_speed_august.csv',
#                             stringsAsFactors = FALSE)
}

## Select only the top few percentage road segmnets to visualize
## Otherwise, it becomes too big to be displayed
top <- 0.50
num.segments <- round(top * nrow(segment.speed))
src <- segment.speed$from[1:num.segments]
target <- segment.speed$to[1:num.segments]
network.data <- data.frame(src, target)

## Visualize (and save) the network using D3
if(is.pgh) {
  out.filename <- './files/pgh_road_network_train.html'
  # out.filename <- 'pgh_road_network_test.html'
} else {
  out.filename <- './files/was_road_network_train.html'
  # out.filename <- 'was_road_network_test.html'
}

simpleNetwork(network.data) %>% saveNetwork(file = out.filename)

## TODO: Use the new segment_speed data to visualize the network on a Shiny app!

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

## Recode its node to its number
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

## Create an edgelist dataset
network.data <- cbind(src = src.nodeNum, target = target.nodeNum,
                      speed = round(segment.speed$avg_speed, 2),
                      length = round(segment.speed$length, 2),
                      name = segment.speed$street.name)

## Create a network object from edgelist
road.network <- network.edgelist(x = network.data,
                                 g = network.initialize(n.nodes, directed = FALSE),
                                 ignore.eval = FALSE,
                                 names.eval = c('speed', 'length', 'name'))

## Visualize the network
if(is.pgh) {
  out.filename <- './files/pgh_train_segments.html'
  mainStr <- 'PGH (Train) Road Network'
} else {
  out.filename <- './files/was_train_segments.html'
  mainStr <- 'WAS (Train) Road Network'
}

## Highlight the source and destination
src.node <- 55
dst.node <- 237
src.dst.nodes <- c(src.node, dst.node)
all.nodes <- 1:n.nodes
road.network %v% 'col' <- ifelse(all.nodes %in% src.dst.nodes, '#32B232', '#FF0000')
render.d3movie(road.network, vertex.cex = 0.25, vertex.border = '#FFD700',
               vertex.lwd = 0.05, vertex.col = road.network %v% 'col',
               edge.col = '#808080', edge.lwd = 0.50, edge.border = '#FFFFFF',
               edge.tooltip = paste('<b>Speed:</b>', (road.network %e% 'speed'), '<br>',
                                    '<b>Length:</b>', (road.network %e% 'length'), '<br>',
                                    '<b>Name:</b>', (road.network %e% 'name')),
               main = mainStr, launchBrowser=F, filename=out.filename, output.mode='HTML')

## Covert from network to igraph object
road.graph <- asIgraph(road.network)
## Give the graph edge weights (as the avg. travel times)
road.lengths <- as.numeric(E(road.graph)$length)
road.speeds <- as.numeric(E(road.graph)$speed)
E(road.graph)$weight <- road.lengths / road.speeds

## Find the shortest path between two given nodes
sp <- shortest_paths(road.graph, from = 55, to = 237, output = 'both')
sp.vertices <- sp$vpath[[1]]
sp.vertices <- as.numeric(sp.vertices)

## Visualize the shortest path
road.network %v% 'col' <- ifelse(all.nodes %in% sp.vertices, '#32B232', '#FF0000')
if(is.pgh) {
  mainStr <- 'Shortest Path (PGH Train)'
  out.filename <- './files/pgh_train_shortest_paths.html'
} else {
  mainStr <- 'Shortest Path (WAS Train)'
  out.filename <- './files/was_train_shortest_paths.html'
}
render.d3movie(road.network, vertex.cex = 0.25, vertex.border = '#FFD700',
               vertex.lwd = 0.05, vertex.col = road.network %v% 'col',
               edge.col = '#808080', edge.lwd = 0.50, edge.border = '#FFFFFF',
               edge.tooltip = paste('<b>Speed:</b>', (road.network %e% 'speed'), '<br>',
                                    '<b>Length:</b>', (road.network %e% 'length'), '<br>',
                                    '<b>Name:</b>', (road.network %e% 'name')),
               main = mainStr, launchBrowser=F, filename=out.filename, output.mode='HTML')

# sp.edges <- sp$epath[[1]]
