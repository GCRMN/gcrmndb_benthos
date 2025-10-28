# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0271" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  select(1:"Other (OT)") %>% 
  pivot_longer("Hard Coral (HC)":"Other (OT)",
              names_to = "organismID", values_to = "measurementValue") %>% 
  select(-"EcoRegion", -"Island", -"GPS Code") %>% 
  rename(locality = "Site name", decimalLatitude = Long, decimalLongitude = Lat,
         eventDate = Date, verbatimDepth = "Depth (m)") %>% 
  mutate(measurementValue = measurementValue*100,
         verbatimDepth = as.numeric(str_remove_all(verbatimDepth, "m")),
         organismID = str_split_fixed(organismID, " \\(", 2)[,1], # remove the text in parentheses
         eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         decimalLatitude = case_when(str_count(decimalLatitude, " ") == 0 ~ as.numeric(decimalLatitude),
                                     str_count(decimalLatitude, " ") == 1 ~ as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,1]) +
                                       as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,2])/60,
                                     str_count(decimalLatitude, " ") == 2 ~ as.numeric(str_split_fixed(decimalLatitude, " ", 3)[,1]) +
                                       as.numeric(str_split_fixed(decimalLatitude, " ", 3)[,2])/60 +
                                       as.numeric(str_split_fixed(decimalLatitude, " ", 3)[,3])/3600),
         decimalLongitude = case_when(str_count(decimalLongitude, " ") == 0 ~ as.numeric(decimalLongitude),
                                     str_count(decimalLongitude, " ") == 1 ~ as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,1]) +
                                       as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,2])/60,
                                     str_count(decimalLongitude, " ") == 2 ~ as.numeric(str_split_fixed(decimalLongitude, " ", 3)[,1]) +
                                       as.numeric(str_split_fixed(decimalLongitude, " ", 3)[,2])/60 +
                                       as.numeric(str_split_fixed(decimalLongitude, " ", 3)[,3])/3600)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
