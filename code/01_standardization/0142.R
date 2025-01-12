# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0142" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "site_metadata")

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "long_format") %>% 
  left_join(., data_site) %>% 
  rename(locality = "Site.Name", year = Year, month = Month, day = Day, parentEventID = Transect,
         verbatimDepth = "Depth.m", measurementValue = "Absolute.percent.cover", decimalLatitude = Latitude,
         decimalLongitude = Longitude) %>% 
  mutate(eventDate = as.Date(paste(year, month, day, sep = "-")),
         organismID = case_when(Genus.or.group == "Turbinaria" ~ paste(Broad.group, Genus.or.group, sep = " - "),
                                TRUE ~ Genus.or.group),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 30 m transect length, every 50 cm") %>% 
  select(datasetID, locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID, eventDate,
         samplingProtocol, year, month, day, organismID, measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
