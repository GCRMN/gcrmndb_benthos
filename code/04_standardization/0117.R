# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0117" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., range = "O9:P29", col_names = c("code", "locality"))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  rename(code = Reef, decimalLatitude = Latitude, decimalLongitude = Longitud, eventDate = Date) %>% 
  select(code, decimalLatitude, decimalLongitude, eventDate, CoralC, AlgaeC) %>% 
  pivot_longer("CoralC":"AlgaeC", names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(decimalLongitude = -decimalLongitude,
         organismID = str_replace_all(organismID, c("CoralC" = "Hard coral",
                                                    "AlgaeC" = "Algae")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
