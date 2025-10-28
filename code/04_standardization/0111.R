# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0111" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  rename(locality = Site, decimalLatitude = "Latitude N",
         decimalLongitude = "Longitude W") %>% 
  select(locality, decimalLatitude, decimalLongitude) %>% 
  drop_na(decimalLatitude) %>% 
  distinct()

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  select(-Country, -`Latitude N`, -`Longitude W`) %>% 
  rename(locality = Site, year = Year) %>% 
  pivot_longer("HC":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  left_join(., data_site) %>% 
  mutate(decimalLongitude = -decimalLongitude,
         datasetID = dataset,
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "NIA" = "Macroalgae",
                                                    "SC" = "Soft corals zoanthids",
                                                    "SP" = "Sponges",
                                                    "OT" = "Others",
                                                    "RKC" = "Dead corals",
                                                    "RC" = "Hard substrate",
                                                    "RB" = "Rock",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
