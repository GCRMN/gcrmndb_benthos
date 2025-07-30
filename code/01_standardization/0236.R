# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(zoo)

dataset <- "0236" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(.x)))

## 2.2 Create a function to standardize the sheets ----

convert_data_238 <- function(sheet_i){
  
  # Load the data
  
  data <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>%
    select(data_path) %>% 
    pull() %>% 
    read_xlsx(path = ., sheet = sheet_i, skip = 2, na = c("NA", "", "Missing")) %>% 
    mutate(across(c(Latitude, Longitude, Date),  ~na.locf(.))) %>% 
    rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
           verbatimDepth = `Depth (m)`, eventDate = Date, parentEventID = `Distance Along Transect (m)`) %>% 
    mutate(add_notes_perc = str_split_fixed(`Additional notes`, "%", 2)[,1],
           add_notes_organism = str_trim(str_split_fixed(`Additional notes`, "%", 2)[,2]))
  
  if(sheet_i == "2017"){
    
    data <- data %>% 
      select(-Direction, -`End Latitude`, -`End Longitude`, -`Visibility`,
             -`Total % Hard Coral Cover`, -`Additional notes`) %>% 
      mutate(across(c(`Sand %`, `Bare Substract`, `Turf Algae`), ~as.numeric(.x)))
    
  }else if(sheet_i == "2024"){
    
    data <- data %>% 
      rename("Turf Algae" = "Algae Cover") %>% 
      select(-Direction, -`End Latitude`, -`End Longitude`, -`Visibility`,
             -`Total % Hard Coral Cover`, -`Total % Soft Coral Cover`, -`Additional notes`) %>% 
      mutate(across(c(`Sand %`, `Bare Substract`, `Turf Algae`), ~as.numeric(.x)))
    
  }else{
    
    data <- data %>% 
      select(-Direction, -`End Latitude`, -`End Longitude`, -`Visibility`,
             -`Total % Hard Coral Cover`, -`Total % Soft Coral Cover`, -`Additional notes`) %>% 
      mutate(across(c(`Sand %`, `Bare Substract`, `Turf Algae`), ~as.numeric(.x)))
    
  }
  
  # Extract data for hard coral and soft coral columns
    
  data_a <- data %>% 
    select(-`Sand %`, -`Bare Substract`, -`Turf Algae`, -add_notes_perc, -add_notes_organism) %>% 
    rename_at(vars(matches("pecies")), ~paste0("species_", seq_along(.))) %>% 
    rename_at(vars(matches("over")), ~paste0("cover_", seq_along(.))) %>% 
    mutate(across(starts_with("cover_"), ~as.numeric(.x)))
  
  data_a <- data_a %>% 
    pivot_longer(cols = starts_with("species_"), names_to = "species_col", values_to = "organismID") %>%
    bind_cols(., data_a %>%
                pivot_longer(cols = starts_with("cover_"),
                             names_to = "cover_col", values_to = "measurementValue") %>%
                select(measurementValue)) %>%
    select(-species_col) %>% 
    select(-starts_with("cover_")) %>% 
    drop_na(measurementValue)
  
  # Extract data for bare, algae, and sand
  
  data_b <- data %>% 
    select(locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate, parentEventID,
           `Sand %`, `Bare Substract`, `Turf Algae`) %>% 
    pivot_longer(7:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    drop_na(measurementValue)
  
  # Extract data for notes
  
  data_c <- data %>% 
    select(locality, decimalLatitude, decimalLongitude, verbatimDepth, eventDate, parentEventID,
           add_notes_perc, add_notes_organism) %>% 
    drop_na(add_notes_perc) %>% 
    rename(organismID = add_notes_organism, measurementValue = add_notes_perc) %>% 
    mutate(measurementValue = as.numeric(measurementValue))
  
  # Combine data and return result
  
  data <- bind_rows(data_a, data_b, data_c) %>% 
    arrange(locality, eventDate, parentEventID) %>% 
    mutate(organismID = gsub("[[:punct:]]", "", organismID),
           verbatimDepth = as.numeric(verbatimDepth),
           eventDate = as.character(eventDate))
  
  return(data)
  
}

## 2.3 Map over the function ----

map(c("2017", "2018", "2019", "2021", "2022", "2023", "2024"), ~convert_data_238(sheet_i = .x)) %>% 
  list_rbind() %>% 
  # Replace by NA
  mutate(across(1:ncol(.), ~case_when(.x %in% c("N/A", "NA", "") ~ NA,
                                      TRUE ~ .x)),
         eventDate = case_when(str_length(eventDate) == 5 ~ as.Date(eventDate, origin = "1899-12-30"),
                               TRUE ~ as.Date(eventDate)),
         organismID = ifelse(str_detect(organismID, "[1-9]") == TRUE, NA, organismID),
         organismID = str_replace_all(organismID, " sp", ""),
         organismID = case_when(organismID == "Turf Algae" ~ "Algae",
                                TRUE ~ organismID)) %>% 
  # Add latitude and longitude
  select(-decimalLatitude, -decimalLongitude) %>% 
  mutate(locality = case_when(locality == "Batifish" ~ "Batfish",
                              locality == "Playgrounds" ~ "Caves",
                              locality == "Devi;" ~ "Devils",
                              locality == "Devil" ~ "Devils",
                              TRUE ~ locality)) %>% 
  left_join(., data_site) %>%  
  # Additional variables 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 25 m transect length, every 2.5 m") %>% 
  drop_na(measurementValue) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
