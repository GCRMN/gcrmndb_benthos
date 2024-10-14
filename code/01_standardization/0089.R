# 1. Packages ----

library(tidyverse)
library(readxl)
library(sf)

dataset <- "0089" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Montserrat data ----

### 2.1.1 Site data ----

data_site_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(site_id = "Survey ID", locality = "Site Name", verbatimDepth = Depth, eventDate = "Date (A)",
         decimalLatitude = "Northing (A)", decimalLongitude = "Easting (A)") %>% 
  select(site_id, locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate) %>% 
  mutate(site_id = str_remove_all(site_id, "m|-|/"))

### 2.1.2 Main data ----

data_main_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(-"SUBSTRATE ID", -"If RKC is >10% what is the primary cause?", -"Comments") %>% 
  rename(site_id = "Survey ID", parentEventID = Transect, recordedBy = "Data recorded by") %>% 
  pivot_longer(4:ncol(.), values_to = "organismID", names_to = "useless_col") %>% 
  left_join(., data_site_a) %>% 
  select(-site_id, -useless_col) %>% 
  mutate(parentEventID = as.numeric(str_replace_all(parentEventID, c("75-95m" = "4",
                                                                     "50-70m" = "3",
                                                                     "25-45m" = "2",
                                                                     "0-20m" = "1")))) %>% 
  # Convert number of points to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID,
           verbatimDepth, eventDate, recordedBy, organismID) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID,
           verbatimDepth, eventDate, recordedBy) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  mutate(organismID = str_replace_all(organismID, c("NIA" = "Nutrient indicator algae",
                                                    "OT" = "Other fauna",
                                                    "RC" = "Rock",
                                                    "SD" = "Sand",
                                                    "SP" = "Sponge",
                                                    "HC" = "Hard coral",
                                                    "RKC" = "Recently killed coral",
                                                    "SC" = "Soft coral",
                                                    "RB" = "Rubble",
                                                    "SI" = "Silt")),
         samplingProtocol = "Point-Intercept Transect",
         eventDate = as.Date(eventDate),
         decimalLatitude = as.numeric(paste0(str_sub(decimalLatitude, 1, 2), ".", str_sub(decimalLatitude, 3, 6))),
         decimalLongitude = -as.numeric(paste0(str_sub(decimalLongitude, 1, 2), ".", str_sub(decimalLongitude, 3, 6))))

## 2.2 Philippines data (file 1) ----

data_main_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(sheet = "Substrate Composition", skip = 1) %>% 
  select(1:48) %>% 
  filter(row_number() != 1) %>% 
  rename(locality = "...3", parentEventID = "...5", eventDate = "...7",
         decimalLongitude = "...8", decimalLatitude = "...9", verbatimDepth = "...12",
         samplingProtocol = "Comm. Name", year = "...6") %>% 
  select(-"...1", -"...2", -"...4", -"...10", -"...11", -"Lifeform",
         -"...15", -"...26", -"...41", -"Hard Coral...16", -"Other...25") %>% 
  pivot_longer(9:ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  mutate(organismID = str_split_fixed(organismID, "\\.\\.\\.", 2)[,1],
         measurementValue = as.numeric(measurementValue),
         parentEventID = as.numeric(str_replace_all(parentEventID, c("75-95m" = "4",
                                                                     "50-70m" = "3",
                                                                     "25-45m" = "2",
                                                                     "0-20m" = "1"))),
         samplingProtocol = str_remove_all(samplingProtocol, " \\(PIT\\)"),
         eventDate = case_when(str_length(eventDate) != 5 ~ as.Date(eventDate,
                                                                    format = "%d/%m/%Y"),
                               str_length(eventDate) == 5 ~ as.Date(as.numeric(eventDate),
                                                                    origin = "1899-12-30"))) %>% 
  # Convert CRS
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = "EPSG:32651") %>% 
  st_transform(crs = 4326) %>% 
  mutate(decimalLongitude = st_coordinates(.)[,1],
         decimalLatitude = st_coordinates(.)[,2]) %>% 
  st_drop_geometry() %>% 
  select(-samplingProtocol) %>% 
  # Convert number of points to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID,
           verbatimDepth, eventDate) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total)

## 2.3 Philippines data (file 2) ----

data_main_c <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 3) %>% 
  pull() %>% 
  read_xlsx(sheet = "Substrate Composition", skip = 1) %>% 
  select(1:48) %>% 
  filter(row_number() != 1) %>% 
  rename(locality = "...3", parentEventID = "...5", eventDate = "...7",
         decimalLongitude = "...8", decimalLatitude = "...9", verbatimDepth = "...12",
         samplingProtocol = "Comm. Name", year = "...6") %>% 
  select(-"...1", -"...2", -"...4", -"...10", -"...11", -"Lifeform",
         -"...15", -"...26", -"...41", -"Hard Coral...16", -"Other...25") %>% 
  pivot_longer(9:ncol(.), values_to = "measurementValue", names_to = "organismID") %>% 
  mutate(organismID = str_split_fixed(organismID, "\\.\\.\\.", 2)[,1],
         measurementValue = as.numeric(measurementValue),
         parentEventID = as.numeric(str_replace_all(parentEventID, c("75-95m" = "4",
                                                                     "50-70m" = "3",
                                                                     "25-45m" = "2",
                                                                     "0-20m" = "1"))),
         samplingProtocol = str_remove_all(samplingProtocol, " \\(PIT\\)"),
         eventDate = case_when(str_length(eventDate) != 5 ~ as.Date(eventDate,
                                                                    format = "%d/%m/%Y"),
                               str_length(eventDate) == 5 ~ as.Date(as.numeric(eventDate),
                                                                    origin = "1899-12-30"))) %>% 
  # Convert CRS
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = "EPSG:32651") %>% 
  st_transform(crs = 4326) %>% 
  mutate(decimalLongitude = st_coordinates(.)[,1],
         decimalLatitude = st_coordinates(.)[,2]) %>% 
  st_drop_geometry() %>% 
  select(-samplingProtocol) %>% 
  # Convert number of points to percentage cover
  group_by(locality, decimalLatitude, decimalLongitude, parentEventID,
           verbatimDepth, eventDate) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total)

## 2.4 Merge data ----

bind_rows(data_main_a, data_main_b, data_main_c) %>% 
  mutate(datasetID = dataset,
         year = case_when(is.na(year) ~ year(eventDate),
                          TRUE ~ as.numeric(year)),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site_a, data_main_a, data_main_b, data_main_c)
