# 1. Packages ----

library(tidyverse)
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0082" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(locality = 1) %>% 
  mutate(decimalLatitude = case_when(str_detect(Lat, "N") == TRUE ~ as.numeric(str_remove_all(Lat, "N")),
                                      TRUE ~ convert_coords(Lat)),
         decimalLongitude = case_when(str_detect(Long, "W") == TRUE ~ as.numeric(str_remove_all(Long, "W")),
                                      TRUE ~ convert_coords(Long)),
         decimalLongitude = -decimalLongitude,
         locality = str_replace_all(locality, "Torrens Point", "Torrents Point")) %>% 
  select(locality, decimalLatitude, decimalLongitude)

## 2.2 Main data ----

### 2.2.1 Data for 2021 and 2022 ----

metadata_main_2022 <- read_xlsx("data/01_raw-data/0082/GCRMN - Benthic Data_per transect_2021_2022_v2.xlsx",
                                sheet = 2, range = "A2:H24") %>% 
  select(Site, "2021", "2022") %>% 
  rename(locality = Site) %>% 
  pivot_longer(2:3, names_to = "year", values_to = "verbatimDepth") %>% 
  mutate(year = as.numeric(year))

data_main_2022 <- read_xlsx("data/01_raw-data/0082/GCRMN - Benthic Data_per transect_2021_2022_v2.xlsx",
                            sheet = 4, range = "A2:EA2561") %>% 
  pivot_longer("Shadow...34":"Tape (TAPE)", values_to = "measurementValue", names_to = "organismID") %>% 
  select(Year, Location, Transect, Quadrat, organismID, measurementValue) %>% 
  drop_na(measurementValue) %>% 
  rename(year = Year, locality = Location, parentEventID = Transect, eventID = Quadrat) %>% 
  left_join(., data_site) %>% 
  left_join(., metadata_main_2022)

### 2.2.2 Data for 2024 ----

metadata_main_2024 <- read_xlsx("data/01_raw-data/0082/GCRMN - Benthic_data_per transect_2024.xlsx",
                            sheet = 2) %>% 
  rename(locality = 1, eventDate = 2) %>%
  select(-"Average depth") %>% 
  pivot_longer(3:7, names_to = "parentEventID", values_to = "verbatimDepth") %>% 
  mutate(parentEventID = as.numeric(str_split_fixed(parentEventID, " ", 3)[,3]))

data_main_2024 <- read_xlsx("data/01_raw-data/0082/GCRMN - Benthic_data_per transect_2024.xlsx",
                            sheet = 4, skip = 1) %>% 
  pivot_longer("Shadow...34":"Tape (TAPE)", values_to = "measurementValue", names_to = "organismID") %>% 
  select(Year, Location, Transect, Quadrat, organismID, measurementValue) %>% 
  drop_na(measurementValue) %>% 
  rename(year = Year, locality = Location, parentEventID = Transect, eventID = Quadrat) %>% 
  mutate(locality = str_replace_all(locality, "Torrens Point", "Torrents Point")) %>% 
  left_join(., data_site) %>% 
  left_join(., metadata_main_2024)

### 2.2.3 Bind data ----

bind_rows(data_main_2022, data_main_2024) %>% 
  mutate(datasetID = dataset,
         organismID = str_remove(organismID, "\\s*\\([^\\)]+\\)"),
         samplingProtocol = "Photo-quadrat, 30 m transect length, every 2 m") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main_2022, data_main_2024, metadata_main_2022, metadata_main_2024, data_site)
