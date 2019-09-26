library(tidyverse)
library(leaflet)
library(readr)

# read data ---------
amrit = read_csv("data/sample/amrit.csv")
amrit_pop_tim = read_csv("data/sample/amrit_popular_times.csv")

# markers on map ---------
leaflet(data = amrit) %>% addTiles() %>%
  addMarkers(~lng, ~lat, popup = ~as.character(name), label = ~as.character(types))
