# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0209" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Dataset 1 ----

data_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(locality = Site, parentEventID = Transect, eventID = Quadrat, year = Year,
         verbatimDepth = Depth, organismID = name, measurementValue = cover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, parentEventID, eventID,
         verbatimDepth, organismID, measurementValue) %>% 
  mutate(measurementValue = measurementValue*100,
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat")

## 2.2 Dataset 2 ----

data_mof <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.delim()

data_event <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.delim()

data_occ <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 4) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.delim()




B <- left_join(mof, event, by = "id") %>% 
  left_join(., occ, by = "id")






## 2.3 Combine data ----

bind_rows(data_a, data_b) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_a, data_b)
