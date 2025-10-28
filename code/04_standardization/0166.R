# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0166" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Benthic codes ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(code = Code, organismID = Equivalence) %>% 
  distinct()

## 2.2 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(-4) %>% 
  rename(path = "File name (.xls)", locality = "Site", eventDate = 2,
         decimalLatitude = "Latitude", decimalLongitude = "Longitude") %>% 
  mutate(eventDate = case_when(eventDate == "00/02/16" ~ as.Date("2016-02-20"),
                               str_detect(eventDate, "/") == TRUE ~ as.Date(eventDate, format = "%d/%m/%y"),
                               TRUE ~ as.Date(as.numeric(eventDate), origin = "1899-12-31")))

## 2.3 List of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., full.names = TRUE) %>% 
  tibble(path = .) %>% 
  filter(str_detect(path, "AGRRA|coordinates") == FALSE)

## 2.4 Create a function to combine the files ----

convert_0166 <- function(path){
  
  if(str_split_fixed(path, "\\.", 2)[,2] == "xls"){
    
    data <- readxl::read_xls(path = path, sheet = 1, col_names = FALSE) %>% 
      filter(str_detect(`...1`, " cm")) %>% 
      select(3:12) %>% 
      mutate(parentEventID = rep(1:(nrow(.)/10), each = 10)) %>% 
      pivot_longer(1:10, names_to = "remove", values_to = "code") %>% 
      select(-remove) %>% 
      # Convert from number of points to percentage cover
      group_by(pick(everything())) %>% 
      summarise(measurementValue = n()) %>% 
      ungroup() %>% 
      group_by(across(c(-code, -measurementValue))) %>% 
      mutate(total = sum(measurementValue)) %>% 
      ungroup() %>% 
      mutate(measurementValue = (measurementValue*100)/total) %>% 
      select(-total) %>% 
      mutate(path = path)
    
  }else if(str_split_fixed(path, "\\.", 2)[,2] == "xlsx"){
    
    data <- readxl::read_xlsx(path = path, sheet = 1, col_names = FALSE) %>% 
      filter(str_detect(`...1`, " cm")) %>% 
      select(3:12) %>% 
      mutate(parentEventID = rep(1:(nrow(.)/10), each = 10)) %>% 
      pivot_longer(1:10, names_to = "remove", values_to = "code") %>% 
      select(-remove) %>% 
      # Convert from number of points to percentage cover
      group_by(pick(everything())) %>% 
      summarise(measurementValue = n()) %>% 
      ungroup() %>% 
      group_by(across(c(-code, -measurementValue))) %>% 
      mutate(total = sum(measurementValue)) %>% 
      ungroup() %>% 
      mutate(measurementValue = (measurementValue*100)/total) %>% 
      select(-total) %>% 
      mutate(path = path)
    
  }
  
  return(data)
  
}

## 2.5 Map over the function ----

map_dfr(list_files$path, ~convert_0166(path = .)) %>% 
  mutate(path = str_remove_all(path, ".xlsx"),
         path = str_remove_all(path, "data/01_raw-data/0166/|.xls")) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-path, -code) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_files, data_site, data_code, convert_0166)
