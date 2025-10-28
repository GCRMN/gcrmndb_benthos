# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0237" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv()

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  left_join(., data_site) %>% 
  select(-locality) %>% 
  rename(decimalLatitude = latitude, decimalLongitude = longitude, verbatimDepth = depth_m,
         measurementValue = pct_cover, eventDate = date, locality = ps_site_id,
         samplingProtocol = method, organismID = morphotaxon) %>% 
  select(locality, decimalLatitude, decimalLongitude, habitat, verbatimDepth,
         eventDate, organismID, measurementValue, samplingProtocol) %>% 
  mutate(samplingProtocol = str_replace_all(samplingProtocol, "uvs", "Underwater Visual Sensus"),
         habitat = str_replace_all(habitat, "fore_reef", "Fore Reef"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
