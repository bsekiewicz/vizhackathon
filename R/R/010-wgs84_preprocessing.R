warsaw_wgs84_100 <- 
  read.csv('data/raw/warsaw_wgs84_every_100m.txt', sep='\t', encoding = 'UTF-8') %>%
  set_colnames(c('longitude', 'latitude', 'district_name')) %>%
  mutate(district_name = toupper(district_name),
         district_name = district_name %>% stri_replace_all_fixed('┼ÜR├ÔDMIE┼ÜCIE', 'ŚRÓDMIEŚCIE'))

warsaw_wgs84_100$district_name %>% unique

warsaw_wgs84_500 <- 
  read.table('data/raw/warsaw_wgs84_every_500m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_n', 'district_name'))

warsaw_wgs84_1000 <- 
  read.table('data/raw/warsaw_wgs84_every_1000m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_name'))

warsaw_wgs84_2000 <- 
  read.table('data/raw/warsaw_wgs84_every_2000m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_name'))
