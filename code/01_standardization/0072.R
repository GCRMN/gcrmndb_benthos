# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0072" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx() %>% 
  # Remove 10 m length transects, keep only 30 m length
  filter(!(is.na(range)))

## 2.2 Create a function to combine the sheets ----

convert_data_072 <- function(sheet_i){
  
  data_site_i <- data_site %>% 
    filter(sheet == sheet_i)

  data_raw <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>% 
    select(data_path) %>% 
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

## 2.3 Combine and export ----

map_dfr(unique(data_site$sheet), ~convert_data_072(sheet_i = .)) %>% 
  mutate(datasetID = dataset,
         recordedBy = "Reem Al Mealla",
         samplingProtocol = "Line intersect transect, 30 m transect length",
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         # Corrections based on the Excel spreadsheet headers
         organismID = str_replace_all(organismID, c("MAC" = "Padina",
                                                    "Macroaglae" = "Macroalgae",
                                                    "CCA" = "Crustose coralline algae",
                                                    "Rock w/ Turf algae" = "Rock with turf algae",
                                                    "Rubble" = "Rubble with turf algae"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_data_072)
