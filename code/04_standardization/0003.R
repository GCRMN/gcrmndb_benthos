# 1. Required packages ----

library(tidyverse) # Core tidyverse packages

dataset <- "0003" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull()

load(data_path)

## 2.2 Date data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "date") %>% 
  select(data_path) %>% 
  pull()

load(data_path)

## 2.3 Main data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

load(data_path)

points.zero %>% 
  mutate(organismID = paste0(gcrmn_group, " - ", COMP_2021_DESCRIPTION)) %>% 
  select(-BENTHOS_CODE, -GROUP_CODE, -gcrmn_group, -COMP_2021_DESCRIPTION, -VIDEO_CODE) %>% 
  # Convert from number of points to percentage cover
  group_by(across(c(-n.points))) %>% 
  summarise(n.points = sum(n.points)) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -n.points))) %>% 
  mutate(measurementValue = n.points*100/sum(n.points)) %>% 
  ungroup() %>% 
  select(-n.points) %>% 
  # Join to add lat and long
  mutate(SITE_NO = as.character(SITE_NO)) %>% 
  left_join(., Sites) %>% 
  left_join(., Samples) %>%
  # Misc changes
  rename(decimalLatitude = LAT_DD, decimalLongitude = LONG_DD,
         eventDate = SAMPLE_DATE, verbatimDepth = DEPTH, parentEventID = TRANSECT_NO) %>% 
  mutate(locality = paste0(REEF, " - ", SITE_NO),
         eventDate = as.Date(eventDate, tryFormats = "%d/%m/%Y"),
         year = case_when(is.na(eventDate) ~ Year,
                          !(is.na(eventDate)) ~ year(eventDate)),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Video transect") %>% 
  select(-Year, -VISIT_NO, -REEF, -SITE_NO, -P_CODE) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(Sites, Samples, points.zero, data_path)
