# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(sf)

dataset <- "0019" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv2(.) %>% 
  select(Site, Station, X, Y) %>% 
  # Change CRS (RGNC91-93)
  st_as_sf(coords = c("X", "Y"), crs = "+proj=lcc +lat_0=-21.5 +lon_0=166 +lat_1=-20.6666666666667 +lat_2=-22.3333333333333 +x_0=400000 +y_0=300000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs") %>% 
  st_transform(crs = 4326) %>% 
  mutate(decimalLongitude = as.numeric(st_coordinates(.)[,1]),
         decimalLatitude = as.numeric(st_coordinates(.)[,2])) %>% 
  st_drop_geometry() %>% 
  mutate(locality	= paste(Site, Station, sep = " "),
         locality = str_to_title(locality)) %>% 
  select(-Site, -Station)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "typo_LIT", na = "NA") %>% 
  rename(code = CODE_LIT_SOPRONER, organismID = All) %>% 
  select(code, organismID) %>% 
  distinct()

# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = "LIT") %>% 
  select(-Campagne, -Client, -Dist, -Lineaire) %>% 
  rename(eventDate = Date, parentEventID = "T", recordedBy = Obs,
         measurementValue = Couverture, code = Code_LIT) %>% 
  mutate(datasetID = dataset,
         eventDate = as_date(eventDate, origin = "1900-01-01"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         recordedBy = str_to_sentence(recordedBy),
         locality	= paste(Site, Station, sep = " "),
         locality = str_to_title(locality),
         code = str_to_upper(code),
         parentEventID = as.numeric(str_sub(parentEventID, 3, 3))) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-Site, -Station, -code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site)