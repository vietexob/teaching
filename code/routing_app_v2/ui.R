library(shiny)
library(leaflet)

shinyUI(fluidPage(
  titlePanel('Routing App v2'),
  
  sidebarLayout(
    sidebarPanel(
      helpText('Welcome to the Routing App v2!
               Start by uploading your output CSV file in the correct format.
               Refresh your browser to test a different instance.'),
      
      # fileInput("infile", label = h5("Upload input TXT file")),
      
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
