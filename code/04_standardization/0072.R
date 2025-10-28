# 1. Packages ----

library(tidyverse)
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0072" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data from 2017 - 2018 ----

### 2.1.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  # Read the file
  read_xlsx() %>% 
  # Remove 10 m length transects, keep only 30 m length
  filter(!(is.na(range)))

### 2.1.2 Create a function to combine the sheets ----

convert_data_072 <- function(sheet_i){
  
  data_site_i <- data_site %>% 
    filter(sheet == sheet_i)

  data_raw <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>% 
    select(data_path) %>% 
    filter(row_number() == 1) %>% 
    pull() %>% 
    # Read the file
    read_xlsx(path = ., sheet = sheet_i, range = as.character(data_site_i[1,"range"])) %>% 
    # Remove columns containing more than 80% of NA
    purrr::discard(~sum(is.na(.x))/length(.x)* 100 >= 80)
  
  # Correct issue of negative length value for sheet 7
  # Likely due to I7 and I8 values reversed
  if(sheet_i == 7){
    
    data_raw[2,9] <- 50
    data_raw[3,9] <- 20
    data_raw[4,9] <- 10
  
  }
  
  data_standardized <- bind_rows(data_raw[,1:3], data_raw[,4:6], data_raw[,7:9]) %>% 
    rename(parentEventID = 1, organismID = 2, measurementValue = 3) %>% 
    mutate(parentEventID = ifelse(str_detect(parentEventID, "T") == FALSE, NA_character_, parentEventID),
           parentEventID = zoo::na.locf(parentEventID),
           parentEventID = as.numeric(str_remove_all(parentEventID, "T"))) %>% 
    filter(!(is.na(measurementValue))) %>% 
    # Convert length to percentage cover
    group_by(parentEventID, organismID) %>% 
    summarise(measurementValue = sum(measurementValue)) %>% 
    ungroup() %>% 
    group_by(parentEventID) %>% 
    mutate(total = sum(measurementValue)) %>% 
    ungroup() %>% 
    mutate(measurementValue = (measurementValue*100)/total,
           sheet = sheet_i) %>% 
    left_join(., data_site_i) %>% 
    select(-sheet, -range, -total)
  
  return(data_standardized)
  
}

### 2.1.3 Combine ----

data_2018 <- map_dfr(unique(data_site$sheet), ~convert_data_072(sheet_i = .)) %>% 
  # Corrections based on the Excel spreadsheet headers
  mutate(organismID = str_replace_all(organismID, c("MAC" = "Padina",
                                                    "Macroaglae" = "Macroalgae",
                                                    "CCA" = "Crustose coralline algae",
                                                    "Rock w/ Turf algae" = "Rock with turf algae",
                                                    "Rubble" = "Rubble with turf algae")),
         across(c(decimalLatitude, decimalLongitude), ~as.numeric(.)))

## 2.2 Data from 2022 ----

### 2.2.1 Site data ----

data_site_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull()

data_site <- read_xlsx(path = data_site_path, sheet = 1) %>% 
  rename(locality = Site, eventDate = SurveyDate, verbatimDepth = "Depth (m)") %>% 
  select(locality, eventDate, verbatimDepth)

data_site <- read_xlsx(path = data_site_path, sheet = 2) %>% 
  rename(locality = SiteName, decimalLatitude = Latitude, decimalLongitude = Longitude, habitat = ReefType) %>% 
  select(locality, decimalLatitude, decimalLongitude, habitat) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~str_replace_all(., c("050 58.079" = "050°58.079\'",
                                                                            "050 " = "50 ",
                                                                            "\'" = "\"",
                                                                            " " = "°"))),
         across(c(decimalLatitude, decimalLongitude), ~convert_coords(.))) %>% 
  left_join(., data_site) %>% 
  mutate(locality = ifelse(str_detect(locality, "[0-9]") == TRUE,
                           str_replace_all(locality, " ", "0"),
                           locality),
         eventDate = as.Date(eventDate, tryFormats = c("%d.%m.%Y")))

### 2.2.2 Main data ----

data_2022 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  # Read the file
  read_xlsx() %>% 
  rename(measurementValue = Percentage_Cover, parentEventID = Transect, organismID = Benthos, locality = Site) %>% 
  select(locality, parentEventID, organismID, measurementValue) %>% 
  mutate(parentEventID = as.numeric(str_remove_all(parentEventID, "T")),
         organismID = str_replace_all(organismID, c("HC" = "Hard coral",
                                                    "SC" = "Soft coral",
                                                    "MAC" = "Macroalgae",
                                                    "TA" = "Turf algae",
                                                    "CCA" = "Coralline algae",
                                                    "SD" = "Sand",
                                                    "SP" = "Sponge",
                                                    "RB" = "Rubble",
                                                    "OTH" = "Others"))) %>% 
  left_join(., data_site)

## 2.3 Combine and export ----

bind_rows(data_2018, data_2022) %>% 
  mutate(datasetID = dataset,
         recordedBy = "Reem Al Mealla",
         samplingProtocol = "Line intersect transect, 30 m transect length",
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_site_path, convert_data_072, data_2018, data_2022)
