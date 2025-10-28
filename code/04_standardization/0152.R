# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

source("code/00_functions/convert_coords.R")

dataset <- "0152" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(Site = ReefSite, decimalLatitude = Latitude..N., decimalLongitude = Longitude..W.) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)),
         decimalLongitude = -decimalLongitude)

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() 

## 2.3 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  pivot_longer("acce_cover":ncol(.), names_to = "benthic_cover_code", values_to = "measurementValue") %>% 
  left_join(., data_code) %>% 
  left_join(., data_site) %>% 
  rename(locality = Site, year = Year, organismID = Description,
         verbatimDepth = MedianDepth) %>% 
  select(locality, verbatimDepth, year, decimalLatitude, decimalLongitude, organismID, measurementValue) %>% 
  mutate(samplingProtocol = "Point intersect transect, 30 m transect length, every 25 cm",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code, convert_coords)
