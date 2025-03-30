# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(zoo)
source("code/00_functions/convert_coords.R")

dataset <- "0194" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data from 2016 to 2019 ----

### 2.1.1 Create a function to convert the data ----

convert_0194 <- function(path_i, sheet_i){
  
  metadata <- read_xlsx(path = path_i, sheet = sheet_i, range = "B3:I9")
  
  metadata <- t(metadata) %>% 
    as_tibble() %>% 
    rename(locality = V1, decimalLatitude = V3, decimalLongitude = V4,
           verbatimDepth = V5, samplingProtocol = V6) %>% 
    select(-V2)
  
  colnames_i <- read_xlsx(path = path_i, sheet = sheet_i, range = "A3:I4")
  
  colnames_i <- as.character(colnames_i)
  
  data <- read_xlsx(path = path_i, sheet = sheet_i, range = "A10:I69", col_names = colnames_i) %>% 
    mutate(year = case_when(str_detect(Site, "[0-9]") == TRUE ~ str_split_fixed(Site, "-", 2)[,2],
                            TRUE ~ NA),
           year = na.locf(year, na.rm = FALSE), .after = Site) %>% 
    filter(!(is.na(Site)) & str_detect(Site, "Total") == FALSE & str_detect(Site, "[0-9]") == FALSE) %>% 
    rename(organismID = Site) %>% 
    pivot_longer(3:ncol(.), names_to = "locality", values_to = "measurementValue") %>% 
    drop_na(measurementValue) %>% 
    mutate(measurementValue = as.numeric(measurementValue)) %>% 
    left_join(., metadata)
  
  return(data)
  
}

### 2.1.2 Convert the data ----

data_a <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0194(path_i = ., sheet_i = 1)

data_b <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0194(path_i = ., sheet_i = 2)

data_c <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0194(path_i = ., sheet_i = 3)

## 2.2 Data from 2020 to 2024 ----

### 2.2.1 Create a function to convert the data ----

convert_0194 <- function(path_i, sheet_i){
  
  metadata <- read_xlsx(path = path_i, sheet = sheet_i, range = "B2:C9")
  
  metadata <- t(metadata) %>% 
    as_tibble() %>% 
    rename(locality = V1, decimalLatitude = V4, decimalLongitude = V5,
           verbatimDepth = V6, samplingProtocol = V7) %>% 
    select(-V2, -V3)
  
  data <- read_xlsx(path = path_i, sheet = sheet_i, range = "A11:C111", col_names = c("Site", "KVT OT2", "KVT OT6")) %>% 
    mutate(year = case_when(str_detect(Site, "Kavaratti") == TRUE ~ Site,
                            TRUE ~ NA),
           year = str_remove_all(year, "Kavaratti Cover"),
           year = na.locf(year, na.rm = FALSE), .after = Site) %>% 
    filter(!(is.na(Site)) & str_detect(Site, "Total") == FALSE & str_detect(Site, "[0-9]") == FALSE) %>% 
    rename(organismID = Site) %>% 
    pivot_longer(3:ncol(.), names_to = "locality", values_to = "measurementValue") %>% 
    drop_na(measurementValue) %>% 
    mutate(measurementValue = as.numeric(measurementValue)) %>% 
    left_join(., metadata)
  
  return(data)
  
}

### 2.2.2 Convert the data ----

data_d <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0194(path_i = ., sheet_i = 1) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~str_replace_all(.x, c("N" = "",
                                                                                 "E" = "",
                                                                                 "″" = "''",
                                                                                 "′" = "'"))),
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)))

## 2.3 Combine data ----

bind_rows(data_a, data_b, data_c) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~str_remove_all(.x, "N |E ")),
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x))) %>% 
  # Convert from area to percentage cover
  group_by(across(c(-measurementValue, -organismID))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  bind_rows(., data_d) %>% 
  mutate(verbatimDepth = as.numeric(str_remove_all(verbatimDepth, " m|m")),
         month = case_when(str_detect(year, "May") == TRUE ~ 5,
                           str_detect(year, "November") == TRUE ~ 11,
                           str_detect(year, "Nov") == TRUE ~ 11,
                           str_detect(year, "Apr") == TRUE ~ 4,
                           str_detect(year, "April") == TRUE ~ 4,
                           str_detect(year, "March") == TRUE ~ 3,
                           str_detect(year, "Dec") == TRUE ~ 12,
                           str_detect(year, "December") == TRUE ~ 5),
         year = parse_number(year),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_0194, convert_coords, data_a, data_b, data_c, data_d)
