library(shiny)
library(leaflet)

load("data/sin_coords.RData")
load("data/pgh_coords.RData")
load("data/was_coords.RData")

source("./convertSPLines.R")
source('./get_output_summary.R')

shinyServer(function(input, output, session) {
  ## These reactive expressions (functions) get rerun only when the
  ## original widgets change
  inputData <- reactive({
    input.file <- input$file
    # print(input.file)
    input.data <- NULL
    
    if(!is.null(input.file)) {
      data.type <- input.file[, 3]
      # print(data.type)
      is.csv <- grepl(pattern = 'csv', x = data.type) | grepl(pattern = 'excel', x = data.type)
      if(is.csv) {
        data.path <- input.file[, 4]
        # print(data.path)
        input.data <- read.csv(file = data.path, header = FALSE, stringsAsFactors = FALSE)
        # print(head(input.data))
        if(ncol(input.data) == 8) {
          names(input.data) <- c('indicator', 'from.x', 'from.y', 'to.x', 'to.y',
                                 'st.name', 'seg.len', 'speed')
        } else {
          input.data <- NULL
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
    input.data <- inputData()
    # print(head(input.data))
    
    ## This is to check if user has changed the city, set input to NULL
    ## if the current city has been changed to reset the map and control
    if(!is.null(input.data)) {
      mean.lon <- mean(0.5 * (input.data$from.x + input.data$to.x))
      mean.lat <- mean(0.5 * (input.data$from.y + input.data$to.y))
      # print(paste(mean.lon, mean.lat))
      lon.diff <- lat.diff <- 0
      
      input.city <- input$city
      if(input.city == 1) {
        lon.diff <- abs(mean.lon - sin.lon)
        lat.diff <- abs(mean.lat - sin.lat)
      } else if(input.city == 2) {
        lon.diff <- abs(mean.lon - allegheny_lon)
        lat.diff <- abs(mean.lat - allegheny_lat)
      } else {
        lon.diff <- abs(mean.lon - dc_lon)
        lat.diff <- abs(mean.lat - dc_lat)
      }
      
      # print(paste(lon.diff, lat.diff))
      if(lon.diff > 0.05 | lat.diff > 0.05) {
        input.data <- NULL
      }
    }
    
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
    
    if(!is.null(input.data)) {
      ## Summarize the travel times and wait times 
      output$summary <- renderPrint({
        is.metric <- input$city == 1
        output.data <- getOutputSummary(input.data, is.metric)
        summary(output.data)
      })
      
      ## Define marker dataset for the taxis' initial locations
      taxi.data <- subset(input.data, indicator == 'Taxi')
      taxi.data <- taxi.data[, 2:3]
      names(taxi.data) <- c('lon', 'lat')
      ## Define the taxi popup icon
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
      titleStr <- ""
      if(input$city == 1) {
        titleStr <- "Speed (km/h)"
      } else {
        titleStr <- "Speed (mph)"
      }
      
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
        addLegend("bottomright", pal=pal, values=~speed, title=titleStr,
                  opacity = 0.80)
    } else {
      output$summary <- renderPrint({
        print('Nothing to display.')
      })
    }
  })
})
