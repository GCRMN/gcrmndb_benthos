# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0049" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 1, na = c("", "NA")) %>% 
  select(1:9) %>% 
  mutate(year = as.numeric(str_split_fixed(Date, "\\.", 2)[,1]),
         month = as.numeric(str_split_fixed(Date, "\\.", 2)[,2]),
         parentEventID = if_else(Sampling == "LIT.10m", Transect.Quadrat, NA),
         eventID = if_else(Sampling == "Quadrat.1m2", Transect.Quadrat, NA),
         datasetID = dataset) %>% 
  select(-Date, -Transect.Quadrat) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, samplingProtocol = Sampling, organismID = Substrate,
         measurementValue = "%cover") %>% 
  mutate(samplingProtocol = case_when(samplingProtocol == "LIT.10m" ~ 
              "Line intersect transect, 10 m transect length",
            samplingProtocol == "Quadrat.1m2" ~ 
              "Photo-quadrat, 10 m transect length, every 1 m, area of 1 m2, image analyzed by 91 point count"),
         organismID = str_replace_all(organismID, "Sand&Rubble", "Sand and rubble"),
         measurementValue = measurementValue*100) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~ 
                  -(abs(as.numeric(str_split_fixed(.x, "°", 2)[,1])) + 
                      (as.numeric(str_split_fixed(.x, "°", 2)[,2])/60)))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
