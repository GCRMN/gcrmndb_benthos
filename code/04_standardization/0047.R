# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0047" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 1, col_types = c("text", "numeric", "numeric", "numeric",
                                               "date", "numeric", "text", "guess", "guess")) %>% 
  drop_na(Site) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, eventDate = Date, parentEventID = Transect, organismID = Substrate) %>% 
  select(1:7) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 20 cm") %>% 
  # Correction on longitude and depth
  mutate(decimalLongitude = if_else(decimalLongitude > 0, -decimalLongitude, decimalLongitude),
         verbatimDepth = if_else(verbatimDepth == 45047.0, 1.5, verbatimDepth)) %>% 
  group_by(across(-organismID)) %>% 
  mutate(total = n()) %>% 
  ungroup() %>% 
  group_by_all() %>% 
  count() %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total) %>% 
  select(-n, -total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
