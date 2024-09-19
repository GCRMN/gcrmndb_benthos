# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0079" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "SiteMetadata") %>% 
  select(Location, Latitude, Longitude, Depth)

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "BenthicCodes")

## 2.3 Main data ----

# Data were manually copied from the xlsx file to a csv file because
# reading xlsx file directly led to changes in percentage cover values

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(.) %>% 
  pivot_longer("AA":"UNK", names_to = "Code", values_to = "measurementValue") %>% 
  select(Location, FilmDate, AnalysisBy, AnalysisDate, Transect, Code, measurementValue) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  filter(Code != "PC") %>% 
  rename(locality = Location, eventDate = FilmDate, recordedBy = AnalysisBy, parentEventID = Transect,
         decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth, organismID = Meaning) %>% 
  select(-AnalysisDate, -Code, -Group, -Category) %>% 
  mutate(datasetID = dataset,
         eventDate = as.Date(eventDate, tryFormats = "%d/%m/%Y"),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Video transect, 10 m transect length") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_code, data_main)
