# 1. Packages ----

library(tidyverse)
library(janitor)
library(readxl)

dataset <- "0075" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., range = "B9:Q26") %>% 
  rename(locality = Site, decimalLatitude = "Latitude (N)",
         decimalLongitude = "Longitude (E)", verbatimDepth = "depth (m)") %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(locality = case_when(locality == "Bu Rashid Island" ~ "Abu Rashid",
                              locality == "Phi Phi (BB) Beach" ~ "Phi Phi Beach",
                              TRUE ~ locality))

## 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., col_names = FALSE) %>% 
  t() %>% 
  as_tibble() %>% 
  drop_na(V1) %>% 
  select(-V3, -V6, -V7, -V10, -V37, -V47) %>% 
  row_to_names(row_number = 1) %>% 
  pivot_longer(7:ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  rename(locality = Site, eventDate = Date, parentEventID = "Transect Number",
         habitat = Habitat, recordedBy = "Observer (Name)", samplingProtocol = "Transect Length (m)") %>% 
  mutate(parentEventID = as.numeric(parentEventID),
         measurementValue = as.numeric(measurementValue),
         eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30"),
         samplingProtocol = paste0("Line intersect transect, ", samplingProtocol, " m transect length"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         locality = case_when(locality == "Phi Phi Beach, Musandam" ~ "Phi Phi Beach",
                              locality == "Phiphi Beach, Musandam" ~ "Phi Phi Beach",
                              locality == "Al Harf, Oman" ~ "Al Harf",
                              locality == "Abu Rashid, Musandam" ~ "Abu Rashid",
                              locality == "Shark island" ~ "Shark Island",
                              locality == "Delma-North" ~ "Delma North",
                              locality == "Eagle Bay, Musandam" ~ "Eagle Bay",
                              locality == "Dibba" ~ "Dibba Island",
                              locality == "Delma" ~ "Delma West",
                              locality == "Sharm" ~ "Sharm Rocks",
                              locality == "Saaidiyat" ~ "Saadiyat",
                              locality == "Hole in the wall,KFK" ~ "Hole in the Wall",
                              locality == "Bu Nair North" ~ "Sir Bu Nair North",
                              locality == "Bu Nair West" ~ "Sir Bu Nair Northwest",
                              TRUE ~ locality)) %>% 
  left_join(., data_site) %>% 
  # Convert from length to percentage
  group_by(across(c(-measurementValue, -organismID))) %>% 
  mutate(tot = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/tot) %>% 
  select(-tot) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
