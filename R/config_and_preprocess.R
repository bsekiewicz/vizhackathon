pal = rev(c(
  "#FFB600",
  "#FFD05C",
  "#FFEBB9",
  "#B9B8B7",
  "#858381"))

wgs <- read_csv('../data/preprocessing/warsaw_wgs84_every_500m.txt')
districts <- read_csv('../data/preprocessing/district_ids_mapping.csv')

places = read_csv("../data/preprocessing/places.csv")
places_wgs84 = read_csv("../data/preprocessing/places_wgs84.csv")
popular_times <- read_csv('../data/preprocessing/popular_times.csv')

district_choices = districts$id
names(district_choices) = as.character(districts$district_name)
