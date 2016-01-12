library(shiny)
library(leaflet)

load("data/sin_coords.RData")

source("./convertSPLines.R")
source('./get_output_summary.R')
source('./get_input_coords.R')

shinyServer(function(input, output, session) {
  inputData <- reactive({
    input.file <- input$infile
    # print(input.file)
    input.data <- NULL
    
    if(!is.null(input.file)) {
      data.type <- input.file[, 3]
      # print(data.type)
      is.txt <- grepl(pattern = 'text', x = data.type)
      if(is.txt) {
        data.path <- input.file[, 4]
        input.txt <- readLines(data.path)
        if(length(input.txt) > 2) {
          num.ods <- as.numeric(input.txt[1])
          # print(num.ods)
          num.taxis <- as.numeric(input.txt[2])
          # print(num.taxis)
          if(num.taxis > num.ods) {
            stop('Invalid input text!')
          }
          
          ## Read the OD pairs
          origin <- vector()
          destination <- vector()
          for(i in 3:(2+num.ods)) {
            od.pair <- input.txt[i]
            od.pairStr <- strsplit(od.pair, ', ')
            od.pairStr <- od.pairStr[[1]]
            origin[i-2] <- od.pairStr[1]
            # print(origin[i-2])
            destination[i-2] <- od.pairStr[2]
            # print(destination[i-2])
          }
          
          ## Read the taxi locations
          taxi.locs <- vector()
          for(i in (2+num.ods+1):length(input.txt)) {
            taxi.loc <- input.txt[i]
            taxi.locs <- c(taxi.locs, taxi.loc)
          }
          if(length(taxi.locs) != num.taxis) {
            stop('Number of taxis mismatched!')
          }
          if(num.taxis < num.ods) {
            delta <- num.ods - num.taxis
            for(i in 1:delta) {
              taxi.locs <- c(taxi.locs, NA)
            }
          }
          
          input.data <- data.frame(origin = origin, destination = destination,
                                   taxi = taxi.locs)
        } else {
          stop('Invalid input text!')
        }
      }
    }
    
    return(input.data)
  })
  
  ## These reactive expressions (functions) get rerun only when the
  ## original widgets change
  outputData <- reactive({
    output.file <- input$outfile
    # print(output.file)
    output.data <- NULL
    
    if(!is.null(output.file)) {
      data.type <- output.file[, 3]
      # print(data.type)
      is.csv <- grepl(pattern = 'csv', x = data.type) | grepl(pattern = 'excel', x = data.type)
      if(is.csv) {
        data.path <- output.file[, 4]
        # print(data.path)
        output.data <- read.csv(file = data.path, header = FALSE, stringsAsFactors = FALSE)
        # print(head(output.data))
        if(ncol(output.data) == 8) {
          names(output.data) <- c('indicator', 'from.x', 'from.y', 'to.x', 'to.y',
                                 'st.name', 'seg.len', 'speed')
        } else {
          output.data <- NULL
        }
      }
    }
    
    return(output.data)
  })
  
  output$map <- renderLeaflet(
    leaflet(data = inputData()) %>% 
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = sin.lon, lat = sin.lat, zoom = 12)
  )
  
  observe({
    pal <- colorNumeric("RdYlGn", domain = NULL, na.color = "#808080")
    input.data <- inputData()
    # print(input.data)
    output.data <- outputData()
    # print(output.data)
    
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
      ## Translate each node id into lon/lat coordinates and visualize them
      input.coord <- getInputCoords(input.data)
      print(input.coord)
    }
    
    if(!is.null(output.data)) {
      
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
