library(igraph)

getEdgeCoords <- function(road.network, edges) {
  from.x <- vector()
  from.y <- vector()
  to.x <- vector()
  to.y <- vector()
  travel.times <- vector()
  
  for(i in 1:length(edges)) {
    ## This is because Python indexes from 0 and R from 1.
    edge.id <- edges[i] + 1
    
    edge.from.x <- E(road.network)[edge.id]$from.x
    edge.from.y <- E(road.network)[edge.id]$from.y
    edge.to.x <- E(road.network)[edge.id]$to.x
    edge.to.y <- E(road.network)[edge.id]$to.y
    
    from.x[i] <- edge.from.x
    from.y[i] <- edge.from.y
    to.x[i] <- edge.to.x
    to.y[i] <- edge.to.y
    
    ## Add travel time
    travel.times[i] <- E(road.network)[edge.id]$travel_time
  }
  
  coord.data <- data.frame(from.x = from.x, from.y = from.y,
                           to.x = to.x, to.y = to.y, travel_time = travel.times)
  return(coord.data)
}

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

getInputCoords <- function(input.data, is.input=TRUE) {
  ## Read the road network
  road.filename <- './data/sin_road_subgraph.graphml'
  road.network <- read.graph(road.filename, format = 'graphml')
  
  if(is.input) {
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
  } else {
    edge.coord <- getEdgeCoords(road.network, input.data$edge)
    
    output.coord <- data.frame(indicator = input.data$indicator,
                               from.x = edge.coord$from.x,
                               from.y = edge.coord$from.y,
                               to.x = edge.coord$to.x, to.y = edge.coord$to.y,
                               travel_time = edge.coord$travel_time)
    return(output.coord)
  }
}
