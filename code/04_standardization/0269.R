# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0269" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., skip = 1, na = c("NA", "na")) %>% 
  filter(Year >= 2018) %>% # Remove data before 2018, which are included in datasetID 0263
  pivot_longer("Hardcoral_percent":"Other_percent", names_to = "organismID", values_to = "measurementValue") %>% 
  select(Site, Latitude, Longitude, Depth, Year, Month, Method, organismID, measurementValue) %>% 
  drop_na(measurementValue) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method) %>% 
  mutate(verbatimDepth = as.numeric(verbatimDepth),
         datasetID = dataset,
         organismID = str_remove_all(organismID, "_percent"),
         samplingProtocol = case_when(str_detect(samplingProtocol, "timed swim") == TRUE ~ "Timed swim",
                                      samplingProtocol == "Line_intercept_transect" ~ "Line Intercept Transect",
                                      samplingProtocol == "quadrat" ~ "Photo-quadrat")) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
