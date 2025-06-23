# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0229" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  group_by(`Site Id`, Lat, Lon, date) %>% 
  mutate(Transect = as.numeric(as.factor(Transect))) %>% 
  ungroup() %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Lon, verbatimDepth = `Depth (m)`,
         eventDate = date, locality = `Site Id`, parentEventID = Transect) %>% 
  select(-`Reef Name`, -Facies, -Status, -`No Take (yes or No)`, -`Visibility M`, -year,
         -month, -`Rugosity (m)`, -`image#`, -`point#`) %>% 
  pivot_longer("Abiotic":ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  mutate(locality = paste0("S", locality),
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
