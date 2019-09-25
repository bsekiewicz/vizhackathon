popular_times <-
  function(places, google_search_term = Sys.getenv('GOOGLE_SEARCH_TERM')) {
    times_list <- list()
    problematic_places <- c()
    
    cat('There are ', nrow(places), ' place that I will call.\n')
    for (j in 1:nrow(places)) {
      
      tryCatch({
        cat('Calling place ', j, '\n')
        place_identifier <- str_c(places$name[j], ' ', places$vicinity[j])
        encoded_name <- URLencode(place_identifier)# gsub(' ', '+', fixed = TRUE, place_identifier))
        search_url <- 
          str_c(
            'https://www.google.de/search?tbm=map&tch=1&hl=en&q=',
            encoded_name,
            google_search_term
          )
        
        
        times       <- content(GET(search_url))$d
        times_clean <- fromJSON(substr(times, 5, nchar(times)))
        if (length(times_clean[[1]][[2]][[1]]) >= 15) {
          info        <- times_clean[[1]][[2]][[1]][[15]]
          
          if (length(info[[5]]) >= 9) {
            total_ratings <- info[[5]][[9]]
            rating_av     <- info[[5]][[8]]
            av_time_spent <- info[[118]][[1]]
            
            popular_times <- info[[85]][[1]]
            
            
            sunday    <- popular_times[[1]][[2]] %>% occupancy
            monday    <- popular_times[[2]][[2]] %>% occupancy
            tuesday   <- popular_times[[3]][[2]] %>% occupancy
            wednesday <- popular_times[[4]][[2]] %>% occupancy
            thursday  <- popular_times[[5]][[2]] %>% occupancy
            friday    <- popular_times[[6]][[2]] %>% occupancy
            saturday  <- popular_times[[7]][[2]] %>% occupancy
            
            times_list[[places$place_id[j]]] <-
              bind_rows(
                sunday    %>% mutate(day = 'Sunday'),
                monday    %>% mutate(day = 'Monday'),
                tuesday   %>% mutate(day = 'Tuesday'),
                wednesday %>% mutate(day = 'Wednesday'),
                thursday  %>% mutate(day = 'Thursday'),
                friday    %>% mutate(day = 'Friday'),
                saturday  %>% mutate(day = 'Saturday')
              ) %>%
              mutate(av_time_spent = av_time_spent,
                     place_id      = places$place_id[j],
                     name          = places$name[j],
                     vicinity      = places$vicinity[j])
          } else {
            times_list[[places$place_id[j]]] <- data.frame(error = TRUE, place_id = places$place_id[j])
          }
        } else {
          times_list[[places$place_id[j]]] <- data.frame(error = TRUE, place_id = places$place_id[j])
        }
      },
      error = function(cond){
        cat('Problem with place ', j, '\n')
        problematic_places <- c(problematic_places, j)
      }) 
    }
    cat(problematic_places)
    return(times_list)
  }

occupancy <- function(df){
  if (is.null(df) || is.na(df)) {
    data.frame(
      hour = 6:23,
      occupancy_index = 0,
      occupancy_text  = ''
    )  
  } else {
    df[, 1:3] %>% 
      as.data.frame %>%
      set_names(c('hour', 'occupancy_index', 'occupancy_text')) %>%
      mutate(hour           = as.numeric(as.character(hour)),
             occupancy_index = as.numeric(as.character(occupancy_index))
      )
  }
}