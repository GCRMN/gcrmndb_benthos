# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0132" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  select(survey_id, site_latitude, site_longitude) %>% 
  distinct()

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  pivot_longer(13:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  left_join(., data_site) %>% 
  rename(locality = site, eventDate = date..UTC., parentEventID = transect,
         eventID = image_name, verbatimDepth = depth_m, decimalLatitude = site_latitude,
         decimalLongitude = site_longitude) %>% 
  select(locality, parentEventID, eventID, verbatimDepth, decimalLatitude, decimalLongitude,
         eventDate, organismID, measurementValue) %>% 
  mutate(eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  group_by(locality, parentEventID, eventDate, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
