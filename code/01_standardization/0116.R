# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0116" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(locality = `Site Name`, verbatimDepth = `Mooring Depth (ft)`) %>% 
  mutate(verbatimDepth = verbatimDepth*0.3048,
         decimalLatitude = str_split_fixed(Coordinates, " ", 2)[,1],
         decimalLatitude = str_replace_all(decimalLatitude, "21°'29.138'N", "21°29.138'N"),
         decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = str_split_fixed(Coordinates, " ", 2)[,2],
         decimalLongitude = convert_coords(decimalLongitude),
         decimalLongitude = -decimalLongitude) %>% 
  select(-Coordinates)

## 2.2 Main data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2, range = "A1:IC134", col_names = FALSE) %>% 
  filter(row_number() %in% c(1:6, 27:134)) %>% 
  t() %>% 
  as_tibble()

colnames(data_main) <- data_main[1,]

data_main <- data_main %>% 
  filter(row_number() != 1) %>% 
  pivot_longer(7:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, year = Year, parentEventID = `TRANSECT NAME`) %>% 
  mutate(measurementValue = as.numeric(as.character(measurementValue)),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 100 m transect length",
         organismID = str_replace_all(organismID, " \\s*\\([^\\)]+\\)", ""),
         month = case_when(Season == "Spring" ~ 4,
                           Season == "Summer" ~ 8,
                           Season == "Fall" ~ 10,
                           TRUE ~ NA),
         locality = str_replace_all(locality, c("Admirals" = "Admiral's Aquarium",
                                                "Dove" = "Dove Cay",
                                                "Shark" = "Shark Alley",
                                                "Shark Shark Alley" = "Shark Alley",
                                                "Tuckers" = "Tucker's Reef",
                                                "Tucker" = "Tucker's Reef"))) %>% 
  drop_na(measurementValue) %>% 
  select(-Date, -Depth, -Season) %>% 
  filter(!(organismID %in% c("TAPE, WAND, SHADOW (TWS)", "Shadow (SHAD)", "Tape (TAPE)", "Wand (WAND)"))) %>% 
  group_by(locality, year, month) %>% 
  mutate(parentEventID = as.numeric(as.factor(parentEventID))) %>% 
  ungroup() %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_main, convert_coords)
