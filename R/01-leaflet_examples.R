source("R/00-read_geojson.R")
source("R/leaflet_functions.R")

# add markers -------
m %>% 
  addMarkers(data = amrit, lng = ~lng, lat = ~lat)

# add provider tiles ---------
m %>% addPolygons() %>% 
  addProviderTiles(providers$Stamen.Toner)


# polygons ------
pal <- colorBin("Spectral", domain = NULL)
m %>% addPolygons(
  fillColor = ~pal(2:10),
  # fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7)

# add nicer polygons -------
m %>% addCustomPolygons()

# circle markers based on rating --------
m %>% addCustomPolygons %>% 
  addMarkers(data = amrit, lng = ~lng, lat = ~lat) %>%
  addCircleMarkers(data = amrit, radius = ~sqrt(user_ratings_total)/2, 
                   color = ~"blue", weight = 0.5,
                   fill = TRUE)


# popup with rating --------------
leaflet(data = amrit) %>% 
  addTiles() %>%
  addMarkers(lng = ~lng, lat = ~lat, label = ~as.character(rating))


# marker with custom color and icon -----------
getColorRating <- function(amrit) {
  sapply(amrit$rating, function(rating) {
    if (rating < 4) {
      "yellow"
    } else {
      "green"
    } 
    })
}

icons <- awesomeIcons(
  icon = 'close', # TODO does not read some icons e.g. "restaurant"
  iconColor = 'black',
  library = 'ion',
  markerColor = getColorRating(amrit)
)

m %>% addCustomPolygons %>% 
  addAwesomeMarkers(data = amrit, lng = ~lng, lat = ~lat, icon=icons, label=~as.character(name))

# add rectangle -----------
m %>%
  addMarkers(data = amrit, lng = ~lng, lat = ~lat) %>% 
  addRectangles(
    lng1=min(amrit$lng), lat1=min(amrit$lat),
    lng2=max(amrit$lng), lat2=max(amrit$lat),
    fillColor = "transparent"
  )
