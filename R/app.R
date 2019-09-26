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
  x = readRDS("../data/geojson.Rds")
  places = readRDS("../data/places.Rds")
  
  # prepare leaflet -------------
  m <- leaflet(x) %>%
    addTiles()
  
  # TODO
  # m %>% 
  #   addCircleMarkers(data = sel_places, radius = ~rating, 
  #                    color = ~"blue", weight = 0.5,
  #                    fill = TRUE)
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    
    nsamplegroup = 30
    sel_places = places[1:n, ] %>% 
      # filter(type==sel_type) %>% 
      filter(type %in% input$wanted_types) %>% 
      group_by(type) %>% 
      arrange(desc(rating)) %>% 
      mutate(rank=row_number()) %>% 
      filter(rank<=nsamplegroup)
    
    sel_places
  })

  
  output$map <- renderLeaflet({
    leaflet(places) %>% 
      addTiles() %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
  observe({
    leafletProxy("map") %>% 
      clearShapes() %>%
      clearMarkers() %>%
      addCircleMarkers(data = filteredData(), 
                       radius = 0.1,
                       color = "blue",
                       fillOpacity = 0.7,
                       fill = TRUE)
  })
  
}

shinyApp(ui, server)