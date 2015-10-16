library(shiny)
library(leaflet)

load("data/sin_coords.RData")
load("data/pgh_coords.RData")
load("data/was_coords.RData")

source("./convertSPLines.R")

shinyServer(function(input, output, session) {
  inputData <- reactive({
    input.file <- input$file
    input.data <- NULL
    
    if(!is.null(input.file)) {
      data.type <- input.file[, 3]
      if(data.type == 'text/csv') {
        data.path <- input.file[, 4]
        input.data <- read.csv(file = data.path, header = FALSE, stringsAsFactors = FALSE)
        if(ncol(input.data) == 8) {
          names(input.data) <- c('indicator', 'from.x', 'from.y', 'to.x', 'to.y',
                                 'st.name', 'seg.len', 'speed')
        }
      }
    }
    
    return(input.data)
  })
  
  output$map <- renderLeaflet(
    if(input$city == 1) { # SIN
      leaflet(data = inputData()) %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        setView(lng = sin.lon, lat = sin.lat, zoom = 14)
    } else if(input$city == 2) { # PGH
      leaflet(data = inputData()) %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        setView(lng = allegheny_lon, lat = allegheny_lat, zoom = 14)
    } else { # WAS
      leaflet(data = inputData()) %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        setView(lng = dc_lon, lat = dc_lat, zoom = 14)
    }
  )
  
  observe({
    pal <- colorNumeric("RdYlGn", domain = NULL, na.color = "#808080")
    destIcon <- makeIcon(
      iconUrl = "./data/dest_icon.png",
      iconWidth = 35, iconHeight = 35,
      iconAnchorX = 18, iconAnchorY = 35
    )
    
    taxiIcon <- makeIcon(
      iconUrl = './data/taxi_icon.png',
      iconWidth = 32, iconHeight = 35,
      iconAnchorX = 18, iconAnchorY = 35
    )
    
    input.data <- inputData()
    
    if(!is.null(input.data)) {
      taxi.data <- subset(input.data, indicator == 'Taxi')
      taxi.data <- taxi.data[, 2:3]
      names(taxi.data) <- c('lon', 'lat')
      taxi.popup <- paste(rep('Taxi', nrow(taxi.data)),
                          1:nrow(taxi.data))
      
      ## Define the marker dataset for the start and end points of each path
      source.data <- subset(input.data, indicator == 'Start')
      source.data <- source.data[, 2:3]
      names(source.data) <- c('lon', 'lat')
      
      ## Define the source popup icon
      source.popup <- paste(rep("Origin", nrow(source.data)),
                            1:nrow(source.data))
      
      target.data <- subset(input.data, indicator == 'End')
      target.data <- target.data[, 4:5]
      names(target.data) <- c('lon', 'lat')
      
      ## Define the destination popup icon
      target.popup <- paste(rep("Destination", nrow(target.data)),
                            1:nrow(target.data))
      
      input.data <- convertSPLines(input.data)
      st.name <- input.data$st.name
      seg.len <- input.data$seg.len
      speed <- input.data$speed
      
      ## Define parameters of HTML pop-up
      streetInfo.popup <- paste0("<strong>Street name: </strong>", st.name,
                                 "<br><strong>Segment length: </strong>", seg.len,
                                 "<br><strong>Speed: </strong>", speed)
      
      leafletProxy("map", data = input.data) %>%
        clearShapes() %>% clearMarkers() %>% clearControls() %>%
        addMarkers(data = taxi.data, ~lon, ~lat,
                   icon = taxiIcon, popup = taxi.popup) %>%
        addMarkers(data = source.data, ~lon, ~lat, popup = source.popup) %>%
        addMarkers(data = target.data, ~lon, ~lat,
                   icon = destIcon, popup = target.popup) %>%
        addPolylines(color = ~pal(speed),
                     opacity = 0.30,
                     popup = streetInfo.popup) %>%
        addLegend("bottomright", pal=pal, values=~speed, title="Speed (km/h)",
                  opacity = 0.80)
    }
  })
})
