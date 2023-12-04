# 1. Load packages ----

library(tidyverse) # Core tidyverse packages
library(sf)
sf_use_s2(FALSE) # Switch from S2 to GEOS

# 2. Load and change CRS ----

data_eez <- st_read("data/07_data-eez/01_raw/eez_v12.shp") %>% 
  st_transform(crs = 4326) %>% 
  st_make_valid() %>% 
  select(SOVEREIGN1, TERRITORY1) %>% 
  mutate(TERRITORY1 = str_replace_all(TERRITORY1, c("Micronesia" = "Federated States of Micronesia")),
         TERRITORY1 = str_remove_all(TERRITORY1, " / Enenkio"))

# 3. Remove holes within polygons ----

## 3.1 For all territory (except Micronesia and Palau) ----

data_eez <- nngeo::st_remove_holes(data_eez)

## 3.2 For Micronesia and Palau (particular cases) ----

data_eez_micronesia <- data_eez %>% 
  filter(TERRITORY1 == "Micronesia") %>% 
  # Transform MULTIPOLYGON to POLYGON
  st_cast(., "POLYGON") %>% 
  # Extract larger POLYGON
  mutate(area = st_area(.)) %>% 
  filter(area == max(area)) %>% 
  select(-area)

data_eez_palau <- data_eez %>% 
  filter(TERRITORY1 == "Palau") %>% 
  # Transform MULTIPOLYGON to POLYGON
  st_cast(., "POLYGON") %>% 
  # Extract larger POLYGON
  mutate(area = st_area(.)) %>% 
  filter(area == max(area)) %>% 
  select(-area)

## 3.3 Bind data ---- 

data_eez <- data_eez %>%
  filter(!(TERRITORY1 %in% c("Micronesia", "Palau"))) %>% 
  bind_rows(., data_eez_micronesia) %>% 
  bind_rows(., data_eez_palau)

rm(data_eez_micronesia, data_eez_palau)

# 4. Dataviz ----

ggplot() +
  geom_sf(data = data_eez)

# 5. Save data ----

st_write(data_eez, "data/07_data-eez/02_clean/eez_v12.shp", append = FALSE)

# 6. Create the buffer ----

data_eez %>% 
  filter(TERRITORY1 != "Alaska") %>% # Issue TopologyException for Alaska
  st_transform(crs = 7801) %>% # CRS in meters
  st_buffer(., dist = 1000) %>% # 1 km buffer
  st_transform(crs = 4326) %>% 
  st_wrap_dateline() %>% 
  st_make_valid() %>% 
  st_write(., "data/07_data-eez/03_buffer/eez_v12_buffer.shp", append = FALSE)
