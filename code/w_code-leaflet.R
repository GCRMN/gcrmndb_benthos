library(leaflet)

leaflet(data = A) %>% 
  addTiles() %>%
  addMarkers(~decimalLongitude, ~decimalLatitude, label = ~locality)