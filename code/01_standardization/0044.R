# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

source("code/00_functions/convert_coords.R")

dataset <- "0044" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  rename(locality = Site, habitat = Habitat,
         decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = convert_coords(decimalLongitude),
         habitat = str_remove_all(habitat, "_West|_East"),
         habitat = str_replace_all(habitat, "_", " ")) %>% 
  select(-Note) %>% 
  as.data.frame()

# 2.2 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  pivot_longer("Acanthastrea":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  filter(measurementValue != 0) %>% 
  rename(verbatimDepth = Depth, eventDate = Date, parentEventID	= Transect, locality = Site) %>% 
  select(-Year, -YearGroup, -Project, -Habitat) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         # Site names were replaced (see data site)
         locality = str_replace_all(locality, c("Nikko_1" = "Ngermid_1",
                                                "Nikko_2" = "Ngermid_2",
                                                "Nikko_3" = "Ngermid_3"))) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
