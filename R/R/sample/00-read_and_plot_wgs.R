library(tidyverse)
library(leaflet)

# read fishnet ---------
read_wgs <- function(file) {
  read.table(file = file, 
             sep = "" , header = F , 
             na.strings ="", stringsAsFactors= F,
             encoding = 'UTF-8') %>% as_tibble()
}

ww_wgs_1000m = read_wgs(file = "data/raw/warsaw_wgs84_every_1000m.txt") %>% 
  dplyr::rename(lng=V1, lat=V2, district=V3)
ww_wgs_2000m = read_wgs(file = "data/raw/warsaw_wgs84_every_2000m.txt") %>% 
  dplyr::rename(lng=V1, lat=V2, district=V3)
ww_wgs_500m = read_wgs(file = "data/raw/warsaw_wgs84_every_500m.txt") %>% 
  dplyr::rename(lng=V1, lat=V2, district_id=V4, district=V4)
ww_wgs_100m = read_wgs(file = "data/raw/warsaw_wgs84_every_100m.txt") %>% 
  dplyr::rename(lng=V1, lat=V2, district=V3)

ww_wgs_100m %>% count(district) %>% arrange(desc(n))

# plot fishnet ---------
ww_wgs_500m %>% 
  ggplot(aes(x=lng, y=lat)) +
  geom_point(aes(color=district), size=0.01) +
  theme_minimal()

ww_wgs_100m[sample(1:nrow(ww_wgs_100m), size = 2000, replace = F), ] %>% 
  ggplot(aes(x=lng, y=lat)) +
  geom_point(aes(color=district), size=0.01) +
  theme_minimal()
