# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0210" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "sites") %>% 
  rename(locality = Name, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., na = c("NA")) %>%
  select(-Aspect, -relative_depth) %>% 
  rename(year = Year, locality = Site, verbatimDepth = depth,
         day = Day, month = Month, parentEventID = transect, eventID = quadrat,
         organismID = benthic_attribute, measurementValue = percent) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         eventDate = case_when(!(is.na(year)) & !(is.na(month)) & !(is.na(day)) ~
                                 paste0(year, "-", str_pad(month, 2, pad = "0"), "-", str_pad(day, 2, pad = "0")),
                               TRUE ~ NA),
         eventDate = as.Date(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
