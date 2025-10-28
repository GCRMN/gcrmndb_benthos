# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0197" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "data_with_summary") %>% 
  # Select the organization since multiple datasetID in a single Excel sheet
  filter(Organization == "PRÎSM") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude, year = Year,
         samplingProtocol = Method, organismID = `Benthic category`, measurementValue = mean_cover) %>% 
  select(locality, decimalLatitude, decimalLongitude, year, samplingProtocol, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         decimalLatitude = paste0(str_sub(decimalLatitude, 1, 3), ".",
                                  str_sub(decimalLatitude, 4, str_length(decimalLatitude))),
         decimalLatitude = str_replace_all(decimalLatitude, "\\.\\.", "\\."),
         decimalLatitude = as.numeric(decimalLatitude),
         decimalLongitude = paste0(str_sub(decimalLongitude, 1, 2), ".",
                                  str_sub(decimalLongitude, 3, str_length(decimalLongitude))),
         decimalLongitude = str_replace_all(decimalLongitude, "\\.\\.", "\\."),
         decimalLongitude = as.numeric(decimalLongitude)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)



library(leaflet)


leaflet(A) %>% 
  addTiles() %>% 
  addMarkers(~decimalLongitude, ~decimalLatitude, label = ~locality)









