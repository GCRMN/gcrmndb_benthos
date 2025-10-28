# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0084" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  pivot_longer("Coral":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(datasetID = dataset,
         month = month(Year),
         year = year(Year)) %>% 
  rename(locality = Site_Code,
         decimalLatitude = Lat,
         decimalLongitude = Long) %>% 
  select(-Year) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
