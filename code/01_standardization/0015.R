# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0015" # Define the dataset_id

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
  read_csv(., na = c("", "NA", "NaN")) %>% 
  select(site_id, reef_name, coordinates_in_decimal_degree_format, date, 
         "depth (m)", substrate_code, segment_code, total, substrate_recorded_by) %>% 
  rename(verbatimDepth = "depth (m)", eventDate = date, parentEventID	= site_id, recordedBy = substrate_recorded_by,
         eventID = segment_code, locality = reef_name, measurementValue = total, code = substrate_code) %>% 
  mutate(decimalLatitude = str_split_fixed(coordinates_in_decimal_degree_format, ",", 2)[,1],
         decimalLatitude = as.numeric(str_trim(decimalLatitude)),
         decimalLongitude = str_split_fixed(coordinates_in_decimal_degree_format, ",", 2)[,2],
         decimalLongitude = as.numeric(str_trim(decimalLongitude)),
         eventDate = dmy(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 20 m transect length, every 5 cm", 
         parentEventID = as.numeric(as.factor(parentEventID)), # To reduce the length of the character string
         eventID = as.numeric(as.factor(eventID))) %>% 
  group_by(locality, parentEventID, eventID, decimalLongitude, decimalLatitude, verbatimDepth, eventDate) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  filter(total != 0) %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  left_join(., data_code) %>% 
  select(-code, -coordinates_in_decimal_degree_format, -total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code)