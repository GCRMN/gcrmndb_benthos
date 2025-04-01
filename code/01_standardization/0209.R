# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0209" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = Site, parentEventID = Transect, eventID = Quadrat, year = Year,
         verbatimDepth = Depth, organismID = name, measurementValue = cover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, parentEventID, eventID,
         verbatimDepth, organismID, measurementValue) %>% 
  mutate(measurementValue = measurementValue*100,
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
