library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                h4("Select your preferences:"),
                
               selectInput("wanted_types", label = "Wanted",
                           choices = unique(places$type),
                           selected = "bar",
                           multiple=TRUE, selectize=TRUE),
               
               selectInput("unwanted_types", label = "Unwanted",
                           choices = unique(places$type),
                           selected = "police",
                           multiple=TRUE, selectize=TRUE)
               
  )
)

server <- function(input, output, session) {
  # preprocessing -------------------
  source("../R/functions.R")
  x = readRDS("../data/geojson.Rds")
  places = readRDS("../data/places.Rds")
  places_wgs84 = readRDS("../data/places_wgs84.Rds")
  
  # prepare leaflet -------------
  m <- leaflet(x) %>%
    addTiles()
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    
    print(input$wanted_types)
    print(input$unwanted_types)
    params = list(types_in = input$wanted_types, types_out = input$unwanted_types)
    # params = list(types_in = input$wanted_types, types_out = "police")
    places_score = score(data = places_wgs84, params = params)
    pal = c(
      "#FFB600",
      "#FFD05C",
      "#FFEBB9",
      "#B9B8B7",
      "#858381")
    
    places_score = places_score %>% 
      mutate(score_cut = cut(score, 
                             breaks = c(0,1,2,3,4,10), include.lowest = F,
                             labels = pal) %>% as.character())
    
    places_score
      
  })

  
  output$map <- renderLeaflet({
    leaflet(places) %>% 
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% # DONE
      fitBounds(lng1 = ~min(lng), lat1 = ~min(lat), lng2 = ~max(lng), lat2 = ~max(lat))
  })
  
  # observeEvent(input$map_click, {
  #   click <- input$map_click
  #   print(click)
  #   text<-paste("Lattitude ", click$lat, "Longtitude ", click$lng)
  #   
  #   proxy <- leafletProxy("map")
  #   proxy %>% clearPopups() %>%
  #     addPopups(click$lng, click$lat, text)
  # })
  
  observe({
    # leafletProxy("map") %>% 
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addCircleMarkers(data = filteredData(), 
    #                    radius = 0.1,
    #                    color = "blue",
    #                    fillOpacity = 0.7,
    #                    fill = TRUE)
    leafletProxy("map") %>%
      clearShapes() %>%
      clearMarkers() %>%
      addTiles() %>%
      addCircles(data = places_score[], 
                 lng = ~lng, lat = ~lat,
                 # radius = ~rating, 
                 radius = ~250, 
                 fillOpacity = 0.6,
                 color = ~score_cut,
                 weight = 0.5,
                 fill = TRUE)
    
  })
  
}

shinyApp(ui, server)