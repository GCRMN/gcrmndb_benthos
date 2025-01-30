# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0151" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  drop_na(TOT_BIOTIC_COVER) %>% 
  rename(locality = STATION_CODE, decimalLatitude = LAT_DEGREES, decimalLongitude = LON_DEGREES,
         eventDate = DATE, organismID = SCIENTIFIC_NAME, measurementValue = TOT_BIOTIC_COVER, year = YEAR) %>% 
  select(locality, decimalLatitude, decimalLongitude, eventDate, organismID, measurementValue, year) %>% 
  mutate(datasetID = dataset,
         eventDate = as.Date(eventDate, format = "%d/%m/%Y"),
         year = ifelse(is.na(eventDate), year, year(eventDate)),
         month = month(eventDate),
         day = day(eventDate),
         organismID = str_remove_all(organismID, " spp"),
         organismID = ifelse(organismID == "Turbinaria", "Algae - Turbinaria", organismID)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
