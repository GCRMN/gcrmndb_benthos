# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0073" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List all files ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(path = ., pattern = ".xls", full.names = TRUE)

## 2.2 Create a function to combine the files ----

convert_data_073 <- function(path_i){
  
  data_raw <- read_xlsx(path = path_i, sheet = 1) %>% 
    filter(!(is.na(Date))) %>% 
    pivot_longer(4:(ncol(.)-1), values_to = "measurementValue", names_to = "organismID") %>% 
    mutate(Transect = as.numeric(Transect))
  
  return(data_raw)

}

## 2.3 Combine and export ----

map_dfr(data_site, ~convert_data_073(path_i = .)) %>% 
  select(-Total_cm) %>% 
  rename(locality = Site, eventDate = Date, parentEventID = Transect) %>% 
  # Convert length to percentage cover
  group_by(parentEventID, organismID, locality, eventDate) %>% 
  summarise(measurementValue = sum(measurementValue)) %>% 
  ungroup() %>% 
  group_by(parentEventID, locality, eventDate) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>%
  select(-total) %>% 
  # Add variables
  mutate(datasetID = dataset,
         recordedBy = "David Abrego",
         samplingProtocol = "Line intersect transect, 20 m transect length",
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         # Add metadata from the article 
         # Annual outbreaks of coral disease coincide with extreme seasonal warming
         habitat = case_when(locality %in% c("Saadiyat_Acropora", "Saadiyat_Tiles") ~ "Patch reef",
                             locality %in% c("SirBuNair_North", "SirBuNair_NorthEast") ~ "Fringing reef"),
         decimalLatitude = case_when(locality == "Saadiyat_Acropora" ~ 24.598600,
                                     locality == "Saadiyat_Tiles" ~ 24.599000,
                                     locality == "SirBuNair_North" ~ 25.256600,
                                     locality == "SirBuNair_NorthEast" ~ 25.240000),
         decimalLongitude = case_when(locality == "Saadiyat_Acropora" ~ 54.420100,
                                      locality == "Saadiyat_Tiles" ~ 54.421500,
                                      locality == "SirBuNair_North" ~ 54.209500,
                                      locality == "SirBuNair_NorthEast" ~ 54.194300),
         verbatimDepth = case_when(locality %in% c("Saadiyat_Acropora", "Saadiyat_Tiles") ~ 6.5,
                                   locality %in% c("SirBuNair_North", "SirBuNair_NorthEast") ~ 7)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_data_073)
