# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0245" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, na = c("", "NA", "na")) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method,
         parentEventID = Replicate) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         samplingProtocol, parentEventID, Hardcoral_percent, Softcoral_percent,
         Reckilledcoral_percent, Macroalgae_percent, Turfalgae_percent,
         Corallinealgae_percent, Other_percent) %>%  
  pivot_longer("Hardcoral_percent":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(organismID = str_remove_all(organismID, "_percent"),
         samplingProtocol = str_replace_all(samplingProtocol, "LIT", "Line intercept transect"),
         measurementValue = measurementValue*100,
         datasetID = dataset,
         month = as.numeric(month),
         verbatimDepth = as.numeric(verbatimDepth)) %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
