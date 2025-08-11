# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0248" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data for the GRC3 ----

data_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = site_number, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(year = str_sub(Date, 6, 9),
         month = 9,
         locality = paste0("S", locality)) %>% 
  select(-Date, -GBRMPA_LABEL_ID) %>% 
  pivot_longer("Branching_Cover_mean":"Massive_Cover_mean",
               names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = paste0("Hard coral - ", str_split_fixed(organismID, "_", 2)[,1]))

## 2.2 Data for the GRC4 ----

data_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = site_number, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(year = str_sub(Date, 6, 9),
         month = 9,
         locality = paste0("S", locality)) %>% 
  select(-Date, -GBRMPA_LABEL_ID) %>% 
  pivot_longer("Branching_Cover_mean":"Massive_Cover_mean",
               names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = paste0("Hard coral - ", str_split_fixed(organismID, "_", 2)[,1]))

## 2.3 Combine and export data ----

bind_rows(data_a, data_b) %>% 
  mutate(datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_a, data_b)
