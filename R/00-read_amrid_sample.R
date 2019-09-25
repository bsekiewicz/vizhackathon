library(tidyverse)
library(leaflet)

# read data ---------
amrit = read_csv("data/amrit.csv")
amrit_pop_tim = read_csv("data/amrit_popular_times.csv")

# markers on map ---------
leaflet(data = amrit) %>% addTiles() %>%
  addMarkers(~lng, ~lat, popup = ~as.character(name), label = ~as.character(types))
