
# read geojson ---------------
# from tutorial https://rstudio.github.io/leaflet/choropleths.html
library(dplyr)
library(leaflet)
library(geojsonio)

x = geojsonio::geojson_read("data/raw/warsaw_distincts.geojson", what = "sp")
class(x)

# TODO remove warsaw layer which can overlap all districts
m <- leaflet(x) %>%
  addTiles()

m %>% addPolygons()

# provider tiles ---------------
# m %>% addPolygons() %>% 
  # addProviderTiles(providers$Stamen.Toner)
  # addProviderTiles(providers$CartoDB.Positron)
  # addProviderTiles(providers$Esri.NatGeoWorldMap)

pal <- colorBin("Spectral", domain = NULL)

m %>% addPolygons(
  fillColor = ~pal(2:10),
  weight = 2,
  opacity = 0.1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7)

# highlight --------
m %>% addPolygons(
  fillColor = ~pal(2:10),
  weight = 0.7,
  opacity = 1,
  color = "black",
  dashArray = "3",
  fillOpacity = 0.2,
  highlight = highlightOptions(
    weight = 5,
    color = "#625",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE))
