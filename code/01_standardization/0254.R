# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0254" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, skip = 1, na = c("", "NA", "na")) %>% 
  pivot_longer("Hardcoral_percent":"Other_percent", names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Location, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method,
         parentEventID = Replicate) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         parentEventID, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         organismID = str_remove_all(organismID, "_percent")) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
