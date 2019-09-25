library(magrittr)

warsaw_wgs84_100 <- 
  read.table('data/warsaw_wgs84_every_100m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_name'))

warsaw_wgs84_500 <- 
  read.table('data/warsaw_wgs84_every_500m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_n', 'district_name'))

warsaw_wgs84_1000 <- 
  read.table('data/warsaw_wgs84_every_1000m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_name'))

library(ggplot2)
library(maps)
library(ggmap)
library(ggthemes)

ggplot(warsaw_wgs84_100, aes(x = longitude, y = latitude, col = district_name)) +
  geom_point() +
  coord_map() + 
  theme_minimal() +
  theme(legend.position = 'None') +
  labs(title = 'Warsaw, every 100m') 
ggsave('plots/warsaw_wgs84_every_100m.png')


ggplot(warsaw_wgs84_500, aes(x = longitude, y = latitude, col = district_name)) +
  geom_point() +
  coord_map() + 
  theme_minimal() +
  guides(col = guide_legend(title = 'District')) +
  labs(title = 'Warsaw, every 500m') 
ggsave('plots/warsaw_wgs84_every_500m.png')


ggplot(warsaw_wgs84_1000, aes(x = longitude, y = latitude, col = district_name)) +
  geom_point() +
  coord_map() + 
  theme_minimal() +
  theme(legend.position = 'None') +
  labs(title = 'Warsaw, every 1000m') 
ggsave('plots/warsaw_wgs84_every_1000m.png')
