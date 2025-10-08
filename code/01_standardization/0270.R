# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0270" # Define the dataset_id

# 2. Import, standardize and export the data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

## 2.1 Benthic codes ----

data_code <- read_xlsx(data_path, sheet = "Metadata",
                       range = "B29:C203", col_names = c("code", "organismID")) %>% 
  # Add missing codes
  bind_rows(., tibble(code = c("GORG", "SM", "DJOL"), organismID = c("Gorgoniidae", "Sand-Mud", NA)))

## 2.2 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.,
            sheet = "Overall") %>% 
  rename(`Survey Name` = Name) %>% 
  select(`Survey ID`, `Survey Name`, Latitude, Longitude)

## 2.3 Date data ----

data_date <- read_xlsx(data_path, sheet = "Overall") %>% 
  select(`Survey ID`, `Survey Name`, `Transect ID`,`Surveyor`, `Surveyed`)

## 2.4 List of sheets to combine ----

list_sheets <- tibble(sheet = readxl::excel_sheets(data_path),
                      path = as.character(data_path)) %>% 
  filter(!(sheet %in% c("TermsOfUse", "Metadata", "Overall", "tNDCORAL")))

## 2.5 Create the function ----

convert_data_270 <- function(index_i){
  
  data_i <- read_xlsx(path = as.character(list_sheets[index_i, "path"]),
                      sheet = as.character(list_sheets[index_i, "sheet"])) %>% 
    pivot_longer(5:ncol(.), values_to = "measurementValue", names_to = "code")
  
  return(data_i)
  
}

## 2.6 Map over the function ----

map(1:nrow(list_sheets), ~convert_data_270(.)) %>% 
  list_rbind() %>% 
  filter(!(str_starts(code, "t"))) %>% 
  mutate(measurementValue = measurementValue*100) %>% 
  left_join(., data_code) %>%
  # Remove NA in organismID (all "Newly dead - XXX", and DJOL)
  drop_na(organismID) %>% 
  left_join(., data_site) %>% 
  left_join(., data_date) %>% 
  select(-code) %>% 
  rename(locality = `Survey Name`, parentEventID = `Transect ID`, eventDate = Surveyed,
         recordedBy = Surveyor, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(-`Survey ID`, -`Transect Name`) %>% 
  mutate(eventDate = as.Date(eventDate),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Point intersect transect, 10 m transect length, every 0.1 m") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site, data_date, data_path, list_sheets, convert_data_270)
