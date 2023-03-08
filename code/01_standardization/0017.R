# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format
library(sf)

dataset <- "0017" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls() %>% 
  st_as_sf(coords = c("X", "Y"), crs = "+proj=utm +zone=58 +south +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") %>% 
  st_transform(crs = 4326) %>% # Change CRS
  mutate(decimalLongitude = as.numeric(st_coordinates(.)[,1]),
         decimalLatitude = as.numeric(st_coordinates(.)[,2])) %>% 
  rename(locality = Station) %>% 
  st_drop_geometry()

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 2) %>% 
  select(CODE_LIT_SOPRONER, All) %>% 
  distinct() %>% 
  rename(Code_LIT_SOPRONER = CODE_LIT_SOPRONER, organismID = All)

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  rename(eventDate = Date, locality = Station, parentEventID = "T", measurementValue = Couverture,
         recordedBy = Obs, year = Campagne) %>% 
  select(-ORGANISME, -Ruban, -Lineaire, -CODE_LIT, -General, -Formes, -Acroporidae, -famille) %>% 
  mutate(datasetID = dataset,
         eventDate = as.Date(eventDate, origin = "1900-01-01"),
         samplingProtocol = "Line intersect transect, 20 m transect length",
         parentEventID = as.numeric(as.factor(parentEventID)),
         year = if_else(is.na(eventDate), year, year(eventDate)),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-Code_LIT_SOPRONER) %>% 
  drop_na(measurementValue) %>% 
  filter(measurementValue != 0) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site)