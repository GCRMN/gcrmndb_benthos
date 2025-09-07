# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0258" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., skip = 1, sheet = 1, na = c("", "NA", "na")) %>% 
  pivot_longer("Hardcoral_percent":"Other_percent", names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, parentEventID = Replicate,
         samplingProtocol = Method) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         parentEventID, samplingProtocol, organismID, measurementValue) %>% 
  mutate(organismID = str_remove_all(organismID, "_percent"),
         datasetID = dataset,
         samplingProtocol = "Line Intercept Transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
