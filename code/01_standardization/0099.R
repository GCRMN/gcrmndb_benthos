# 1. Packages ----

library(tidyverse)

dataset <- "0099" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Long-term data ----

### 2.1.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv()

### 2.1.2 Main data ----

data_lt <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(., na.strings = c("NA", "")) %>% 
  pivot_longer(7:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  left_join(., data_site) %>% 
  drop_na(measurementValue) %>% 
  select(-Island) %>% 
  rename(locality = Location, eventID = quadrat, year = Year, month = Month,
         verbatimDepth = Depth, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(eventID = as.numeric(str_sub(eventID, -1, -1)),
         month = str_replace_all(month, c("November" = "11",
                                          "December" = "12",
                                          "September" = "9",
                                          "August" = "8",
                                          "October" = "10",
                                          "May" = "5",
                                          "February" = "2",
                                          "March" = "3")),
         month = as.numeric(month),
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "TF" = "Turf algae",
                                                    "MA" = "Macroalgae",
                                                    "OT" = "Other",
                                                    "SD" = "Sand",
                                                    "SP" = "Sponge",
                                                    "CCA" = "cca",
                                                    "CYA" = "Cyanobacteria",
                                                    "MI" = "",
                                                    "BS" = "",
                                                    "ND" = "")),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset)

## 2.2 Bonaire data ----

data_bonaire <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  mutate(parentEventID = row_number(),
         verbatimDepth = case_when(zone == "LT" ~ 10,
                                   zone == "DO" ~ 5,
                                   TRUE ~ NA)) %>% 
  rename(decimalLatitude = lat, decimalLongitude = lon, locality = wpt.no) %>% 
  select(-area, -zone) %>% 
  pivot_longer("cca":"turf", names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(measurementValue = measurementValue*100,
         datasetID = dataset,
         samplingProtocol = case_when(year %in% c(2014, 2017) ~ "Line intersect transect",
                                      year %in% c(2020, 2023) ~ "Photo-quadrat",
                                      TRUE ~ NA),
         locality = paste0("S", locality))

## 2.3 Combine data ----

bind_rows(data_lt, data_bonaire) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_main, data_bonaire)
