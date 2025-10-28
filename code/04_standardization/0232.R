# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0232" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Kenya ----

data_kenya <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1, skip = 1) %>% 
  rename(locality = site, eventDate = date, decimalLatitude = latitude,
         decimalLongitude = longitude, measurementValue = `hard coral cover (%)`) %>% 
  select(locality, eventDate, decimalLatitude, decimalLongitude, measurementValue)
  
## 2.2 Red Sea ----

data_redsea <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  rename(locality = "Site name", eventDate = Date, decimalLatitude = Latitude, parentEventID = `#Photos`,
         decimalLongitude = Longitude, measurementValue = `% coral cover (inc. bleached)`) %>% 
  select(locality, eventDate, decimalLatitude, decimalLongitude, parentEventID, measurementValue) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(str_remove_all(.x, "° E|° N"))))

## 2.3 Oman ----

data_oman <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 3) %>% 
  rename(locality = Site, decimalLatitude = Latitude, parentEventID = `#photos`,
         decimalLongitude = Longitude, measurementValue = `% healthy coral`) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID, measurementValue) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(str_remove_all(.x, "° E|° N"))))

## 2.4 Combine data ----

bind_rows(data_kenya, data_oman, data_redsea) %>% 
  mutate(datasetID = dataset,
         organismID = "Hard coral",
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_oman, data_kenya, data_redsea)
