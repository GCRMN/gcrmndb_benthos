# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0165" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(code = str_squish(code))

## 2.2 List of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., pattern = ".xlsx", full.names = TRUE)

## 2.3 Create a function to convert the data ----

convert_0165 <- function(path_i){
  
  data <- readxl::read_xlsx(path = path_i, sheet = "Benthos") %>% 
    select(!contains("Algal")) %>% 
    pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "code") %>% 
    select(-Point) %>% 
    mutate(parentEventID = parse_number(parentEventID),
           locality = str_split_fixed(path_i, "/|_", 8)[,5])
  
  if(unique(data$locality) %in% c("TC1", "TC2", "TC3", "TC4", "TC5", "TC6", "TC7", "TC8")){
    
    data_date <- readxl::read_xlsx(path = path_i, sheet = 1, range = "B5:C6", col_names = FALSE)

  }else{
    
    data_date <- readxl::read_xlsx(path = path_i, sheet = 1, range = "B4:C5", col_names = FALSE)
    
  }

  data <- data %>% 
    mutate(decimalLatitude = as.numeric(data_date[1,1]),
           decimalLongitude = as.numeric(data_date[1,2]),
           eventDate = as.character(data_date[2,1]),
           eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-31"))
  
  return(data)
  
}

## 2.4 Combine the sheets ----

map_dfr(list_files, ~convert_0165(path_i = .)) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, eventDate, parentEventID, code) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  left_join(., data_code) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  select(-code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_files, convert_0165, data_code)
