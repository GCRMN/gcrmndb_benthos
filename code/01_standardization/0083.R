# 1. Packages ----

library(tidyverse)
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0083" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., range = "B3:G11") %>% 
  rename(locality = Stations, decimalLongitude = X, decimalLatitude = Y, verbatimDepth = Profondeur) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(verbatimDepth = as.numeric(str_remove_all(verbatimDepth, "m")),
         decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = -convert_coords(decimalLongitude),
         locality = case_when(locality == "Rocher Pélican" ~ "Rocher Pelican",
                              locality == "Rocher créole" ~ "Rocher creole",
                              TRUE ~ locality))

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2()

## 2.3 List of files and path to combine ----

### 2.3.1 List of paths ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE) %>% 
  as_tibble_col(column_name = "path") %>% 
  filter(str_detect(path, "Récapitulatif|code") == FALSE) %>% 
  mutate(path_id = row_number())

### 2.3.2 List of sheets ----

data_paths <- tibble(x = map(data_paths$path, ~excel_sheets(as.character(.)))) %>% 
  mutate(path_id = row_number()) %>% 
  unnest() %>% 
  rename(sheet = x) %>% 
  filter(sheet != "Info") %>% 
  left_join(., data_paths) %>% 
  select(-path_id)

## 2.4 Create a function to standardize data ----

convert_data_083 <- function(index_i){
  
  data_paths_i <- data_paths %>% 
    filter(row_number() == index_i)
  
  data_i <- read_xlsx(path = as.character(data_paths_i$path),
                      sheet = as.character(data_paths_i$sheet),
                      range = "A14:X39")
  
  data_date_i <- read_xlsx(path = as.character(data_paths_i$path),
                           sheet = as.character(data_paths_i$sheet),
                           range = "K2",
                           col_names = "date") %>% 
    mutate(date = as.character(date)) %>% 
    pull(date)
  
  data_i <- tibble(distance =  c(data_i[1], data_i[3], data_i[5], data_i[7], data_i[9], data_i[11],
                                 data_i[13], data_i[15], data_i[17], data_i[19], data_i[21], data_i[23]),
                   code = c(data_i[2], data_i[4], data_i[6], data_i[8], data_i[10], data_i[12],
                            data_i[14], data_i[16], data_i[18], data_i[20], data_i[22], data_i[24])) %>% 
    unnest() %>% 
    mutate(parentEventID = c(rep(1, 50), rep(2, 50), rep(3, 50), rep(4, 50), rep(5, 50), rep(6, 50)),
           path = as.character(data_paths_i$path),
           sheet = as.character(data_paths_i$sheet),
           date = data_date_i)
  
  return(data_i)
  
}
  
### 2.5 Map over the function ----

B <- map_dfr(1:nrow(data_paths), ~convert_data_083(index_i = .)) %>% 
  # Transform points to percentage cover
  group_by(date, path, code, parentEventID) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(date, path, parentEventID) %>% 
  mutate(measurementValue = measurementValue*100/sum(measurementValue)) %>% 
  ungroup() %>% 
  # Transform the data
  mutate(datasetID = dataset,
         date = case_when(str_length(date) == 8 ~ as.Date(date, tryFormats = "%d/%m/%y"),
                                 str_length(date) == 10 & str_detect(date, "/") == TRUE ~ 
                            as.Date(date, tryFormats = "%d/%m/%Y"),
                                 str_length(date) == 10 & str_detect(date, "-") == TRUE ~
                            as_date(date),
                                 TRUE ~ NA),
         year = year(date),
         month = month(date),
         day = day(date),
         locality = str_remove_all(path, "data/01_raw-data/0083/Benthos_"),
         locality = str_remove_all(locality, ".xlsx"),
         locality = case_when(locality == "Basse_espagnole" ~ "Basse espagnole",
                              locality == "Caye_verte" ~ "Caye verte",
                              locality == "chicot" ~ "Chico",
                              locality == "Fish_point" ~ "Fish pot",
                              locality == "Galion" ~ "Galion",
                              locality == "Ilet_Pinel" ~ "Ilet Pinel",
                              locality == "Rocher_creole" ~ "Rocher creole",
                              locality == "Rocher_pélican" ~ "Rocher Pelican"),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 20 cm") %>% 
  select(-path) %>% 
  rename(eventDate = date) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-code)

# 3. Remove useless objects ----

rm(data_site, data_paths, data_code, convert_data_083)
