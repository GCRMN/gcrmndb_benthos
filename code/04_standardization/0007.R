# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0007" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read.csv2(file = .)

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 3) %>% 
  select(-Date, -Observations) %>% 
  rename(year = Year, recordedBy = Observer, habitat = Habitat, 
         parentEventID = Station, code = Substrate) %>% 
  left_join(., data_code) %>% # Merge main data with substrates codes
  select(-code) %>% # Delete useless variables
  group_by(year, recordedBy, habitat, parentEventID, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(year, recordedBy, habitat, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         measurementValue = (measurementValue/total)*100,
         decimalLongitude = -149.901167,
         decimalLatitude = -17.470833,
         parentEventID = str_extract(parentEventID, "[1-9]"),
         samplingProtocol = "Point intersect transect, 50 m transect length, every 50 cm") %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code)