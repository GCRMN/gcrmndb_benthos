# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0078" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  mutate(across(c(Latitud, Longitud), ~round(.x, 4))) %>% # Correct issue of slightly different coordinates
  rename(locality = Site, decimalLatitude = Latitud, decimalLongitude = Longitud,
         verbatimDepth = 'Average Depth (m)', day = Day, month = Month, year = Year,
         parentEventID = Transect, eventID = Image, organismID = 'spp Name',
         measurementValue = 'Cov% per species') %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, day, month, year,
         parentEventID, eventID, organismID, measurementValue) %>% 
  mutate(eventDate = date(paste(year, month, day, sep = "-")),
         datasetID = dataset,
         samplingProtocol	= "Photo-quadrat") %>% 
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID, eventDate) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
