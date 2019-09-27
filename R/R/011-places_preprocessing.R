places <- readr::read_csv('data/preprocessing/places.csv')
wgs84 <- readr::read_csv("data/preprocessing/warsaw_wgs84_every_500m.txt")

p<-progress_estimated(nrow(places))
places$wgs84_500_id <- NA
for (i in 1:nrow(places)) {
  if (is.na(places[i, 'wgs84_500_id'])) {
  
  tmp <- distance(wgs84$lat, wgs84$lng, rep(places$lat[i],nrow(wgs84)), rep(places$lng[i],nrow(wgs84))) %>%
    mutate(is_min = distance == min(distance))
  
  places[i,'wgs84_500_id'] <- wgs84$id[tmp$is_min][1]
  }
  p$tick()$print()
}

write.csv(places, 'data/preprocessing/places_wgs84.csv', row.names = FALSE)
