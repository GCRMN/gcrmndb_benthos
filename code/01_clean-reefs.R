# 1. Load packages ----

library(tidyverse)
library(sf)
sf_use_s2(FALSE)

# 2. Correct ETP coral reef sites (shared by Andrea Arriaga-Madrigual) ----

if(FALSE){
  
  read.csv("data/08_quality-checks-buffer/2025-10_regional_reef_type_data.csv") %>% 
    filter(decimalLatitude >= -90 & decimalLatitude <= 90) %>%
    filter(decimalLongitude < -74) %>% 
    drop_na(decimalLatitude, decimalLongitude) %>% 
    drop_na(reef_habitat_type) %>% 
    filter(reef_habitat_type != "rocky_reef") %>% 
    select(decimalLatitude, decimalLongitude, reef_habitat_type) %>% 
    distinct() %>% 
    st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) %>% 
    st_write(., "data/08_quality-checks-buffer/gcrmndb-benthos_etp-reef-sites.shp", append = FALSE)
  
}


















# 2. Load coral reef distribution ----

data_reefs <- st_read("data/08_quality-checks-buffer/01_reefs-area_wri/reef_500_poly.shp") %>% 
  st_transform(crs = 4326) %>% 
  st_wrap_dateline(options = "WRAPDATELINE=YES") %>% 
  st_make_valid()

# 3. Add coral reefs for Norfolk Island (missing in the WRI dataset) ----

# Rectangle coordinates calculated from Google Earth Engine
# var point = ee.Geometry.Point([167.958552, -29.061416]).buffer(250).bounds();
# Initial point obtained from observation of coral reefs presence in:
# "Anthropogenic Impacts on Coral-Algal Interactions of the Subtropical Lagoonal Reef, Norfolk Island"

data_reefs_norfolk <- tibble(latitude = c(-29.063664851920677, -29.063664851920677, -29.05916628351211,
                                          -29.05916628351211, -29.063664851920677),
                             longitude = c(167.95599918922915, 167.96111290164643,
                                           167.96111290164643, 167.95599918922915, 167.95599918922915)) %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% 
  st_combine()  %>% 
  st_cast("POLYGON")

# 4. 


  


ggplot() +
  geom_sf(data = datatata, aes(color = reef_habitat_type))









