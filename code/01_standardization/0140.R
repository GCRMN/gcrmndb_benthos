# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0140" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Benthic codes ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .)

## 2.2 List of range to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = .)

## 2.3 Create a function to combine the ranges ----

combine_0140 <- function(i){
  
  data <- read_xlsx(path = as.character(data_path[i, "file_path"]),
                    range = as.character(data_path[i, "range"]),
                    sheet = 1, col_names = FALSE)
  
  data <- tibble(measurementValue = data %>% select(seq(1, 16, by = 2)) %>% c() %>% unlist() %>% as_vector(),
                 code = data %>% select(seq(2, 17, by = 2)) %>% c() %>% unlist() %>% as_vector()) %>% 
    mutate(range = as.character(data_path[i, "range"]),
           file_path = as.character(data_path[i, "file_path"])) %>% 
    left_join(., data_path, by = c("file_path", "range"))
  
  return(data)
  
}

## 2.4 Map over the function ----

map_dfr(1:nrow(data_path), ~combine_0140(i = .)) %>% 
  drop_na(code) %>% 
  mutate(parentEventID = case_when(measurementValue >= 0 & measurementValue <= 19.5 ~ 1,
                                   measurementValue >= 25 & measurementValue <= 44.5 ~ 2,
                                   measurementValue >= 50 & measurementValue <= 69.5 ~ 3,
                                   measurementValue >= 75 & measurementValue <= 94.5 ~ 4,
                                   TRUE ~ NA),
           code = str_replace_all(code, "NIC", "NIA")) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID, eventDate, code) %>% 
  count() %>% 
  ungroup() %>% 
  # Generate 0 values
  tidyr::complete(code, nesting(locality, parentEventID, eventDate,
                                decimalLatitude, decimalLongitude, verbatimDepth),
                  fill = list(n = 0)) %>% 
  group_by(locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID, eventDate) %>% 
  mutate(total = sum(n)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total,
         datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 50 cm") %>% 
  left_join(., data_code) %>% 
  select(-n, -total, -code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_path, combine_0140)
