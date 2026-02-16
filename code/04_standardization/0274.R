# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0274" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Site Names") %>% 
  rename(locality = SAMPLE_ID, decimalLatitude = LATITUDE, decimalLongitude = LONGITUDE,
         eventDate = DATE, verbatimDepth = DEPTH_M) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         decimalLatitude = case_when(locality %in% c("THBCR0013", "THBCF0013") ~ "125300N", # Replace the "OO" by "00"
                                     TRUE ~ decimalLatitude),
         decimalLatitude = case_when(str_detect(decimalLatitude, "S") == TRUE ~
                                       -as.numeric(str_sub(decimalLatitude, 1, 2)) +
                                       (as.numeric(str_sub(decimalLatitude, 3, 4))/60) +
                                       (as.numeric(str_sub(decimalLatitude, 5, 6))/3600),
                                     str_detect(decimalLatitude, "N") == TRUE ~
                                       as.numeric(str_sub(decimalLatitude, 1, 2)) +
                                       (as.numeric(str_sub(decimalLatitude, 3, 4))/60) +
                                       (as.numeric(str_sub(decimalLatitude, 5, 6))/3600)),
         decimalLongitude = as.numeric(str_sub(decimalLongitude, 1, 3)) +
           (as.numeric(str_sub(decimalLongitude, 4, 5))/60) +
           (as.numeric(str_sub(decimalLongitude, 6, 7))/3600),
         # Correction of wrong site coordinates
         decimalLongitude = case_when(locality == "IDCR00285" ~ 105.2683,
                                     TRUE ~ decimalLongitude),
         decimalLatitude = case_when(locality %in% c("IDCRF0163", "IDCRF0162") ~ -5.604444,
                                     TRUE ~ decimalLatitude))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos") %>% 
  rename(locality = SAMPLE_ID, organismID = BENTHOS, measurementValue = LENGTH) %>% 
  group_by(locality, organismID) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  ungroup() %>% 
  group_by(locality) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total,
         samplingProtocol = paste0("Line intercept transect, ", total/100, " m transect length"),
         datasetID = dataset) %>% 
  select(-total) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
