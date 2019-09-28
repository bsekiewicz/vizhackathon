library(tidyverse)
library(shiny)
library(leaflet)
library(magrittr)

# prepare app config -------------------
source("../R/config_and_preprocess.R")
source("../R/functions.R")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                h4("Select your preferences:"),
                
               selectInput("wanted_types", label = "I like:",
                           choices = unique(places$type),
                           selected = "bar",
                           multiple=TRUE, selectize=TRUE),
               
               selectInput("unwanted_types", label = "I dislike:",
                           choices = unique(places$type),
                           selected = "police",
                           multiple=TRUE, selectize=TRUE),
               
               selectInput("districts", label = "District:",
                           choices = district_choices, selected = c(10, 4, 2),
                           # choices = district_choices, selected = NULL,
                           multiple=TRUE, selectize=TRUE)
               
  )
)

server <- function(input, output, session) {
  
  # prepare leaflet -------------
  m <- leaflet(places) %>%
    addTiles()
  
  filteredData <- reactive({
    
    params = list(types_in = input$wanted_types, types_out = input$unwanted_types)
    places_score = score_3(data = places_wgs84, params = params, wgs = wgs, districts = input$districts, popular_times = popular_times)
    places_score %<>% 
      mutate(score_cut = cut(score, 
                             breaks = c(0,1,2,3,4,10), # TODO use densier palette
                             include.lowest = F,
                             labels = pal) %>% as.character())
    
    places_score
      
  })
  
  output$map <- renderLeaflet({
    leaflet(places) %>% 
      addTiles() %>%
      
      fitBounds(lng1 = ~min(lng), lat1 = ~min(lat), lng2 = ~max(lng), lat2 = ~max(lat))
  })
  
  observe({
    leafletProxy("map") %>%
      clearShapes() %>%
      clearMarkers() %>%
      addTiles() %>%
      # TODO why providertiles not working in renderLeaflet layer
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addCircles(data = filteredData(), 
                 lng = ~lng, lat = ~lat,
                 radius = ~200, 
                 fillOpacity = 0.5,
                 color = ~score_cut,
                 weight = 0.5,
                 fill = TRUE, highlightOptions=highlightOptions(weight = 5, color = "black", sendToBack = T))
  })
  
}

shinyApp(ui, server)