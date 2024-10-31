# 1. Packages ----

library(tidyverse)

dataset <- "0099" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  mutate(parentEventID = row_number(),
         verbatimDepth = case_when(zone == "LT" ~ 10,
                                   zone == "DO" ~ 5,
                                   TRUE ~ NA)) %>% 
  rename(decimalLatitude = lat, decimalLongitude = lon, locality = wpt.no) %>% 
  select(-area, -zone) %>% 
  pivot_longer("cca":"turf", names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(measurementValue = measurementValue*100,
         datasetID = dataset,
         samplingProtocol = case_when(year %in% c(2014, 2017) ~ "Line intersect transect",
                                      year %in% c(2020, 2023) ~ "Photo-quadrat",
                                      TRUE ~ NA),
         locality = paste0("S", locality)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
