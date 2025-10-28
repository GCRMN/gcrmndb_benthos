# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0173" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data from 5 meters depth ----

data_5 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(, sheet = 1, skip = 2) %>% 
  mutate(verbatimDepth = 5)

## 2.2 Data from 10 meters depth ----

data_10 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(, sheet = 2, skip = 2) %>% 
  mutate(verbatimDepth = 10)

## 2.3 Merge datasets ----

bind_rows(data_5, data_10) %>% 
  select("Site local name", "Latitudes", "Longitudes", "Hard Corals", "Soft Corals",
         "Algal cover", "Associated Fauna", "Dead Compounet", "verbatimDepth", "Dead Components") %>% 
  rename(locality = "Site local name",
         decimalLatitude = Latitudes,
         decimalLongitude = Longitudes) %>% 
  relocate(verbatimDepth, .after = decimalLongitude) %>% 
  pivot_longer(5:10, names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(measurementValue = measurementValue*100,
         year = 2024,
         month = 8,
         datasetID = dataset,
         across(c(decimalLatitude, decimalLongitude), ~str_remove_all(.x, " ")),
         across(c(decimalLatitude, decimalLongitude), ~str_replace_all(.x, "o", "°")),
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_5, data_10, convert_coords)
