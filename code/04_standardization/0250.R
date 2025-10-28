# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0250" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, na = c("", "NA", "na"), range = "A1:AD277") %>% 
  pivot_longer("CORAL (LHC)":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  rename(year = Year, month = Month, parentEventID = "Transect No.", locality = "Site*\r\nSee full name below") %>% 
  mutate(decimalLatitude = str_split_fixed(Coordinates, "N ", 2)[,1],
         decimalLongitude = str_split_fixed(Coordinates, "N ", 2)[,2],
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x))) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude, month, year, organismID, measurementValue) %>% 
  mutate(organismID = str_split_fixed(organismID, " \\(", 2)[,1],
         parentEventID = as.numeric(as.factor(parentEventID)),
         month = str_replace_all(month, c("May" = "5",
                                          "Dec" = "12",
                                          "Jan" = "1",
                                          "Aug" = "8",
                                          "Sep" = "9",
                                          "Jul-Sept" = NA,
                                          "Oct" = "10",
                                          "Nov" = "11")),
         month = as.numeric(month),
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
