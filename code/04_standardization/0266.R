# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0266" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Benthic codes ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  select(-`Functional Group`) %>% 
  rename(organismID = Name) %>% 
  add_row(code = "Un.coral", organismID = "Hard coral")

## 2.2 Perseverance ----

data_perseverance <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv()

metadata_perseverance <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename("Image.name" = Name)

data_perseverance <- left_join(data_perseverance, metadata_perseverance) %>% 
  pivot_longer("Acanth":"Seagrass", names_to = "code", values_to = "measurementValue") %>% 
  rename(eventDate = Date, decimalLatitude = Latitude, locality = SurveySiteName,
         decimalLongitude = Longitude, verbatimDepth = Depth,
         eventID = Image.ID) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
         eventDate, eventID, code, measurementValue) %>% 
  mutate(eventDate = as.Date(eventDate, format = "%d/%m/%Y"))

## 2.3 Beauvallon ----

data_beauvallon <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv()

metadata_beauvallon <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv() %>% 
  rename("Image.name" = Name)

data_beauvallon <- left_join(data_beauvallon, metadata_beauvallon) %>% 
  pivot_longer("Acanth":"Seagrass", names_to = "code", values_to = "measurementValue") %>% 
  rename(eventDate = Date, decimalLatitude = Latitude, locality = SurveySiteName,
         decimalLongitude = Longitude, verbatimDepth = Depth,
         eventID = Image.ID) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
         eventDate, eventID, code, measurementValue) %>% 
  mutate(eventDate = as.Date(eventDate))

## 2.4 Combine both sites ----

bind_rows(data_perseverance, data_beauvallon) %>%
  filter(eventID != "ALL IMAGES") %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset,
         eventID = as.numeric(as.factor(eventID))) %>% 
  left_join(., data_code) %>%
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_beauvallon, metadata_beauvallon, data_perseverance, metadata_perseverance, data_code)
