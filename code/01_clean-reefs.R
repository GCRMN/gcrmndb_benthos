# 1. Load packages ----

library(tidyverse)
library(sf)
sf_use_s2(FALSE)

# 2. Correct ETP coral reef sites (shared by Andrea Arriaga-Madrigual) ----

read.csv("data/08_quality-checks-buffer/2025-10_regional_reef_type_data.csv") %>% 
  filter(decimalLatitude >= -90 & decimalLatitude <= 90) %>%
  filter(decimalLongitude < -74) %>% 
  drop_na(decimalLatitude, decimalLongitude) %>% 
  drop_na(reef_habitat_type) %>% 
  # "scattered_colonies", "other_formation", and "rocky_reef" removed :   
  filter(reef_habitat_type %in% c("coral_community", "coral_reef")) %>% 
  select(decimalLatitude, decimalLongitude, reef_habitat_type) %>% 
  distinct() %>% 
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) %>% 
  st_write(., "data/08_quality-checks-buffer/gcrmndb-benthos_etp-reef-sites.shp", append = FALSE)
