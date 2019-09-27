# score ver 3.0

score_3 <- function(data, wgs, params=list(), districts=NULL, popular_times = popular_times) {

  popular_times %<>% group_by(place_id) %>% summarise(oi = mean(occupancy_index))
  
  data %<>% select(place_id, rating, user_ratings_total, lat, lng, type, wgs=wgs84_500_id)

  # pop times
  data %<>% left_join(popular_times)
  data %<>% filter(!is.na(oi)) %>% filter(oi > 0)
  
  # districts
  if (!is.null(districts)) {
    wgs %<>% filter(district_id %in% districts)  
  }
  
  types_in <- params[['types_in']]
  types_out <- params[['types_out']]
  
  # score
  output <- data %>%
    group_by(wgs) %>%
    summarise(score = 5)
  for (t in types_in) {
    tmp <- data %>% filter(type==t) %>%
      group_by(wgs) %>% 
      summarise(mean_rating = mean(rating, na.rm =TRUE)) %>%
      arrange(desc(mean_rating))
    tmp$mean_rating[is.na(tmp$mean_rating)] <- mean(tmp$mean_rating, na.rm=TRUE)
    tmp <- left_join(output, tmp)
    tmp$mean_rating[is.na(tmp$mean_rating)] <- 0
    tmp$score <- tmp$score + tmp$mean_rating
    output <- tmp %>% select(wgs, score)
  }
  for (t in types_out) {
    tmp <- data %>% filter(type==t) %>%
      group_by(wgs)
    if (nrow(tmp) > 0){
      tmp %<>% summarise(mean_rating = -1) %>%
        arrange(desc(mean_rating))
      tmp <- left_join(output, tmp)
      tmp$mean_rating[is.na(tmp$mean_rating)] <- 0
      tmp$score <- tmp$score + tmp$mean_rating
      output <- tmp %>% select(wgs, score)
    }
  }
  
  output$score[output$score<0] <- 0
  output$score <- output$score/max(output$score)*10
  
  output %<>% arrange(desc(score))
  # hist(output$score)
  
  output %<>% 
    select(id=wgs, score) %>% 
    left_join(wgs) %>% 
    select(lat, lng, score) %>% 
    mutate(in_out = TRUE)
  
  return(output)
}

