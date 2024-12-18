# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0138" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 2) %>% 
  select(1, Lat, Long) %>% 
  rename(locality = 1, decimalLatitude = Lat, decimalLongitude = Long) %>% 
  mutate(decimalLatitude = convert_coords(decimalLatitude),
         decimalLatitude = case_when(locality == "Diadema City" ~ 17.61468,
                                     locality == "Ladder Bay" ~ 17.63636,
                                     TRUE ~ decimalLatitude),
         decimalLongitude = -convert_coords(decimalLongitude),
         decimalLongitude = case_when(locality == "Diadema City" ~ -63.24888,
                                      locality == "Ladder Bay" ~ -63.25633,
                                      TRUE ~ decimalLongitude))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 3, skip = 1) %>% 
  filter(Total != 0) %>% 
  rename(locality = Location, eventID = Quadrat, year = Year) %>% 
  pivot_longer("Acropora cervicornis (ACC)":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  select(locality, eventID, year, organismID, measurementValue) %>% 
  drop_na(measurementValue) %>% 
  left_join(., data_site) %>% 
  mutate(organismID = str_replace_all(organismID, " \\s*\\([^\\)]+\\)", ""),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords)
