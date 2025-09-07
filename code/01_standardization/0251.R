# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0251" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1, skip = 1, na = c("", "NA", "na")) %>% 
  rename(locality = Location, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method,
         parentEventID = Replicate, measurementValue = Hardcoral_percent) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         samplingProtocol, parentEventID, measurementValue) %>% 
  mutate(organismID = "Hard coral",
         datasetID = dataset,
         samplingProtocol = str_replace_all(samplingProtocol, c("Point_intercept_transect" = "Point intercept transect",
                                                                "Belt_transect" = "Belt transect")),
         verbatimDepth = str_replace_all(verbatimDepth, c("3 to 5" = "4",
                                                          "1 to 4" = "2.5")),
         verbatimDepth = as.numeric(verbatimDepth),
         month = str_replace_all(month, c("Nov" = "11",
                                          "Jun-Oct" = NA)),
         month = as.numeric(month)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
