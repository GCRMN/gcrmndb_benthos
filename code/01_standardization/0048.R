# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0048" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Sheet 1 ----

data_sheet_1 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 1, na = c("", "NA")) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, parentEventID = Transect, year = Year,
         month = Month, day = Day, samplingProtocol = Method,
         measurementValue = Cover, organismID = Substrate) %>% 
  select(-11, -12) %>% 
  mutate(eventDate = if_else(!is.na(year) & !is.na(month) & !is.na(day),
                             paste(year, str_pad(month, 2, pad = "0"), str_pad(day, 2, pad = "0"), sep = "-"),
                             NA),
         measurementValue = measurementValue*100,
         samplingProtocol = case_when(samplingProtocol == "LIT.10m" ~ 
                                        "Line intersect transect, 10 m transect length",
                                      samplingProtocol == "PIT.10m" ~ 
                                        "Point intersect transect, 10 m transect length, every 20 cm"))

## 2.2 Sheet 2 ----

data_sheet_2 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 2, na = c("", "NA")) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, parentEventID = Transect, eventDate = Date,
         samplingProtocol = Method, organismID = Substrate, n = "n/Transect") %>% 
  select(-9, -10) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         eventDate = as.character(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 20 cm") %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~ as.numeric(str_replace(str_remove(.x, "\\."), "°", "\\.")))) %>% 
  drop_na(decimalLatitude) %>% 
  group_by(decimalLatitude, decimalLongitude, parentEventID, verbatimDepth, eventDate) %>% 
  mutate(total = sum(n)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total) %>% 
  select(-n, -total) %>% 
  group_by_all() %>% 
  summarise(measurementValue = sum(measurementValue))
  
## 2.3 Sheet 3 ----

data_sheet_3 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 3, na = c("", "NA")) %>% 
  select(-8, -9) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude,
         verbatimDepth = Depth, parentEventID = Transect, eventDate = Date,
         samplingProtocol = Method, organismID = Substrate) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~ as.numeric(str_replace(str_remove(.x, "\\."), "°", "\\.")))) %>% 
  drop_na(decimalLatitude) %>% 
  group_by(decimalLatitude, decimalLongitude, parentEventID, verbatimDepth, eventDate) %>% 
  mutate(total = n()) %>% 
  ungroup() %>% 
  group_by_all() %>% 
  count() %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total) %>% 
  select(-n, -total) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         eventDate = as.character(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 20 cm")

## 2.4 Bind the data and export the file ----

bind_rows(data_sheet_1, data_sheet_2) %>% 
  bind_rows(., data_sheet_3) %>% 
  mutate(datasetID = dataset,
         organismID = str_replace_all(organismID, c("ACE" = "Calcareous encruting algae",
                                                    "MA" = "Macroalgae",
                                                    "S&D" = "Sand and rubble",
                                                    "ACE&T&D" = "Calcareous encruting algae, turf, and rubble",
                                                    "ACE&D" = "Calcareous encruting algae and rubble",
                                                    "CA" = "Coralline algae"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_sheet_1, data_sheet_2, data_sheet_3)
