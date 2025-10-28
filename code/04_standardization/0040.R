# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0040" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  select(Depth, Surveyor, Lat, Long, Year, Site, Transect, "Acr_br":"Turf") %>% 
  rename(locality = Site, parentEventID = Transect, decimalLatitude = Lat,
         decimalLongitude = Long, verbatimDepth = Depth, year = Year, recordedBy = Surveyor) %>% 
  pivot_longer("Acr_br":"Turf", names_to = "code", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(datasetID = dataset) %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code)