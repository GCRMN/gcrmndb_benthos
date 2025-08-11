# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0241" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, skip = 1, na = c("", "NA", "na")) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, eventDate = Year, samplingProtocol = Method,
         parentEventID = Replicate) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
         samplingProtocol, parentEventID, Hardcoral_percent, Softcoral_percent,
         Reckilledcoral_percent, Macroalgae_percent, Turfalgae_percent,
         Corallinealgae_percent, Other_percent) %>%  
  pivot_longer("Hardcoral_percent":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = as.numeric(verbatimDepth),
         organismID = str_remove_all(organismID, "_percent"),
         samplingProtocol = str_replace_all(samplingProtocol, "Point_intercept_transect", "Point intercept transect"),
         datasetID = dataset) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
