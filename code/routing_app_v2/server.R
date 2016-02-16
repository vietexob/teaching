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
        
        validate(
          need(length(input.txt) > 2, 'Error: Invalid input data!')
        )
        
        num.ods <- as.numeric(input.txt[1])
        # print(num.ods)
        num.taxis <- as.numeric(input.txt[2])
        # print(num.taxis)
        
        validate(
          need(!is.na(num.ods) && !is.na(num.taxis), 'Error: Invalid input data!')
        )
        validate(
          need(num.taxis <= num.ods, 'Error: Invalid input data!')
        )
        
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
        
        validate(
          need(length(taxi.locs) == num.taxis, 'Error: Number of taxis mismatched!')
        )
        
        if(num.taxis < num.ods) {
          delta <- num.ods - num.taxis
          for(i in 1:delta) {
            taxi.locs <- c(taxi.locs, NA)
          }
        }
        
        input.data <- data.frame(origin = origin, destination = destination,
                                 taxi = taxi.locs)
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
        
        if(ncol(output.data) == 4) {
          names(output.data) <- c('indicator', 'edge', 'seg.len', 'speed')
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
    output.data <- outputData()
    
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
      # print(input.coord)
      
      ## Visualize the OD pairs and taxi locations
      ## Define marker dataset for the taxis' initial locations
      taxi.data <- input.coord[, 5:6]
      names(taxi.data) <- c('lon', 'lat')
      ## Remove the NA's, if any
      taxi.data <- subset(taxi.data, !is.na(lon))
      
      ## Define the taxi popup icon
      taxi.popup <- paste(rep('Taxi', nrow(taxi.data)),
                          1:nrow(taxi.data))
      
      ## Define the marker dataset for the start and end points of each path
      source.data <- input.coord[, 1:2]
      names(source.data) <- c('lon', 'lat')
      ## Define the source popup icon
      source.popup <- paste(rep("Origin", nrow(source.data)),
                            1:nrow(source.data))
      
      target.data <- input.coord[, 3:4]
      names(target.data) <- c('lon', 'lat')
      ## Define the destination popup icon
      target.popup <- paste(rep("Destination", nrow(target.data)),
                            1:nrow(target.data))
      
      ## Create line data frame for the OD pairs
      od.data <- input.coord[, 1:4]
      names(od.data) <- c('from.x', 'from.y', 'to.x', 'to.y')
      od.lines <- convertSPLines(input.data=od.data, has.attributes=FALSE)
      
      ## Draw the taxi locations and OD pairs/lines
      leafletProxy("map", data = od.lines) %>%
        clearShapes() %>% clearMarkers() %>% clearControls() %>%
        addMarkers(data = taxi.data, ~lon, ~lat,
                   icon = taxiIcon, popup = taxi.popup) %>%
        addMarkers(data = source.data, ~lon, ~lat, popup = source.popup) %>%
        addMarkers(data = target.data, ~lon, ~lat,
                   icon = destIcon, popup = target.popup) %>%
        addPolylines(opacity = 0.40, weight = 3)
    }
    
    if(!is.null(output.data)) {
#       output$summary <- renderPrint({
#         print('Retrieving coordinates...')
#       })
      
      output.coord <- getInputCoords(output.data, is.input=FALSE)
      
      ## Summarize the travel times and wait times 
#       output$summary <- renderPrint({
#         is.metric <- TRUE
#         output.data <- getOutputSummary(output.data, is.metric)
#         summary(output.data)
#       })
      
      ## Define marker dataset for the taxis' initial locations
      taxi.data <- subset(output.coord, indicator == 'Taxi')
      taxi.data <- taxi.data[, 2:3]
      names(taxi.data) <- c('lon', 'lat')
      ## Define the taxi popup icon
      taxi.popup <- paste(rep('Taxi', nrow(taxi.data)),
                          1:nrow(taxi.data))
      
      ## Define the marker dataset for the start and end points of each path
      source.data <- subset(output.coord, indicator == 'Start')
      source.data <- source.data[, 2:3]
      names(source.data) <- c('lon', 'lat')
      ## Define the source popup icon
      source.popup <- paste(rep("Origin", nrow(source.data)),
                            1:nrow(source.data))
      
      ## Create a taxi-source matching data
      matching.data <- cbind(taxi.data, source.data)
      names(matching.data) <- c('from.x', 'from.y', 'to.x', 'to.y')
      matching.lines <- convertSPLines(input.data=matching.data, has.attributes=FALSE)
      
      target.data <- subset(output.coord, indicator == 'End')
      target.data <- target.data[, 4:5]
      names(target.data) <- c('lon', 'lat')
      ## Define the destination popup icon
      target.popup <- paste(rep("Destination", nrow(target.data)),
                            1:nrow(target.data))
      
      speed <- output.coord$speed
      titleStr <- "Speed (km/h)"
      new.output <- convertSPLines(output.coord, has.attributes = TRUE)
      
      leafletProxy("map", data = new.output) %>%
        clearShapes() %>% clearMarkers() %>% clearControls() %>%
        addMarkers(data = taxi.data, ~lon, ~lat,
                   icon = taxiIcon, popup = taxi.popup) %>%
        addMarkers(data = source.data, ~lon, ~lat, popup = source.popup) %>%
        addMarkers(data = target.data, ~lon, ~lat,
                   icon = destIcon, popup = target.popup) %>%
        addPolylines(color = ~pal(speed), opacity = 0.30) %>%
        addPolylines(data = matching.lines, opacity = 0.40, weight = 3) %>%
        addLegend("bottomright", pal=pal, values=~speed, title=titleStr,
                  opacity = 0.80)
    } else {
      output$summary <- renderPrint({
        print('Upload output to display.')
      })
    }
  })
})
