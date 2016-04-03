library(shiny)
library(leaflet)

load("data/sin_coords.RData")

source("./convertSPLines.R")
source('./get_output_summary.R')
source('./get_input_coords.R')

shinyServer(function(input, output, session) {
#   inputData <- reactive({
#     input.file <- input$infile
#     # print(input.file)
#     input.data <- NULL
#     
#     if(!is.null(input.file)) {
#       data.type <- input.file[, 3]
#       # print(data.type)
#       is.txt <- grepl(pattern = 'text', x = data.type)
#       if(is.txt) {
#         data.path <- input.file[, 4]
#         input.txt <- readLines(data.path)
#         
#         validate(
#           need(length(input.txt) > 2, 'Error: Input file too short!')
#         )
#         
#         num.ods <- as.numeric(input.txt[1])
#         num.taxis <- as.numeric(input.txt[2])
#         
#         validate(
#           need(!is.na(num.ods) && !is.na(num.taxis), 'Error: Missing num. taxis/demands!')
#         )
#         validate(
#           need(num.taxis <= num.ods, 'Error: There must be less taxis than demands!')
#         )
#         
#         ## Read the OD pairs
#         origin <- vector()
#         destination <- vector()
#         pickup_time <- vector()
#         for(i in 3:(2+num.ods)) {
#           od.pair <- input.txt[i]
#           od.pairStr <- strsplit(od.pair, ', ')
#           od.pairStr <- od.pairStr[[1]]
#           
#           origin[i-2] <- od.pairStr[1]
#           destination[i-2] <- od.pairStr[2]
#           if(length(od.pairStr) > 2) {
#             pickup_time[i-2] <- od.pairStr[3]
#           }
#         }
#         
#         ## Read the taxi locations
#         taxi.locs <- vector()
#         for(i in (2+num.ods+1):length(input.txt)) {
#           taxi.loc <- input.txt[i]
#           taxi.locs <- c(taxi.locs, taxi.loc)
#         }
#         
#         validate(
#           need(length(taxi.locs) == num.taxis, 'Error: Number of taxis mismatched!')
#         )
#         
#         if(num.taxis < num.ods) {
#           delta <- num.ods - num.taxis
#           for(i in 1:delta) {
#             taxi.locs <- c(taxi.locs, NA)
#           }
#         }
#         
#         if(length(pickup_time) > 0) {
#           input.data <- data.frame(origin = origin, destination = destination,
#                                    time = pickup_time, taxi = taxi.locs)
#         } else {
#           input.data <- data.frame(origin = origin, destination = destination,
#                                    taxi = taxi.locs)
#         }
#       }
#     }
#     
#     return(input.data)
#   })
  
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
        
        if(ncol(output.data) == 2) {
          names(output.data) <- c('indicator', 'edge')
        } else if(ncol(output.data) == 4) {
          names(output.data) <- c('taxi', 'indicator', 'time', 'edge')
        } else {
          output.data <- NULL
        }
      }
    }
    
    return(output.data)
  })
  
  output$map <- renderLeaflet(
    leaflet(data = outputData()) %>% 
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = sin.lon, lat = sin.lat, zoom = 12)
  )
  
  observe({
    pal <- colorNumeric("Spectral", domain = NULL, na.color = "#808080")
    # input.data <- inputData()
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
    
#     if(!is.null(input.data)) {
#       ## Translate each node id into lon/lat coordinates and visualize them
#       input.coord <- getInputCoords(input.data)
#       
#       ## Visualize the OD pairs and taxi locations
#       ## Define marker dataset for the taxis' initial locations
#       taxi.data <- input.coord[, 5:6]
#       names(taxi.data) <- c('lon', 'lat')
#       ## Remove the NA's, if any
#       taxi.data <- subset(taxi.data, !is.na(lon))
#       
#       ## Define the taxi popup icon
#       taxi.popup <- paste(rep('Taxi', nrow(taxi.data)),
#                           1:nrow(taxi.data))
#       
#       ## Define the marker dataset for the start and end points of each path
#       source.data <- input.coord[, 1:2]
#       names(source.data) <- c('lon', 'lat')
#       ## Define the source popup icon
#       if(ncol(input.data) == 3) {
#         source.popup <- paste(rep("Origin", nrow(source.data)),
#                               1:nrow(source.data))
#       } else {
#         source.popup <- paste(rep('Origin', nrow(source.data)),
#                               1:nrow(source.data), '@', input.data$time)
#       }
#       
#       target.data <- input.coord[, 3:4]
#       names(target.data) <- c('lon', 'lat')
#       ## Define the destination popup icon
#       target.popup <- paste(rep("Destination", nrow(target.data)),
#                             1:nrow(target.data))
#       
#       ## Create line data frame for the OD pairs
#       od.data <- input.coord[, 1:4]
#       names(od.data) <- c('from.x', 'from.y', 'to.x', 'to.y')
#       od.lines <- convertSPLines(input.data=od.data, has.attributes=FALSE)
#       
#       ## Draw the taxi locations and OD pairs/lines
#       leafletProxy("map", data = od.lines) %>%
#         clearShapes() %>% clearMarkers() %>% clearControls() %>%
#         addMarkers(data = taxi.data, ~lon, ~lat,
#                    icon = taxiIcon, popup = taxi.popup) %>%
#         addMarkers(data = source.data, ~lon, ~lat, popup = source.popup) %>%
#         addMarkers(data = target.data, ~lon, ~lat,
#                    icon = destIcon, popup = target.popup) %>%
#         addPolylines(opacity = 0.40, weight = 3)
#     }
    
    if(!is.null(output.data)) {
      is.scheduling <- ncol(output.data) == 4
      # print(head(output.data))
      
      withProgress(message = 'Preparing output', value = 0, {
        n <- 3 # number of 'milestones'
        incProgress(1/n, detail = 'Retrieving coordinates')
        
        output.coord <- getInputCoords(output.data, is.input=FALSE)
        
        ## Summarize the travel times and wait times 
        output$summary <- renderPrint({
          if(is.scheduling) {
            new.output.coord <- output.coord
            new.output.coord$taxi <- output.data$taxi
            new.output.coord$time <- output.data$time
            summ.output <- getOutputSummary(new.output.coord, is.metric = TRUE,
                                            is.scheduling = is.scheduling)
            summary(summ.output)
            # print(summ.output)
          } else {
            summ.output <- getOutputSummary(output.coord, is.metric=TRUE)
            total.time <- sum(sum(summ.output$wait.time), sum(summ.output$travel.time))
            total.time <- round(total.time, 2)
            print(paste('Total time =', total.time))
          }
        })
        
        incProgress(2/n, detail = 'Retrieving locations')
        
        ## Define marker dataset for the taxis' initial locations
        taxi.data <- subset(output.coord, indicator == 'Taxi')
        taxi.data <- taxi.data[, 2:3]
        names(taxi.data) <- c('lon', 'lat')
        ## Define the taxi popup icon
        if(is.scheduling) {
          taxi.subset <- subset(output.data, indicator == 'Taxi')
          taxi.nos <- taxi.subset$taxi
          taxi.popup <- paste(rep('Taxi', nrow(taxi.data)), taxi.nos)
        } else {
          taxi.popup <- paste(rep('Taxi', nrow(taxi.data)),
                              1:nrow(taxi.data))
        }
        
        ## Define the marker dataset for the start and end points of each path
        source.data <- subset(output.coord, indicator == 'Start')
        source.data <- source.data[, 2:3]
        names(source.data) <- c('lon', 'lat')
        ## Define the source popup icon
        if(is.scheduling) {
          source.subset <- subset(output.data, indicator == 'Start')
          pickup.time <- source.subset$time
          source.popup <- paste(rep("Origin", nrow(source.data)), 1:nrow(source.data),
                                rep('@', nrow(source.data)), pickup.time)
        } else {
          source.popup <- paste(rep("Origin", nrow(source.data)),
                                1:nrow(source.data))
        }
        
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
        
        incProgress(3/n, detail = 'Converting into spatial lines')
        
        travel_time <- output.coord$travel_time
        titleStr <- "Time (minutes)"
        new.output <- convertSPLines(output.coord, has.attributes = TRUE)
      })
      
      leafletProxy("map", data = new.output) %>%
        clearShapes() %>% clearMarkers() %>% clearControls() %>%
        addMarkers(data = taxi.data, ~lon, ~lat,
                   icon = taxiIcon, popup = taxi.popup) %>%
        addMarkers(data = source.data, ~lon, ~lat, popup = source.popup) %>%
        addMarkers(data = target.data, ~lon, ~lat,
                   icon = destIcon, popup = target.popup) %>%
        addPolylines(color = ~pal(travel_time), opacity = 0.35) %>%
        addPolylines(data = matching.lines, opacity = 0.45, weight = 3) %>%
        addLegend("bottomright", pal=pal, values=~travel_time, title=titleStr,
                  opacity = 0.80)
    } else {
      output$summary <- renderPrint({
        print('Upload output to display.')
      })
    }
  })
})
