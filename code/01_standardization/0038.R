# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(lubridate)
library(sf)
sf_use_s2(FALSE)

dataset <- "0038" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Load data --

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv()

# 2.2 Filter sites within coral reefs --

reef_buffer <- st_read("data/08_quality-checks-buffer/reefs-buffer_gee/reef_buffer.shp") %>% 
  st_transform(crs = 4326) %>% 
  st_wrap_dateline() %>% 
  st_make_valid()

data_main_sites <- data_main %>% 
  select(site_name, dataset_id, latitude, longitude) %>% 
  distinct() %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ggplot() +
  geom_sf(data = reef_buffer) +
  geom_sf(data = data_main_sites)

data_main_reefs <- st_intersection(data_main_sites, reef_buffer)

data_main_reefs <- data_main_reefs %>% 
  bind_rows(data_main_sites %>% filter(!(dataset_id %in% unique(data_main_reefs$dataset_id)))) %>% 
  rename(coral_reefs = GRIDCODE) %>% 
  mutate(coral_reefs = replace_na(coral_reefs, 0),
         coral_reefs = if_else(coral_reefs == 1, TRUE, FALSE))

ggplot() +
  geom_sf(data = reef_buffer) +
  geom_sf(data = data_main_reefs, aes(color = coral_reefs))

data_main <- left_join(data_main_reefs, data_main) %>% 
  st_drop_geometry()

# 2.3 Standardize the data --

data_main <- data_main %>% 
  filter(coral_reefs == TRUE) %>% 
  rename(locality = site_name,
         parentEventID = dataset_id,
         decimalLatitude = latitude,
         decimalLongitude = longitude,
         verbatimDepth = depth,
         eventDate = survey_date,
         organismID = RLS_category,
         measurementValue = percent_cover) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude, verbatimDepth,
         eventDate, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         parentEventID = as.numeric(as.factor(parentEventID)),
         samplingProtocol = "Photo-quadrat, 50 m transect length, every 2.5 m", # Based on Edgar et al, 2020
         eventDate = as_date(eventDate, format = "%d/%m/%Y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

# 2.4 Remove sites with non coral reefs benthic categories --

uncorrect_sites <- data_main %>% 
  filter(organismID %in% c("Other fucoids", "Ecklonia radiata", "Large brown laminarian kelps")) %>% 
  select(parentEventID) %>% 
  distinct() %>% 
  pull()

data_main %>% 
  filter(!(parentEventID %in% uncorrect_sites)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main, data_main_reefs, data_main_sites, reef_buffer, uncorrect_sites)
