# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0216" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(-SUM, -`Site code`) %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Long, locality = Site, year = Year) %>% 
  pivot_longer("HC":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(datasetID = dataset,
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "SC" = "Soft coral",
                                                    "RKC" = "Recently killed coral",
                                                    "NIA" = "Algae",
                                                    "SP" = "Sponges",
                                                    "RC" = "Rock",
                                                    "RB" = "Rubble",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt",
                                                    "OT" = "Other"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
