# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0217" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Long, locality = Site, year = Year) %>% 
  select(-SUM) %>% 
  pivot_longer("HC":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(datasetID = dataset,
         measurementValue = measurementValue*100,
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "SC" = "Soft coral",
                                                    "RKC" = "Recently killed coral",
                                                    "NIA" = "Algae",
                                                    "SP" = "Sponges",
                                                    "RC" = "Rock",
                                                    "RB" = "Rubble",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt",
                                                    "OT" = "Other")),
         decimalLatitude = str_remove_all(decimalLatitude, "N"),
         decimalLongitude = str_remove_all(decimalLongitude, "E"),
         across(c("decimalLatitude", "decimalLongitude"), ~str_replace_all(.x, "º", "°")),
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
