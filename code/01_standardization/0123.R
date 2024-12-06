# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0123" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = "data_with_replicate") %>% 
  # Select the organization since multiple datasetID in a single dataset
  filter(Organization == "CORDIO-CES-REEFolution") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         parentEventID = Replicate, organismID = `Benthic category`, measurementValue = mean_cover,
         samplingProtocol = Method, year = Year) %>% 
  select(locality, decimalLatitude, decimalLongitude, parentEventID, year, samplingProtocol,
         year, organismID, measurementValue) %>% 
  mutate(samplingProtocol = str_replace_all(samplingProtocol, "Photo quadrat", "Photo-quadrat"),
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
