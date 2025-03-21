# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0180" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Long, verbatimDepth = Depth.m,
         locality = SiteName, samplingProtocol = Method, year = Year, measurementValue = CoralCover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, samplingProtocol, verbatimDepth, measurementValue) %>% 
  mutate(organismID = "Hard coral",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
