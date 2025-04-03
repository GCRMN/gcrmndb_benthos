# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0219" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(, na = c("NA", "N/A", "-")) %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Long, locality = Site, year = Year, verbatimDepth = "Depth (m)") %>% 
  select(-SUM) %>% 
  pivot_longer("HC":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(datasetID = dataset,
         locality = str_to_title(locality),
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "SC" = "Soft coral",
                                                    "RKC" = "Recently killed coral",
                                                    "NIA" = "Algae",
                                                    "SP" = "Sponges",
                                                    "RC" = "Rock",
                                                    "RB" = "Rubble",
                                                    "ALG" = "Algae",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt",
                                                    "OT" = "Other")),
         across(c("decimalLatitude", "decimalLongitude"), ~str_remove_all(.x, " ")),
         across(c("decimalLatitude", "decimalLongitude"), ~as.numeric(str_sub(.x, 1,2))+
                  (as.numeric(paste0(str_sub(.x, 3,4), ".", str_sub(.x, 5,7)))/60)),
         verbatimDepth = as.numeric(str_split_fixed(verbatimDepth, "-", 2)[,1]),
         verbatimDepth = ifelse(verbatimDepth == 1306, 13, verbatimDepth)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
