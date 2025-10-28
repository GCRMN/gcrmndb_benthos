# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0143" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "site_metadata") %>% 
  rename(Site.name = Site.Name)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "data_wide") %>% 
  pivot_longer("Pavement":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  left_join(., data_site) %>% 
  rename(locality = "Site.name", year = Year, month = Month, day = Day, parentEventID = Transect,
         verbatimDepth = "Depth..m.", decimalLatitude = Latitude,
         decimalLongitude = Longitude) %>% 
  mutate(eventDate = as.Date(paste(year, month, day, sep = "-")),
         organismID = case_when(organismID == "Turbinaria" ~ paste("Hard coral", organismID, sep = " - "),
                                TRUE ~ organismID),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 50 m transect length, every 50 cm") %>% 
  select(datasetID, locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID, eventDate,
         samplingProtocol, year, month, day, organismID, measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
