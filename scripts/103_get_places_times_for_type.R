  TYPE <- 'atm'

source('scripts/000_libraries.R')
source('scripts/100_get_places.R')
source('scripts/101_get_times.R')

places_data <- places(data = warsaw_wgs84, type = TYPE)
saveRDS(places_data, 
        file = paste0('data/results/', TYPE, '_', 'raw.rds'))


table(unlist(lapply(places_data, nrow)))

row_one <- which(unlist(lapply(places_data, nrow)) == 1)
head(places_data[row_one])
head(places_data[-row_one])


places_data_binded <- do.call(bind_rows, places_data)

places_data_binded %>% filter(!is.na(name)) %>% unique %>% dim

saveRDS(places_data_binded, 
        file = paste0('data/results/', TYPE, '_', 'binded.rds'))

places_data_times <-
  popular_times(places_data_binded %>%
                  filter(!is.na(name))) %>%
  do.call(bind_rows, .)

saveRDS(places_data_times, 
        file = paste0('data/results/', TYPE, '_', 'times.rds'))

# library(ggplot2)
# ggplot(places_data_binded %>% filter(!is.na(name)), 
#        aes(x = lng, y = lat, col = as.character(ceiling(rating)))) +
#   geom_point() +
#   coord_map() + 
#   theme_minimal() +
#   #guides(col = guide_legend(title = 'District')) +
#   labs(title = 'Warsaw') 
