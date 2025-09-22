# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0112" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1, skip = 1, na = c("", "NA")) %>% 
  rename(decimalLatitude = 5, decimalLongitude = 6, locality = 3,
         verbatimDepth = 7, samplingProtocol = 8, habitat = 4) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, habitat, samplingProtocol) %>% 
  mutate(samplingProtocol = paste0("Photo-quadrat, ",
                                   str_sub(samplingProtocol, 21, 22),
                                   " m transect length, every ",
                                   as.numeric(str_remove_all(str_split_fixed(samplingProtocol,
                                                                             " every ", 2)[,2],
                                                             "[A-z]"))*100, " cm"),
         locality = case_when(locality == "East Koks Island (SB205)" ~ "East Koks Is (SB205)",
                              locality == "Sandy Point Reef (SPT)" ~ "Sandy Point (SPT)",
                              locality == "12-Shelf Slope east of Black Rock" ~ "12-Shelf Slope East of Black Rock",
                              locality == "18-Southern Lowendal Shelf" ~ "18-South Lowendal Shelf",
                              locality == "2-Pitt Point, Trimouille Island" ~ "2-Pitt Pt Trimouille Is",
                              locality == "Gnarraloo Bay" ~ "Gnaraloo Bay",
                              TRUE ~ locality))

## 2.2 Main data ----

### 2.2.1 List of sheets to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

data_sheets <- readxl::excel_sheets(path = data_path)

### 2.2.2 Combine data from sheets ----

map(data_sheets, ~read_xlsx(path = data_path, sheet = .x, col_types = "text", na = c("NA", "na", ""))) %>% 
  list_rbind() %>% 
  rename(eventDate = Date, organismID = Genus, measurementValue = Percent_cover,
         parentEventID = Replicate, eventID = ImageName, locality = Site) %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         eventDate = case_when(str_detect(eventDate, "/") == TRUE ~ as.Date(eventDate, format = "%m/%d/%Y"),
                               TRUE ~ as.Date(as.numeric(eventDate), origin = "1899-12-30")),
         year = case_when(is.na(eventDate) == TRUE ~ as.numeric(Year),
                          TRUE ~ year(eventDate)),
         organismID = case_when(organismID == "Turbinaria spp." ~ paste0(Type, " - ", organismID),
                                TRUE ~ organismID),
         parentEventID = case_when(parentEventID == "T1" ~ "1",
                                   parentEventID == "T2" ~ "2",
                                   parentEventID == "T3" ~ "3",
                                   parentEventID == "T4" ~ "4",
                                   parentEventID == "Transect 1" ~ "1",
                                   parentEventID == "Transect 2" ~ "2",
                                   parentEventID == "Transect 3" ~ "3",
                                   parentEventID == "Transect 4" ~ "4",
                                   parentEventID == "Transect 5" ~ "5",
                                   str_detect(parentEventID, "_") == TRUE ~ str_split_fixed(parentEventID, "_", 2)[,2],
                                   TRUE ~ parentEventID)) %>% 
  # Convert parentEventID to numeric
  group_by(locality, eventDate, year) %>% 
  mutate(parentEventID = as.numeric(as.factor(parentEventID))) %>% 
  ungroup() %>% 
  # Convert eventID to numeric
  group_by(locality, parentEventID, eventDate, year) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  select(locality, parentEventID, eventID, year, eventDate, organismID, measurementValue) %>%
  mutate(month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_path, data_sheets)
