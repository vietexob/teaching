library(shiny)
library(leaflet)

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
  tags$head(includeCSS("styles.css")),
  
  leafletOutput("map", width = "100%", height = "100%"),
  
  absolutePanel(top = 10, right = 10,
                helpText("Routing application."),
                
                radioButtons("city", label = "Choose a city:",
                             choices = list("Pittsburgh, PA" = 1,"Washington, DC" = 2),
                             selected = 1),
                
                selectInput("selection", label = "Choose an input:",
                            choices = list("Training set" = 1, "Test set" = 2),
                            selected = 1)
  )
))
