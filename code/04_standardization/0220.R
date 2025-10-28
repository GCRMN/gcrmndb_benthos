# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0220" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  mutate(eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.x)),
         decimalLatitude = -decimalLatitude)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  filter(`Image name` != "ALL IMAGES") %>% 
  select(-"Annotation status", -"Points") %>% 
  pivot_longer("Bleached Hard Coral Branching":ncol(.),
               names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(site_code = str_split_fixed(`Image name`, "_", 6)[,3],
         parentEventID = str_split_fixed(`Image name`, "_", 6)[,4],
         verbatimDepth = str_split_fixed(`Image name`, "_", 6)[,5],
         across(c(parentEventID, verbatimDepth), ~parse_number(.x)),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  left_join(., data_site) %>% 
  select(-`Image name`, -site_code) %>% 
  rename(eventID = "Image ID") %>% 
  group_by(locality, parentEventID) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords)
