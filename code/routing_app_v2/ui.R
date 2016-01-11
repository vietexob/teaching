library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel('Routing App v2'),
  
  sidebarLayout(
    sidebarPanel(
      helpText('This app visualizes the map of Singapore, the input OD pairs
               and available taxis, and the output matchings between taxis and passengers.
               Start by uploading the input CSV file, followed by uploading the corresponding
               output CSV file in the correct format as described in <insert_url>. Refresh
               the browser to test a different instance.'),
      
      fileInput("infile", label = h5("Upload an input CSV file")),
      
      fileInput('outfile', label = h5('Upload the corresponding output CSV file')),
      
      h5('Output summary:'),
      verbatimTextOutput('summary')
    ),
    
    mainPanel(
      leafletOutput("map")
    ),
    
    position = 'right'
  )
))
