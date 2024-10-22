# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0095" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  rename(locality = dives_code, parentEventID = transect_code,
         measurementValue = cover, organismID = taxa,
         decimalLatitude = lat, decimalLongitude = long,
         eventDate = date, verbatimDepth = max_depth) %>% 
  select(-sites_code, -protec, -group, -group2) %>% 
  mutate(parentEventID = as.numeric(str_sub(parentEventID, -1)),
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat, 10 m transect length") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
