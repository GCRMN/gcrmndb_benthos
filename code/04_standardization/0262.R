# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0262" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, na = c("", "NA", "na")) %>% 
  pivot_longer("HC":"OT", names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, parentEventID = Replicate,
         samplingProtocol = Method) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         parentEventID, organismID, measurementValue) %>% 
  mutate(organismID = str_remove_all(organismID, "_percent"),
         parentEventID = as.numeric(parentEventID),
         datasetID = dataset,
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "SC" = "Soft coral",
                                                    "RKC" = "Recently killed coral",
                                                    "DCA" = "Dead coral algae",
                                                    "CA" = "Coralline algae",
                                                    "NIA" = "Nutrient Indicator Algae",
                                                    "SP" = "Sponges",
                                                    "RC" = "Rock",
                                                    "RB" = "Rublle",
                                                    "SD" = "Sand",
                                                    "SI" = "Silt",
                                                    "OT" = "Other fauna"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
