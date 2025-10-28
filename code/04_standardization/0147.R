# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0147" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(.x)))

## 2.2 Main data ----

### 2.2.1 List of files to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, pattern = "xlsx")

### 2.2.2 Create a function to combine the files ----

convert_0147 <- function(path){
  
  data_results <- read_xlsx(path, sheet = "To Master",
                            range = "A1:F113", col_names = FALSE)
  
  data_results <- t(data_results)
  
  data_results <- as_tibble(data_results)
  
  colnames(data_results) <- data_results[1,]
  
  data_results <- data_results %>% 
    filter(row_number() != 1)
  
  return(data_results)
  
}

### 2.2.3 Map over the function ----

map(data_path, ~convert_0147(path = .x)) %>% 
  list_rbind() %>% 
  pivot_longer("Acropora cervicornis (AC) - coral":ncol(.),
               names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = "Location:", parentEventID = "Transect Number:",
         eventDate = "Date of Filming:", verbatimDepth = "Depth (m)") %>% 
  select(locality, parentEventID, eventDate, verbatimDepth, organismID, measurementValue) %>% 
  mutate(across(c(parentEventID, eventDate, verbatimDepth, measurementValue), ~as.numeric(.x)),
         samplingProtocol = "Video transect, 15 m transect length",
         organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID),
         organismID = str_remove_all(organismID,
                                     " - coral| - maca| -other| - spo| - go| - dca| - zo| - calg"),
         eventDate = as.Date(eventDate, origin = "1899-12-30"),
         year = year(eventDate),
         year = case_when(year == 2014 ~ 2024,
                          TRUE ~ year),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  left_join(., data_site) %>%
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_path, convert_0147)
