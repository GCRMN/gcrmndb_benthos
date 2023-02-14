# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format

dataset <- "0016" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "Data", skip = 1) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth_m,
         habitat = Zone, year = Year, month = Month, parentEventID = Replicate, recordedBy = Surveyor) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, habitat, year, month, parentEventID,
         recordedBy, "Hardcoral_percent":"Other_percent") %>% 
  pivot_longer("Hardcoral_percent":"Other_percent", names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 20 m transect length",
         organismID = str_remove_all(organismID, "_percent"),
         verbatimDepth = (as.numeric(str_split_fixed(verbatimDepth, "-", 2)[,1]) +
           as.numeric(str_split_fixed(verbatimDepth, "-", 2)[,2]))/2) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
