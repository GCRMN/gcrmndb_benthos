# 1. Packages ----

library(tidyverse)
library(janitor)
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0071" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx() %>% 
  mutate(decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = convert_coords(decimalLongitude))

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(range = "A2:AE47") %>% 
  t() %>% 
  as_tibble() %>% 
  select(-V7) %>% 
  filter(!is.na(V1)) %>% 
  row_to_names(row_number = 1) %>% 
  pivot_longer(7:ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  rename(eventDate = Date, parentEventID = "Transect Number", locality = "Site", verbatimDepth = "Depth (m)",
         recordedBy	= "Observer (Name)") %>% 
  mutate(eventDate = as.Date(eventDate, tryFormats = c("%m.%d.%y")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         parentEventID = as.numeric(parentEventID),
         verbatimDepth = as.numeric(verbatimDepth),
         measurementValue = as.numeric(measurementValue),
         measurementValue = replace_na(measurementValue, 0)) %>% 
  group_by(locality, eventDate, parentEventID) %>% 
  mutate(n_points = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/n_points) %>% 
  select(-n_points) %>% 
  mutate(locality = str_replace_all(locality, c("blacktip" = "Black tip",
                                                "Inner reef-site 2 Oct" = "Inner Island")),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 25 m transect length, every 50 cm") %>% 
  select(-"Transect Length (m)") %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords)
