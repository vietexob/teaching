library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel('Routing App v2'),
  
  sidebarLayout(
    sidebarPanel(
      helpText('To be completed.'),
      
      fileInput("file", label = h5("Upload an output CSV file")),
      
      h5('Output summary:'),
      verbatimTextOutput('summary')
    ),
    
    mainPanel(
      leafletOutput("map")
    ),
    
    position = 'right'
  )
))
