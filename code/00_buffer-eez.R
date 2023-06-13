# 1. Load packages ----

library(tidyverse)
library(sf)
sf_use_s2(FALSE)

# 2. Load data ----

data_eez <- st_read("data/07_data-eez/eez_v11.shp") %>% 
  select(SOVEREIGN1, TERRITORY1) %>% 
  #filter(TERRITORY1 %in% c("French Polynesia", "Hawaii", "Fiji", "Tuvalu", "Gilbert Islands")) %>% 
  st_make_valid() %>% 
  st_transform(crs = 4326) %>% 
  st_make_valid() %>% 
  st_transform(crs = 7801) %>% # CRS in meters
  st_buffer(., dist = 1000) %>% # 1 km buffer
  st_transform(crs = 4326) %>% 
  st_wrap_dateline() %>% 
  st_make_valid()

ggplot() +
  geom_sf(data = data_eez) +
  coord_sf(xlim = c(170, 180))

# 3. Correct issue for Hawaii EEZ ----

data_eez_hawaii <- data_eez %>% 
  filter(TERRITORY1 == "Hawaii") %>% 
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180"))
  
# 4. Add correction to other EEZ ----

data_eez <- data_eez %>% 
  filter(TERRITORY1 != "Hawaii") %>% 
  bind_rows(., data_eez_hawaii)

ggplot() +
  geom_sf(data = data_eez) +
  coord_sf(xlim = c(170, 180))

# 5. Export the data ----

st_write(data_eez, "data/07_data-eez/eez_v11_buffer_1km.shp", append = FALSE)
