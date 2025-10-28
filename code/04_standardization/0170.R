# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0170" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(locality = `Site (Short)`, decimalLatitude = Lat, decimalLongitude = Lon) %>% 
  select(locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(eventID = photo.Name, locality = site, verbatimDepth = depth,
         organismID = categories, measurementValue = percentage_cover) %>% 
  select(-atoll) %>% 
  left_join(., data_site) %>% 
  mutate(verbatimDepth = str_replace_all(verbatimDepth, c("10-5m" = "7.5",
                                                          "15-10m" = "12.5",
                                                          "20-15m" = "17.5",
                                                          "25-20m" = "22.5")),
         verbatimDepth = as.numeric(verbatimDepth)) %>% 
  # Convert eventID to numeric
  group_by(locality, verbatimDepth, year, decimalLatitude, decimalLongitude) %>% 
  arrange(eventID) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  # Convert verbatimDepth as parentEventID (4 depth per site)
  group_by(locality, year, decimalLatitude, decimalLongitude) %>% 
  arrange(verbatimDepth) %>% 
  mutate(parentEventID = as.numeric(as.factor(verbatimDepth))) %>% 
  ungroup() %>% 
  mutate(samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
