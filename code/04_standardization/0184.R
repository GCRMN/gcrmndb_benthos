# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(janitor)
source("code/00_functions/convert_coords.R")

dataset <- "0184" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List of sheets to combine ----

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  readxl::excel_sheets()

## 2.2 Create a function to combine the sheets ----

convert_0184 <- function(sheet_i){
  
  metadata_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>%
    filter(row_number() == 1) %>% 
    select(data_path) %>% 
    pull() %>% 
    read_xlsx(path = ., sheet = sheet_i, range = "A1:G6") %>% 
    janitor::remove_empty(.)
  
  data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>%
    filter(row_number() == 1) %>% 
    select(data_path) %>% 
    pull() %>% 
    read_xlsx(path = ., sheet = sheet_i, range = "A8:E18") %>%
    janitor::remove_empty(.) %>% 
    rename(organismID = 1, measurementValue = 2) %>% 
    mutate(locality = as.character(metadata_i[2,2]),
           eventDate = as.character(metadata_i[5,2]),
           decimalLatitude = as.character(metadata_i[3,2]),
           decimalLongitude = as.character(metadata_i[4,2]),
           verbatimDepth = as.character(metadata_i[2,4]),
           samplingProtocol = paste0(as.character(metadata_i[3,4]), ", ", as.character(metadata_i[1,4]), " m"))
  
  return(data_i)
  
}

## 2.3 Map over the function ----

map(list_sheets, ~convert_0184(sheet_i = .)) %>% 
  list_rbind() %>% 
  mutate(organismID = str_split_fixed(organismID, " \\(", 2)[,1],
         organismID = str_to_sentence(organismID),
         eventDate = case_when(eventDate == "1.6.2024" ~ as.Date("2024-06-01"),
                               TRUE ~ as.Date(eventDate, format = "%d.%m.%Y")),
         verbatimDepth = case_when(verbatimDepth == "3 to 5" ~ "4",
                                   verbatimDepth == "4 to 5" ~ "4.5",
                                   verbatimDepth == "10 to 12" ~ "11",
                                   verbatimDepth == "8 to 10" ~ "9",
                                   verbatimDepth == "5 to 6" ~ "5.5",
                                   verbatimDepth == "5 to 7" ~ "6",
                                   verbatimDepth == "3 to 4" ~ "3.5",
                                   verbatimDepth == "7.9m" ~ "8",
                                   verbatimDepth == "9 to 10" ~ "9.5"),
         verbatimDepth = as.numeric(verbatimDepth),
         across(c(decimalLatitude, decimalLongitude), ~str_remove_all(.x, "\"")),
         across(c(decimalLatitude, decimalLongitude), ~str_replace_all(.x, "º", "°")),
         across(c(decimalLatitude, decimalLongitude), ~case_when(str_detect(.x, "°") == TRUE ~ convert_coords(.x),
                                                                 TRUE ~ convert_coords(str_replace_all(.x, " ", "°")))),
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_sheets, convert_0184, convert_coords)
