library(tidyverse)
library(shiny)
library(leaflet)
library(RColorBrewer)
library(magrittr)

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
  # preprocessing -------------------
  source("../R/functions.R")
  
  wgs <- read_csv('../data/preprocessing/warsaw_wgs84_every_500m.txt')
  districts <- read_csv('../data/preprocessing/district_ids_mapping.csv')

  places = read_csv("../data/preprocessing/places.csv")
  places_wgs84 = read_csv("../data/preprocessing/places_wgs84.csv")
  popular_times <- read_csv('../data/preprocessing/popular_times.csv')
  
  district_choices = districts$id
  names(district_choices) = as.character(districts$district_name)
  
  # prepare leaflet -------------
  m <- leaflet(places) %>%
    addTiles()
  
  filteredData <- reactive({
    
    print(input$wanted_types)
    print(input$unwanted_types)
    params = list(types_in = input$wanted_types, types_out = input$unwanted_types)
    places_score = score_3(data = places_wgs84, params = params, wgs = wgs, districts = input$districts, popular_times = popular_times)
    pal = rev(c(
      "#FFB600",
      "#FFD05C",
      "#FFEBB9",
      "#B9B8B7",
      "#858381"))
    
    places_score = places_score %>% 
      mutate(score_cut = cut(score, 
                             breaks = c(0,1,2,3,4,10), include.lowest = F,
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
      addProviderTiles(providers$CartoDB.Positron) %>% # DONE
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