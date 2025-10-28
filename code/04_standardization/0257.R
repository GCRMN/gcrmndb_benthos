# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")
library(sf)

dataset <- "0257" # Define the dataset_id

# 2. Import, standardize and export the data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., skip = 1, sheet = 1, na = c("", "NA", "na", "-")) %>% 
  pivot_longer("Hardcoral_percent":"Other_percent", names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, year = Year, month = Month, samplingProtocol = Method,
         parentEventID = Replicate) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year, month,
         samplingProtocol, parentEventID, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         verbatimDepth = as.numeric(verbatimDepth),
         samplingProtocol = str_replace_all(samplingProtocol, "Point_intercept_transect", "Point intercept transect"),
         organismID = str_remove_all(organismID, "_percent"),
         decimalLatitude2 = ifelse(str_detect(decimalLatitude, "°") == TRUE, decimalLatitude, NA),
         decimalLatitude = ifelse(str_detect(decimalLatitude, "°") == TRUE, NA, decimalLatitude),
         decimalLatitude2 = convert_coords(decimalLatitude2),
         decimalLongitude2 = ifelse(str_detect(decimalLongitude, "°") == TRUE, decimalLongitude, NA),
         decimalLongitude = ifelse(str_detect(decimalLongitude, "°") == TRUE, NA, decimalLongitude),
         decimalLongitude2 = convert_coords(decimalLongitude2),
         row_nb = row_number())

data_coords <- data_main %>%
  select(row_nb, decimalLatitude, decimalLongitude) %>% 
  drop_na(decimalLatitude) %>% 
  st_as_sf(coords = c("decimalLatitude", "decimalLongitude"), crs = "EPSG:32648", remove = FALSE) %>% 
  st_transform(crs = 4326) %>% 
  mutate(decimalLatitude3 = st_coordinates(.)[,2],
         decimalLongitude3 = st_coordinates(.)[,1]) %>% 
  st_drop_geometry()

data_main <- left_join(data_main, data_coords) %>% 
  mutate(decimalLatitude = coalesce(decimalLatitude2, decimalLatitude3),
         decimalLongitude = coalesce(decimalLongitude2, decimalLongitude3)) %>% 
  select(-decimalLatitude2, -decimalLongitude2, -decimalLatitude3, -decimalLongitude3, -row_nb) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main, data_coords, convert_coords)
