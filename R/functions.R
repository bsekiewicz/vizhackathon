score <- function(data, params=list(), distincts=None) {
  
  # data <- read_csv('data/preprocessing/places_with_wgs84.csv')
  
  # params = list(types_in = c('bakery'),
  #               types_out = c('police'))
  
  wgs <- read_csv('data/preprocessing/warsaw_wgs84_every_500m.txt')
  
  types_in <- params[['types_in']]
  types_out <- params[['types_out']]
  
  output <- data %>% group_by(wgs84_500_id) %>%
    summarise(score = sum(type %in% types_in) + sum(!(type %in% types_out))) %>%
    arrange(desc(score))
  
  output$score <- output$score/max(output$score)*10
  
  # output$wgs84_500_id = output$wgs84_500_id-1
  
  output %<>% select(id=wgs84_500_id,score) %>% left_join(wgs) %>% select(lat, lng, score) %>% mutate(in_out = TRUE)
  
  return(output)
}