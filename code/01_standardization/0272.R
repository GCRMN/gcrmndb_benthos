# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0272" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Lord Howe Island data ----

data_lordhowe <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv()

## 2.2 Norfolfk Island data ----

data_norfolk <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv()

## 2.3 Combine data ----

bind_rows(data_lordhowe, data_norfolk) %>% 
  select(-se, -CI_95_lower_bound, -CI_95_upper_bound) %>% 
  rename(locality = site, measurementValue = cover, organismID = response_variable,
         decimalLatitude = latitude, decimalLongitude = longitude) %>% 
  mutate(month = as.numeric(str_replace_all(month, c("March" = "3"))),
         measurementValue = measurementValue*100,
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_norfolk, data_lordhowe)
