# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0157" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  pivot_longer(6:ncol(.), names_to = "eventDate", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  select(-Transect, -Area) %>% 
  rename(locality = Reef, decimalLatitude = Lat, decimalLongitude = Lon) %>% 
  mutate(organismID = "Hard coral",
         year = case_when(eventDate == 33786 ~ 1992,
                          eventDate == 34029 ~ 1993,
                          eventDate == 34121 ~ 1993),
         month = case_when(eventDate == 33786 ~ 7,
                           eventDate == 34029 ~ 2,
                           eventDate == 34121 ~ 5),
         datasetID = dataset,
         across(c(decimalLatitude, decimalLongitude), ~str_replace_all(.x, c("′" = "'",
                                                                             "″" = "''"))),
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x))) %>% 
  select(-eventDate) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_coords)
