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
                                                             "[A-z]"))*100, " cm"))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  rename(eventDate = Date, organismID = Genus, measurementValue = Percent_cover,
         parentEventID = Replicate, eventID = ImageName, locality = Site) %>% 
  mutate(organismID = case_when(organismID == "Turbinaria spp." ~ paste0(Type, " - ", organismID),
                                TRUE ~ organismID)) %>% 
  select(locality, parentEventID, eventID, eventDate, organismID, measurementValue) %>%
  # Convert photo-quadrat ID to numeric
  group_by(locality, parentEventID, eventDate) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(parentEventID = as.numeric(str_remove_all(parentEventID, "Transect ")),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
