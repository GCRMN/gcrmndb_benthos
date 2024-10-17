# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0091" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>%
  pull() %>% 
  read.csv2() %>% 
  mutate(organismID = str_remove_all(organismID, "% "))

## 2.2 Main data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 1) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2)

## 2.3 Data detailed for hard corals ----

data_hc <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2)

## 2.4 Data detailed for invertebrates ----

data_inv <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 3)

## 2.5 Data detailed for macroalgae ----

data_malg <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 4)

## 2.6 Combine and export data ----

data_main %>% 
  select(-LC, -TOTAL, -AINV, -OINV, -CMA, -FMA) %>% 
  left_join(., data_hc) %>% 
  left_join(., data_inv) %>% 
  left_join(., data_malg) %>% 
  pivot_longer(15:ncol(.), values_to = "measurementValue", names_to = "code") %>%
  left_join(., data_code) %>% 
  select(-code) %>% 
  rename(locality = Code, parentEventID = Trans, recordedBy = Surveyor, eventDate = Date,
         decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth) %>% 
  select(locality, parentEventID, recordedBy, eventDate, decimalLatitude, decimalLongitude,
         verbatimDepth, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_hc, data_inv, data_main, data_malg)
