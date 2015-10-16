library(shiny)
library(leaflet)

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
  tags$head(includeCSS("styles.css")),
  
  leafletOutput("map", width = "100%", height = "100%"),
  
  absolutePanel(top = 10, right = 10,
                # helpText("Routing application."),
                
                radioButtons("city", label = h5("Choose a city:"),
                             choices = list("Singapore" = 1, "Pittsburgh, PA" = 2,
                                            "Washington, DC" = 3),
                             selected = 1),
                
                fileInput("file", label = h5("Upload an output CSV file")),
                
                h5('Output summary:'),
                verbatimTextOutput('summary')
  )
))
