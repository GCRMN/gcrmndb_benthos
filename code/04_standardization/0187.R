# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0187" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  select("date":"rubble") %>% 
  pivot_longer("coral":"rubble", names_to = "organismID", values_to = "measurementValue") %>% 
  rename(eventDate = date, locality = site, decimalLatitude = latitude, decimalLongitude = longitude,
         verbatimDepth = depth, parentEventID = transect) %>% 
  mutate(measurementValue = measurementValue*100,
         eventDate = as.Date(eventDate, format = "%d/%m/%Y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

