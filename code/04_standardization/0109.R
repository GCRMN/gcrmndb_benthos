# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0109" # Define the dataset_id

source("code/00_functions/convert_coords.R")

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"),
                ~convert_coords(str_replace_all(., "’", "'"))),
         decimalLongitude = -decimalLongitude,
         locality = paste0(Reef, " ", str_sub(Site, 2, 2)))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(.) %>% 
  rename(organismID = 1) %>% 
  pivot_longer(2:ncol(.), names_to = "Site", values_to = "measurementValue") %>% 
  left_join(., data_site) %>% 
  rename(verbatimDepth = Depth_m) %>% 
  mutate(parentEventID = as.numeric(str_sub(Site, -1, -1)),
         organismID = str_replace_all(organismID, " \\s*\\([^\\)]+\\)", ""),
         samplingProtocol = "Photo-quadrat, 10 m transect length",
         month = 8,
         year = 2019,
         datasetID = dataset) %>% 
  # Convert from number of CPCe points over the entire transect to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-Site, -Date, -total, -Reef) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords)
