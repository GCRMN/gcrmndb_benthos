# 1. Packages ----

library(tidyverse)

dataset <- "0097" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv(., fileEncoding = "Latin1") %>% 
  rename(locality = SiteCode, parentEventID = StationID,
         decimalLatitude = latDD, decimalLongitude = lonDD,
         verbatimDepth = offshoreDepth.ft.) %>% 
  select(locality, parentEventID, decimalLatitude, decimalLongitude,
         verbatimDepth)

## 2.2 Main data A (taxa groups) ----

data_main_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(organismID = "Taxa")

## 2.3 Main data B (stony corals) ----

data_main_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  read.csv() %>% 
  rename(organismID = "SCOR_SPP")

## 2.4 Merge data ----

bind_rows(data_main_a, data_main_b) %>% 
  filter(organismID != "StonyCoral") %>% 
  rename(eventDate = ImageDate, locality = SiteCode, parentEventID = StationID,
         eventID = points, measurementValue = PercentCover) %>% 
  select(eventDate, locality, parentEventID, eventID, organismID, measurementValue) %>% 
  drop_na(measurementValue) %>% 
  left_join(., data_site) %>% 
  mutate(measurementValue = measurementValue*100,
         eventDate = as.Date(eventDate, tryFormats = "%m/%d/%Y"),
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = verbatimDepth*0.3048,
         samplingProtocol = case_when(year >= 2011 ~ "Photo-quadrat, 22 m transect length",
                                      TRUE ~ "Video transect, 22 m transect length"),
         parentEventID = as.numeric(str_sub(parentEventID, -1, -1))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_main_a, data_main_b)
