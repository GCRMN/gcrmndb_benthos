# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
source("code/00_functions/convert_coords.R")

dataset <- "0050" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(file = .) %>% 
  mutate(latitude = -(convert_coords(latitude)),
         longitude = -(convert_coords(longitude))) %>% 
  rename(decimalLatitude = latitude, decimalLongitude = longitude, locality = station)

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

## 2.3 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls(path = ., sheet = 1, na = c("", "NA")) %>% 
  select(-Site) %>% 
  rename(year = Campagne, locality = Station, parentEventID = Secteur) %>% 
  pivot_longer("RC":"HCO", names_to = "code", values_to = "measurementValue") %>% 
  left_join(., data_code) %>% 
  left_join(., data_site) %>% 
  select(-code) %>% 
  mutate(parentEventID = as.numeric(parentEventID),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 20 m transect length, every 50 cm") %>% 
  group_by(across(c(-measurementValue, -organismID))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (100*measurementValue)/total) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code)
