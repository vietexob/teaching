library(shiny)
library(leaflet)

load("data/pgh_coords.RData")
load("data/was_coords.RData")

shinyServer(function(input, output, session) {
  filteredData <- reactive({
    selectionStr <- input$selection
    filename <- ''
    if(input$city == 1) { # PGH
      if(selectionStr == '1') {
        filename <- ''
      } else {
        filename <- './data/pgh_test_segment_speed_august.rds'
      }
    } else { # WAS
      if(selectionStr == '1') {
        filename <- ''
      } else {
        filename <- ''
      }
    }
    
    if(nchar(filename) > 0) {
      input.data <- readRDS(file = filename)
    } else {
      input.data <- NULL
    }
  })
  
  output$map <- renderLeaflet(
    if(input$city == 1) {
      leaflet(data = filteredData()) %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        setView(lng = allegheny_lon, lat = allegheny_lat, zoom = 15)
    } else {
      leaflet(data = filteredData()) %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        setView(lng = dc_lon, lat = dc_lat, zoom = 15)
    }
  )
  
  observe({
    pal <- colorNumeric("RdYlGn", domain = NULL, na.color = "#808080")
    input.data <- filteredData()
    street.names <- input.data$street.name
    segment.len <- input.data$length
    mean.speed <- input.data$mean.speed
    
    ## Define parameters of HTML pop-up
    streetInfo.popup <- paste0("<strong>Street name: </strong>", street.names,
                               "<br><strong>Segment length: </strong>", segment.len,
                               "<br><strong>Mean speed: </strong>", mean.speed)
    
    leafletProxy("map", data = input.data) %>%
      clearShapes() %>% clearMarkers() %>% clearControls() %>%
      addPolylines(color = ~pal(mean.speed),
                   opacity = 0.75,
                   popup = streetInfo.popup) %>%
      addLegend("bottomright", pal=pal, values=~mean.speed, title="Speed (mph)",
                opacity = 0.80)
  })
})
