# 1. Packages ----

library(tidyverse)
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0092" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xls(., sheet = "MASTER") %>% 
  filter(!(row_number() %in% c(1:6))) %>% 
  select("Latitude (N)", "Longitude (W)", "ReefSite", "StartDate (MM/DD/YY)", "SamplingMethod", "MinDepth",
         "PercentTotalCoral", "CCA", "Percent Gorgonian", "Percent Sponges", "TotalMacroalgae Includes Erect Calcareous?",
         "Turf") %>% 
  mutate(across(c("MinDepth",
                  "PercentTotalCoral", "CCA", "Percent Gorgonian", "Percent Sponges", "TotalMacroalgae Includes Erect Calcareous?",
                  "Turf"), ~as.numeric(.))) %>% 
  rename(decimalLatitude = "Latitude (N)", decimalLongitude = "Longitude (W)", locality = "ReefSite",
         eventDate = "StartDate (MM/DD/YY)", samplingProtocol = "SamplingMethod", verbatimDepth = MinDepth) %>% 
  mutate(decimalLatitude = paste0(str_split_fixed(decimalLatitude, " ", 3)[,1], "°",
                                  str_split_fixed(decimalLatitude, " ", 3)[,2], "'",
                                  str_split_fixed(decimalLatitude, " ", 3)[,3]),
         decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = paste0(str_split_fixed(decimalLongitude, " ", 3)[,1], "°",
                                  str_split_fixed(decimalLongitude, " ", 3)[,2], "'",
                                  str_split_fixed(decimalLongitude, " ", 3)[,3]),
         decimalLongitude = -convert_coords(decimalLongitude),
         eventDate = case_when(str_length(eventDate) == 5 ~ as_date(as.numeric(eventDate), origin = "1899-12-30"),
                               str_length(eventDate) == 8 ~ mdy(eventDate))) %>% 
  pivot_longer(7:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = str_replace_all(samplingProtocol,
                                            c("Linear Transect" = "Line intersect transect",
                                              "Point-Intersept Transect" = "Point intersect transect, 10 m transect length, every 10 cm"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_coords)
