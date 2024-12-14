# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(sf)

dataset <- "0135" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2()

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  pivot_longer("AAGA":ncol(.), names_to = "code", values_to = "measurementValue") %>% 
  rename(locality = Site, decimalLatitude = x, decimalLongitude = y, verbatimDepth = Depth) %>% 
  mutate(year = 2022,
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  filter(code != "LC") %>% 
  st_as_sf(coords = c("decimalLatitude", "decimalLongitude"), crs = "EPSG:32616") %>% 
  st_transform(crs = 4326) %>% 
  mutate(decimalLatitude = st_coordinates(.)[,2],
         decimalLongitude = st_coordinates(.)[,1]) %>% 
  st_drop_geometry() %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code)
