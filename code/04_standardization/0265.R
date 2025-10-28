# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0265" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, na = c("", "NA", "na")) %>% 
  pivot_longer("Hardcoral":"Other", names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, year = Year, month = Month, parentEventID = Replicate,
         decimalLongitude = Longitude, decimalLatitude = Latitude,
         verbatimDepth = Depth) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID, year, month,
         verbatimDepth, organismID, measurementValue) %>% 
  mutate(verbatimDepth = ifelse(verbatimDepth > 20, NA, verbatimDepth),
         decimalLatitude2 = ifelse(decimalLatitude > 50, decimalLatitude, NA),
         decimalLongitude2 = ifelse(decimalLongitude < 50, decimalLongitude, NA),
         decimalLatitude = ifelse(is.na(decimalLatitude2) == TRUE, decimalLatitude, decimalLongitude2),
         decimalLongitude = ifelse(is.na(decimalLongitude2) == TRUE, decimalLongitude, decimalLatitude2),
         datasetID = dataset) %>% 
  select(-decimalLatitude2, -decimalLongitude2) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
