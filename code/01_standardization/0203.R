# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0203" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., col_types = "text", na = "NA") %>% 
  select(-Country, -Atoll, -`Tape length(50)`) %>% 
  rename(locality = Location, decimalLatitude = Latitute, decimalLongitude = Longitude,
         verbatimDepth = Depth, samplingProtocol = Method, organismID = Category,
         eventDate = DateTime, year = Year, measurementValue = `HardCoralCover%`) %>% 
  mutate(verbatimDepth = parse_number(verbatimDepth),
         eventDate = case_when(eventDate == "October-Nov 1998" ~ as.Date("1998-10-28"),
                               str_length(eventDate) == 5 ~ as.Date(as.numeric(eventDate), origin = "1899-12-30"),
                               TRUE ~ as.Date(eventDate, tryFormats = "%d-%m-%Y")),
         year = as.numeric(year),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         measurementValue = as.numeric(measurementValue),
         samplingProtocol = case_when(samplingProtocol == "Point Intercept Transect (PIT)" ~ "Point Intercept Transect",
                                      samplingProtocol == "Line Intercept Transect (LIT)" ~ "Line Intercept Transect",
                                      samplingProtocol == "Point Intercept Transect (PIT)/ Reefcheck" ~ "Point Intercept Transect",
                                      samplingProtocol == "Coral Point Count (CPC)/ CoralNet" ~ NA),
         decimalLatitude = str_replace_all(decimalLatitude, "N 05' ", "5°"),
         decimalLatitude = case_when(str_detect(decimalLatitude, "°") == TRUE ~ convert_coords(decimalLatitude),
                                     TRUE ~ as.numeric(decimalLatitude)),
         decimalLongitude = ifelse(decimalLongitude == "N 05' 2007.6", NA, decimalLongitude),
         decimalLongitude = str_replace_all(decimalLongitude, "E 073' ", "73°"),
         decimalLongitude = str_replace_all(decimalLongitude, "E 072' ", "72°"),
         decimalLongitude = case_when(str_detect(decimalLongitude, "°") == TRUE ~ convert_coords(decimalLongitude),
                                      TRUE ~ as.numeric(decimalLongitude)),
         decimalLongitude = ifelse(decimalLongitude > 100 | decimalLongitude < 72.5, NA, decimalLongitude),
         decimalLatitude = ifelse(decimalLatitude < 0 | decimalLatitude > 10, NA, decimalLatitude)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
