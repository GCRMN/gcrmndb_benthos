# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0098" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(.) %>%
  rename(locality = "Site.Name", decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(decimalLongitude = -decimalLongitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., skip = 2) %>% 
  mutate(parentEventID = row_number(), .before = Site) %>% 
  pivot_longer(6:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(verbatimDepth = "Depth (m)", locality = "Site", eventDate = Date) %>% 
  select(-Year) %>% 
  filter(!(organismID %in% c("Stony Coral %", "Turf  CH (mm)", "Turf AI", "Macro CH (mm)",
                             "Macro AI", "Algal index", "Art CH (mm)", "Lobophora %",
                             "Articulated %", "NCC %"))) %>% 
  drop_na(measurementValue) %>% 
  mutate(eventDate = as.Date(eventDate),
         locality = str_replace_all(locality, c("Bachelor's Beach" = "Bachelor",
                                                "No Dive Reserve" = "No-Dive Reserve",
                                                "Bachelors" = "Bachelor",
                                                "Oil Slick Leap" = "Oil Slick",
                                                "No Dive" = "No-Dive Reserve")),
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Line intersect transect, 10 m transect length") %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
