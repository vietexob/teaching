library(igraph)

getNodeCoords <- function(road.network, node.vector) {
  ## Retrieves the lon/lat coords of the input node vector
  
  lon.vector <- vector()
  lat.vector <- vector()
  
  for(a.node in node.vector) {
    if(!is.na(a.node)) {
      an.edge <- E(road.network)[from(a.node)]
      an.edge <- an.edge[1]
      longitude <- E(road.network)[an.edge]$from.x
      latitude <- E(road.network)[an.edge]$from.y
      
      lon.vector <- c(lon.vector, longitude)
      lat.vector <- c(lat.vector, latitude)
    } else {
      lon.vector <- c(lon.vector, NA)
      lat.vector <- c(lat.vector, NA)
    }
  }
  
  coord.data <- data.frame(lon = lon.vector, lat = lat.vector)
  return(coord.data)
}

getInputCoords <- function(input.data) {
  ## Read the road network
  road.filename <- './data/sin_road_network.graphml'
  road.network <- read.graph(road.filename, format = 'graphml')
  
  ## Find the coordinates of the origin nodes
  origin.coord <- getNodeCoords(road.network, input.data$origin)
  ## Find the coordinates of the destination nodes
  dest.coord <- getNodeCoords(road.network, input.data$destination)
  ## Find the coordinates of the taxi locations
  taxi.coord <- getNodeCoords(road.network, input.data$taxi)
  
  input.coord <- cbind(origin.coord, dest.coord, taxi.coord)
  names(input.coord) <- c('origin.lon', 'origin.lat', 'dest.lon', 'dest.lat',
                          'taxi.lon', 'taxi.lat')
  return(input.coord)
}
