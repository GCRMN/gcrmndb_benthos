# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0182" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Load and combine data ----

data_rowleys <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()

path_sites <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull()

load(path_sites)

data_rowleys <- left_join(data_rowleys, RSSites)

data_scott <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()

path_sites <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull()

load(path_sites)

data_main <- left_join(data_scott, Sites) %>% 
  bind_rows(data_rowleys, .)

## 2.2 Transform data ----

data_main %>% 
  rename(locality = Reef, decimalLatitude = LATITUDE, decimalLongitude = LONGITUDE,
         verbatimDepth = Depth, parentEventID = TRANSECT_NO, year = Year, month = Month,
         measurementValue = POINTS, habitat = HABITAT, organismID = CODE_DESCRIPTION_2021) %>% 
  mutate(organismID = str_remove_all(organismID, " spp.| spp"),
         organismID = case_when(organismID == "Turbinaria" ~ paste(GROUP_CODE, organismID, sep = " - "),
                                TRUE ~ organismID)) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID, habitat, verbatimDepth,
         year, month, measurementValue, organismID) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID, year, month) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total,
         datasetID = dataset,
         samplingProtocol = "Video transect") %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
  
# 3. Remove useless objects ----

rm(data_rowleys, data_scott, path_sites, RSSites, Sites, data_main)
