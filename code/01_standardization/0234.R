# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0234" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = Station, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, decimalLatitude, decimalLongitude) %>% 
  mutate(locality = str_replace_all(locality, "_", " "),
         locality = str_remove_all(locality, "\\.")) %>% 
  distinct()

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Plan view", na = c("NA", "na", " ", "")) %>% 
  select(-"total Coral", -"total", -"struc complexity") %>% 
  pivot_longer("sand":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = location, parentEventID = count, verbatimDepth = depth) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
