score <- function(data, params=list(), districts=NULL, wgs = wgs) {
  
  # data <- read_csv('data/preprocessing/places_with_wgs84.csv')
  
  # params = list(types_in = c('bakery'),
  #               types_out = c('police'))
  
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




# score ver 1.0

# (sum in + sum out) / the greatest score * 10

score_1 <- function(data, wgs, params=list(), districts=NULL) {
  # data <- read_csv('data/preprocessing/places_wgs84.csv')
  # wgs <- read_csv('data/preprocessing/warsaw_wgs84_every_500m.txt')
  # 
  # params = list(types_in = c('bakery'),
  #               types_out = c('police'))
  # 
  data %<>% select(place_id, rating, user_ratings_total, lat, lng, type, wgs=wgs84_500_id)
  
  if (!is.null(districts)) {
    wgs %<>% filter(district_id %in% districts)  
  }
  
  types_in <- params[['types_in']]
  types_out <- params[['types_out']]
  
  # score
  output <- data %>% group_by(wgs) %>%
    summarise(score = sum(type %in% types_in) + sum(!(type %in% types_out))) %>%
    arrange(desc(score))
  output$score <- output$score/max(output$score)*10
  
  output %<>% 
    select(id=wgs, score) %>% 
    left_join(wgs) %>% 
    select(lat, lng, score) %>% 
    mutate(in_out = TRUE)
  
  return(output)
}

# score ver 2.0

# 

score_2 <- function(data, wgs, params=list(), districts=NULL) {
  # data <- read_csv('data/preprocessing/places_wgs84.csv')
  # wgs <- read_csv('data/preprocessing/warsaw_wgs84_every_500m.txt')
  # 
  # params = list(types_in = c('bakery'),
  #               types_out = c('police'))
  
  data %<>% select(place_id, rating, user_ratings_total, lat, lng, type, wgs=wgs84_500_id)
  
  if (!is.null(districts)) {
    wgs %<>% filter(district_id %in% districts)  
  }
  
  types_in <- params[['types_in']]
  types_out <- params[['types_out']]
  
  # score
  output <- data %>%
    group_by(wgs) %>%
    summarise(score = 0)
  for (t in types_in) {
    tmp <- data %>% filter(type==t) %>%
      group_by(wgs) %>% 
      summarise(mean_rating = mean(rating, rm.na=TRUE)) %>%
      arrange(desc(mean_rating))
    tmp$mean_rating[is.na(tmp$mean_rating)] <- 0 #mean(tmp$mean_rating, rm.na=TRUE)
    tmp <- left_join(output, tmp)
    tmp$mean_rating[is.na(tmp$mean_rating)] <- 0
    tmp$score <- tmp$score + tmp$mean_rating
    output <- tmp %>% select(wgs, score)
  }
  for (t in types_out) {
    tmp <- data %>% filter(type==t) %>%
      group_by(wgs) %>% 
      summarise(mean_rating = 5-mean(rating, rm.na=TRUE)) %>%
      arrange(desc(mean_rating))
    tmp$mean_rating[is.na(tmp$mean_rating)] <- 5 #mean(tmp$mean_rating, rm.na=TRUE)
    tmp <- left_join(output, tmp)
    tmp$mean_rating[is.na(tmp$mean_rating)] <- 5
    tmp$score <- tmp$score + tmp$mean_rating
    output <- tmp %>% select(wgs, score)
  }
  
  output %<>% arrange(desc(score))
  
  output %<>% 
    select(id=wgs, score) %>% 
    left_join(wgs) %>% 
    select(lat, lng, score) %>% 
    mutate(in_out = TRUE)
  
  return(output)
}