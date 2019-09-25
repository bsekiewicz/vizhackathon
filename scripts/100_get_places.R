warsaw_wgs84 <-
  read.table('data/warsaw_wgs84_every_500m.txt') %>%
  set_colnames(c('longitude', 'latitude', 'district_n', 'district_name'))


places <- function(
  api_key = Sys.getenv('GOOGLE_CLOUD_KEY'),
  radius = floor(500*sqrt(2)/2),
  type = 'gym',
  data = warsaw_wgs84
) {
  
  results <- list()
  
  for (row in 1:nrow(data)) {
    cat('Trying row:', row, '\n')
    tryCatch({
      url <- 
        str_c(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=',
          data$latitude[row], ',', data$longitude[row],
          # '52.212026,20.953997',
          '&radius=', radius, 
          '&fields=address&type=', type,
          '&key=', api_key
        )
      
      # Sys.sleep(3)
      places <- fromJSON(url)
      
      
      if (places$status != 'ZERO_RESULTS') {
        
        next_page_token <- places$next_page_token
        places <- places$results %>% select(name, vicinity, geometry, place_id, types, contains('rating'), contains('user_ratings_total'), contains('price_level'))
        places <- cbind(places, places$geometry$location)
        places <- places %>% select(-geometry)
        
        results[[row]] <-
          places
        
        if (!is.null(next_page_token)) {
          Sys.sleep(3)
          next_page_url <- str_c('https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=', next_page_token, '&key=', api_key)
          next_places <- fromJSON(next_page_url)
          next_next_page_token <- next_places$next_page_token
          
          
          next_places <- next_places$results %>% select(name, vicinity, geometry, place_id, types, contains('rating'), contains('user_ratings_total'), contains('price_level'))
          next_places <- cbind(next_places, next_places$geometry$location)
          next_places <- next_places %>% select(-geometry)
          
          results[[row]] <-
            bind_rows(
              results[[row]],
              next_places
            )
          
          if (!is.null(next_next_page_token)) {
            Sys.sleep(3)
            another_next_page_url <- str_c('https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=', next_next_page_token, '&key=', api_key)
            another_next_places <- fromJSON(another_next_page_url)
            
            another_next_places <- another_next_places$results %>% select(name, vicinity, geometry, place_id, types, contains('rating'), contains('user_ratings_total'), contains('price_level'))
            another_next_places <- cbind(another_next_places, another_next_places$geometry$location)
            another_next_places <- another_next_places %>% select(-geometry)
            
            results[[row]] <-
              bind_rows(
                results[[row]],
                another_next_places
              )
          }
        }
        results[[row]] <- 
          results[[row]] %>%
          mutate(point = str_c(data$latitude[row], ',', data$longitude[row]))
      } else {
        results[[row]] <- data.frame(point = str_c(data$latitude[row], ',', data$longitude[row]))
      }
    },
    error = function(cond){cat('Problem with row:', row, '\n')})
  }
  results
}
