# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0110" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(., fileEncoding = "latin1", na.strings = c("", "NA")) %>% 
  mutate(decimalLatitude2 = convert_coords(decimalLatitude),
         decimalLatitude = as.numeric(str_replace_all(decimalLatitude, ",", "\\.")),
         decimalLatitude = coalesce(decimalLatitude2, decimalLatitude),
         decimalLongitude2 = convert_coords(decimalLongitude),
         decimalLongitude = as.numeric(str_replace_all(decimalLongitude, ",", "\\.")),
         decimalLongitude = coalesce(decimalLongitude2, decimalLongitude),
         decimalLongitude = -abs(decimalLongitude)) %>% 
  select(-decimalLatitude2, -decimalLongitude2)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  rename(year = YEAR, locality = SITES, 
         parentEventID = TRANSECT, measurementValue = 'PERCENTAGE COVERAGE') %>% 
  mutate(organismID = coalesce(SPECIES, `CATEGORY NAME`),
         parentEventID = as.numeric(parentEventID),
         datasetID = dataset,
         samplingProtocol = "Point intercept transect") %>% 
  select(locality, parentEventID, year, parentEventID, organismID, measurementValue, datasetID, samplingProtocol) %>% 
  left_join(., data_site) %>% 
  mutate(locality = str_remove_all(locality, " \\(PNN Corales del Rosario y San Bernardo\\)"),
         organismID = ifelse(organismID == "Turbinaria sp.", "Algae - Turbinaria sp.", organismID)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords)
