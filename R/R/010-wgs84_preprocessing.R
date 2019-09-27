# # read.table('data/raw/warsaw_wgs84_every_500m.txt') %>%
# #   set_colnames(c('longitude', 'latitude', 'district_n', 'district_name')) %>%
# #   select(district_n, district_name) %>%
# #   distinct() %>%
# #   arrange(district_n) %>%
# #   write.csv('data/preprocessing/districts.csv', row.names = FALSE)
# 
# districts_id <- read.csv('data/preprocessing/district_ids_mapping.csv', stringsAsFactors = FALSE, encoding = 'UTF-8')
# 
# read.table('data/raw/warsaw_wgs84_every_1000m.txt', stringsAsFactors = FALSE) %>%
#   set_colnames(c('longitude', 'latitude', 'district_name')) %>%
#   mutate(id = seq_along(1:nrow(.))) %>%
#   left_join(districts_id)
# 
# read.table('data/raw/warsaw_wgs84_every_500m.txt') %>%
#   set_colnames(c('longitude', 'latitude', 'district_n', 'district_name')) %>%
#   mutate(id = seq_along(0:(nrow(.)-1))) %>%
#   select(id, lng='longitude', lat='latitude', district_id='district_n') %>%
#   write.csv('data/preprocessing/warsaw_wgs84_every_500m.csv', row.names = FALSE)
