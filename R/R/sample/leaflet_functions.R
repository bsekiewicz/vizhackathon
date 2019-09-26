addCustomPolygons <- function(x) {
  x %>% 
    addPolygons(
      fillColor = ~pal(2:10),
      weight = 0.7,
      opacity = 1,
      color = "black",
      dashArray = "3",
      fillOpacity = 0.2,
      highlight = highlightOptions(
        weight = 5,
        color = "#625",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE))
}
