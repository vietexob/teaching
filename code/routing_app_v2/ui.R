library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel('Routing App v2'),
  
  sidebarLayout(
    sidebarPanel(
      helpText('Welcome to the Routing App v2!
               Start by uploading the input CSV file, followed by uploading the corresponding
               output CSV file in the correct format. Refresh
               the browser to test a different instance.'),
      
      fileInput("infile", label = h5("Upload input CSV file")),
      
      fileInput('outfile', label = h5('Upload output CSV file')),
      
      h5('Output summary:'),
      verbatimTextOutput('summary')
    ),
    
    mainPanel(
      leafletOutput("map")
    ),
    
    position = 'right'
  )
))
