# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(lubridate)
library(sf)
sf_use_s2(FALSE)

dataset <- "0038" # Define the dataset_id

# 2. Load data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv()

# 3. Extract data from coral reefs (monitoring is not restricted to coral reefs for RLS) ----

# 3.1 Check if site is within coral reef distribution shapefile (100 km buffer) --

# 3.1.1 Extract site coordinates --

data_main_sites <- data_main %>% 
  select(site_name, dataset_id, latitude, longitude) %>% 
  distinct() %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# 3.1.2 Load coral reef distribution 100 km buffer --

reef_buffer <- st_read("data/08_quality-checks-buffer/reefs-buffer_gee/reef_buffer.shp") %>% 
  st_transform(crs = 4326) %>% 
  st_wrap_dateline() %>% 
  st_make_valid()

# 3.1.3 Check if sites are within or outside the buffer --

data_main <- data_main_sites %>% 
  mutate(check_buffer = st_intersects(data_main_sites, reef_buffer, sparse = FALSE)[,1]) %>% 
  mutate(latitude = st_coordinates(data_main_sites)[,2],
         longitude = st_coordinates(data_main_sites)[,1]) %>%
  st_drop_geometry() %>% 
  left_join(data_main, .)
  
# 3.2 Check if non-coral reefs algae are present within a quadrat --

data_main <- data_main %>% 
  group_by(survey_id, site_name, latitude, longitude, dataset_id) %>% 
  mutate(check_algae = any(RLS_category %in% c("Phyllospora",
                                               "Ecklonia radiata",
                                               "Large brown laminarian kelps"))) %>% 
  ungroup()

# 3.3 Check if hard corals are present within a quadrat --

data_main <- data_main %>% 
  group_by(survey_id, site_name, latitude, longitude, dataset_id) %>% 
  mutate(check_coral = any(RLE_category %in% c("Coral", "Dead coral"))) %>% 
  ungroup()

# 3.4 Use the (pre-) quality checks to subset the data --

data_checks <- data_main %>% 
  select(survey_id, site_name, latitude, longitude, dataset_id, check_buffer, check_algae, check_coral) %>% 
  distinct() %>% 
  group_by(check_buffer, check_algae, check_coral) %>% 
  count()

# 4. Standardize the data ----

data_main %>% 
  # Remove data based and (pre-)quality checks
  filter(check_buffer == TRUE) %>% 
  filter(check_algae == FALSE & check_coral == FALSE | 
           check_algae == FALSE & check_coral == TRUE |
           check_algae == TRUE & check_coral == TRUE) %>% 
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
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 5. Remove useless objects ----

rm(reef_buffer, data_main_sites, data_checks, data_main)
