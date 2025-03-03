# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0172" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(-Source) %>% 
  rename(locality = Site, year = Year, measurementValue = `%CoralCover`,
         decimalLatitude = Lat, decimalLongitude = Lon, verbatimDepth = Depth) %>% 
  mutate(organismID = "Hard coral",
         datasetID = dataset,
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_coords)
