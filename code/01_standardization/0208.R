# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0208" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(locality = SiteID, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, eventDate = Date, samplingProtocol = Method, parentEventID = TransectoID) %>% 
  pivot_longer("Hard Coral":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
         parentEventID, samplingProtocol, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intercept transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
