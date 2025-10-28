# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
source("code/00_functions/reefcloud_converter.R")

dataset <- "0028" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_csv(.) %>% 
  # Convert from ReefCloud format to gcrmndb_benthos format
  reefcloud_converter(.) %>% 
  mutate(decimalLatitude = ifelse(locality == "Cooks Rock", -19.546029, decimalLatitude),
         decimalLongitude = ifelse(locality == "Cooks Rock", 169.499078, decimalLongitude)) %>% 
  # Export the data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
