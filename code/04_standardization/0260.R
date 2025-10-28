# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0260" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  pivot_longer("HardcoralPercent":"OtherPercent",
               names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, parentEventID = Replicate,
         samplingProtocol = Method) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID,
         verbatimDepth, year, month, samplingProtocol, organismID, measurementValue) %>% 
  mutate(samplingProtocol = "Line Intercept Transect",
         organismID = str_remove_all(organismID, "Percent"),
         measurementValue = measurementValue*100,
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
