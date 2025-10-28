# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0267" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(locality = Site, decimalLatitude = latitude, decimalLongitude = longitude) %>% 
  mutate(locality = case_when(locality == "Sandy island" ~ "Sandy Island",
                              locality == "Limestone" ~ "Limestone Bay",
                              locality == "Shoal Bay" ~ "Shoal Bay East",
                              locality == "Forest Reef" ~ "Forest Bay",
                              locality == "Scrub" ~ "Scrub Island",
                              TRUE ~ locality))

## 2.2 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "Complete") == TRUE)

## 2.3 Function to combine the files ----

convert_data_267 <- function(path_i){

  data <- read_xlsx(path = path_i, sheet = "Reef Habitat") %>% 
    rename("eventID" = 1, "verbatimDepth" = 2, "sand" = 9, "turf sediment" = 10,
           "turf bare" = 11, "coralline algae" = 12, "calcareous algae" = 13,
           "fleshy algae" = 15, "other algae" = 17, "cyanobacteria" = 19,
           "hard coral" = 21, "soft coral" = 24, "fire coral" = 28, "sponges" = 30,
           "diadema antillarum" = 33, "zoanthid" = 36, "other invertebrates" = 39) %>% 
    select(1,2,9,10,11,12,13,15,17,19,21,24,28,30,33,36,39) %>% 
    filter(!(row_number() %in% c(1,2,3))) %>% 
    mutate(eventDate = case_when(lag(eventID, 2) == "Date" ~ lag(eventID, 1),
                                 TRUE ~ NA),
           eventID = case_when(eventID %in% seq(0,50,5) ~ eventID,
                               TRUE ~ NA)) %>% 
    drop_na(eventID) %>% 
    mutate(eventDate = zoo::na.locf(eventDate, na.rm = TRUE)) %>% 
    pivot_longer(3:17, names_to = "organismID", values_to = "measurementValue") %>% 
    mutate(across(c("eventID", "eventDate", "verbatimDepth", "measurementValue"), ~as.numeric(.)),
           measurementValue = measurementValue*100,
           eventDate = as.Date(eventDate, origin = "1899-12-30"),
           path = path_i) %>% 
    drop_na(measurementValue)
  
  return(data)
  
}

## 2.4 Map over the function ----

map(list_files$value, ~convert_data_267(path_i = .x)) %>% 
  list_rbind() %>% 
  mutate(locality = str_split_fixed(path, "/|Reef AMMP Data", 8)[,4],
         locality = str_split_fixed(locality, " ", 2)[,2],
         locality = str_squish(locality)) %>% 
  select(-path) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, list_files, convert_data_267)
