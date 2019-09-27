places <- read.csv('data/raw/places.csv', encoding = 'UTF-8')
places %>% head


popular_times <- read.csv('data/raw/popular_times_1.csv', encoding = 'UTF-8')
popular_times %<>% rbind(read.csv('data/raw/popular_times_2.csv', encoding = 'UTF-8'))





