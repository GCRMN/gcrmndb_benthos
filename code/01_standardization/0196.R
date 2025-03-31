# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0196" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "data_with_summary") %>% 
  # Select the organization since multiple datasetID in a single Excel sheet
  filter(Organization == "Blue Ventures") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude, year = Year,
         samplingProtocol = Method, organismID = `Benthic category`, measurementValue = mean_cover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, samplingProtocol, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         decimalLatitude = as.numeric(decimalLatitude),
         decimalLatitude = ifelse(locality == "Bevato_Permanent_Reserve", NA, decimalLatitude),
         decimalLongitude = as.numeric(decimalLongitude),
         decimalLongitude = ifelse(locality == "Bevato_Permanent_Reserve", NA, decimalLongitude)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
