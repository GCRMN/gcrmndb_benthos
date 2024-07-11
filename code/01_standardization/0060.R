# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0060" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(path = ., sheet = 1, range = "A4:B9") %>% 
  rename(locality = Name) %>% 
  mutate(decimalLatitude = as.numeric(str_split_fixed(Coordinates, ", ", 2)[,1]),
         decimalLongitude = as.numeric(str_split_fixed(Coordinates, ", ", 2)[,2]),
         locality = str_replace_all(locality, c("Bouy Line" = "Buoy Line",
                                                "Casablanca" = "Casa Blanca"))) %>% 
  select(-Coordinates) %>% 
  mutate(decimalLatitude = ifelse(locality == "Grandmas Garden", 9.32424, decimalLatitude),
         decimalLongitude = ifelse(locality == "Grandmas Garden", -82.21962, decimalLongitude))

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read.csv(file = .)

## 2.3 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = "Substrate composition 2024", col_types = "text") %>% 
  drop_na("Dive site") %>% 
  rename(eventDate = Date, locality = "Dive site",
       depth_start = "Depth (Start)", depth_end = "Depth (End)") %>% 
  mutate(across(c(depth_start, depth_end), ~str_replace_all(., "-", NA_character_))) %>% 
  mutate(across(c(depth_start, depth_end), ~as.numeric(str_replace_all(., ",", ".")))) %>% 
  mutate(verbatimDepth = case_when(is.na(depth_start) ~ depth_end,
                                   is.na(depth_end) ~ depth_start,
                                   TRUE ~ (depth_start + depth_end)/2),
         locality = str_replace_all(locality, c("Casablanca" = "Casa Blanca",
                                                "Buoy line" = "Buoy Line"))) %>% 
  left_join(., data_site) %>% 
  select(-Bearing, -Direction, -SD, -depth_start, -depth_end, -"Temperature (C°)", -"AB total",
         -"AL total", -"SP total", -"CO total", -"Others total", -"Notes",
         -"Total Data Points", -Surveyor) %>% 
  pivot_longer(SI:UNKNOWN, values_to = "measurementValue", names_to = "code") %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         measurementValue = replace_na(measurementValue, 0),
         eventDate = str_replace_all(eventDate, c("02/02/0224" = "2024-02-02",
                                                  "19.06.24" = "2024-06-19",
                                                  "20.06.2024" = "2024-06-20",
                                                  "21.06.2024" = "2024-06-21",
                                                  "24.06.2024" = "2024-06-24",
                                                  "25.06.2024" = "2024-06-25",
                                                  "26.06.2024" = "2024-06-26",
                                                  "27.06.2024" = "2024-06-27",
                                                  "28.06.2024" = "2024-06-28")),
         eventDate = case_when(str_length(eventDate) == 5 ~ as.Date(as.numeric(eventDate), origin = "1899-12-30"),
                               TRUE ~ as_date(eventDate))) %>% 
  left_join(., data_code) %>% 
  group_by(locality, eventDate, verbatimDepth, decimalLatitude, decimalLongitude) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         measurementValue = (measurementValue*100)/total,
         samplingProtocol = "Point intersect transect, 30 m transect length, every 25 cm") %>% 
  select(-code, -total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site)
