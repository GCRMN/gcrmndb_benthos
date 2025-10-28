# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0263" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(path = ., full.names = TRUE)

## 2.2 Create a function to combine the files ----

convert_0263 <- function(path){
  
  if(str_detect(path, "Ishigaki") == TRUE){
    
    data_results <- read_xls(path, skip = 1, na = "(no data)") %>% 
      select(Site, Latitude, Longitude, Depth, Year, Month, Hardcoral_percent) %>% 
      rename(locality = Site, decimalLatitude = Latitude, decimalLongitude = Longitude,
             year = Year, month = Month, measurementValue = Hardcoral_percent,
             verbatimDepth = Depth) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             across(c(year, month), ~as.numeric(.x)))
    
  }else if(str_detect(path, "2004|2005|2006|2009") == TRUE){
    
    data_results <- read_xls(path, skip = 3, na = "(no data)", sheet = 1) %>% 
      rename(locality = 4, decimalLatitude = 5, decimalLongitude = 6, verbatimDepth = 7,
             year = 10, month = 11, measurementValue = 22) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             year, month, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             across(c(year, month), ~as.numeric(.x)))
    
  }else if(str_detect(path, "Sekisei")){
    
    data_results <- read_xls(path, skip = 3, na = "(no data)") %>% 
      rename(locality = 4, decimalLatitude = 5, decimalLongitude = 6, verbatimDepth = 7,
             year = 10, month = 11, measurementValue = 21) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             year, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             across(c(year), ~as.numeric(.x)))
    
  }else if(str_detect(path, "2011") == TRUE){
    
    data_results <- read_xlsx(path, skip = 4, na = "(no data)", sheet = 1) %>% 
      rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
             eventDate = 15, measurementValue = 28) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             eventDate, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate))
    
  }else if(str_detect(path, "2012") == TRUE){
    
    data_results <- read_xlsx(path, skip = 4, na = "(no data)", sheet = 1) %>% 
      rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
             eventDate = 15, measurementValue = 29) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             eventDate, measurementValue) %>% 
      drop_na(locality) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30"),
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate))
    
  }else if(str_detect(path, "2013") == TRUE){
    
    data_results <- read_xls(path, skip = 4, na = "(no data)", sheet = 1) %>% 
      rename(locality = 8, decimalLatitude = 9, decimalLongitude = 10, verbatimDepth = 11,
             eventDate = 14, measurementValue = 28) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             eventDate, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30"),
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate)) %>% 
      drop_na(locality)
    
    }else if(str_detect(path, "2014") == TRUE){
      
      data_results <- read_xls(path, skip = 4, na = "(no data)", sheet = 1) %>% 
        rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
               eventDate = 15, measurementValue = 32) %>% 
        select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
               eventDate, measurementValue) %>% 
        mutate(organismID = "Hard coral",
               across(c(verbatimDepth, measurementValue), ~as.character(.x)),
               eventDate = as.Date(eventDate),
               year = year(eventDate),
               month = month(eventDate),
               day = day(eventDate)) %>% 
        drop_na(locality)
      
    }else if(str_detect(path, "2015") == TRUE){
      
      data_results <- read_xls(path, skip = 4, na = "(no data)", sheet = 1) %>% 
        rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
               eventDate = 16, measurementValue = 32) %>% 
        select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
               eventDate, measurementValue) %>% 
        mutate(organismID = "Hard coral",
               across(c(verbatimDepth, measurementValue), ~as.character(.x)),
               eventDate = as.Date(eventDate),
               year = year(eventDate),
               month = month(eventDate),
               day = day(eventDate)) %>% 
        drop_na(locality)
      
    }else if(str_detect(path, "2016") == TRUE){
    
    data_results <- read_xls(path, skip = 4, na = "(no data)", sheet = 1) %>% 
      rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
             eventDate = 16, measurementValue = 30) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             eventDate, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             eventDate = as.Date(eventDate),
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate)) %>% 
      drop_na(locality)
  
    }else if(str_detect(path, "2007") == TRUE){
    
    data_results <- read_xls(path, skip = 3, na = "(no data)", sheet = 4) %>% 
      rename(locality = 4, decimalLatitude = 5, decimalLongitude = 6, verbatimDepth = 7,
             year = 10, month = 11, measurementValue = 22) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             year, month, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             across(c(year, month), ~as.numeric(.x)))
    
  }else if(str_detect(path, "2008|2010") == TRUE){
    
    data_results <- read_xls(path, skip = 3, na = "(no data)", sheet = 3) %>% 
      rename(locality = 4, decimalLatitude = 5, decimalLongitude = 6, verbatimDepth = 7,
             year = 10, month = 11, measurementValue = 22) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             year, month, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             across(c(year, month), ~as.numeric(.x)))
    
  }else if(str_detect(path, "2017") == TRUE){
    
    data_results <- read_xls(path, skip = 4, na = "(no data)", sheet = 2) %>% 
      rename(locality = 9, decimalLatitude = 10, decimalLongitude = 11, verbatimDepth = 12,
             eventDate = 15, measurementValue = 30) %>% 
      select(locality, decimalLatitude, decimalLongitude, verbatimDepth,
             eventDate, measurementValue) %>% 
      mutate(organismID = "Hard coral",
             verbatimDepth = as.character(verbatimDepth),
             across(c(verbatimDepth, measurementValue), ~as.character(.x)),
             eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30"),
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate))
    
  }
  
  return(data_results %>% mutate(path = path))
  
}

## 2.3 Map over the function ----

data_0263 <- map(list_files, ~convert_0263(path = .)) %>% 
  list_rbind() %>% 
  mutate(verbatimDepth = as.numeric(verbatimDepth),
         datasetID = dataset,
         measurementValue = as.numeric(measurementValue)) %>% 
  drop_na(measurementValue)

## 2.4 Correct coordinates ----

data_coords_a <- data_0263 %>% 
  select(decimalLatitude, decimalLongitude) %>% 
  distinct() %>% 
  mutate(decimalLatitude2 = str_replace_all(decimalLatitude, "′", "'"),
         decimalLongitude2 = str_replace_all(decimalLongitude, "′", "'"),
         decimalLatitude2 = str_remove_all(decimalLatitude2, "″"),
         decimalLongitude2 = str_remove_all(decimalLongitude2, "″"),
         decimalLatitude2 = str_replace_all(decimalLatitude2, "ﾟ ", "°"),
         decimalLongitude2 = str_replace_all(decimalLongitude2, "ﾟ ", "°"),
         decimalLatitude2 = convert_coords(decimalLatitude2),
         decimalLongitude2 = convert_coords(decimalLongitude2))

data_coords_b <- data_coords_a %>% 
  filter(is.na(decimalLongitude2)) %>% 
  mutate(decimalLatitude2 = str_replace_all(decimalLatitude, "゜", "°"),
         decimalLatitude2 = str_replace_all(decimalLatitude2, "″", "''"),
         decimalLatitude2 = str_replace_all(decimalLatitude2, "′", "'"),
         decimalLatitude2 = str_replace_all(decimalLatitude2, "o", "°"),
         decimalLatitude2 = case_when(str_detect(decimalLatitude2, ":") == TRUE ~
                                         paste0(str_split_fixed(decimalLatitude2, ":", 3)[,1],
                                                "°",
                                                str_split_fixed(decimalLatitude2, ":", 3)[,2],
                                                "'",
                                                str_split_fixed(decimalLatitude2, ":", 3)[,3]),
                                       TRUE ~ decimalLatitude2),
         decimalLongitude2 = str_replace_all(decimalLongitude, "゜", "°"),
         decimalLongitude2 = str_replace_all(decimalLongitude2, "″", "''"),
         decimalLongitude2 = str_replace_all(decimalLongitude2, "′", "'"),
         decimalLongitude2 = str_replace_all(decimalLongitude2, "o", "°"),
         decimalLongitude2 = case_when(str_detect(decimalLongitude2, ":") == TRUE ~
                                         paste0(str_split_fixed(decimalLongitude2, ":", 3)[,1],
                                                "°",
                                                str_split_fixed(decimalLongitude2, ":", 3)[,2],
                                                "'",
                                                str_split_fixed(decimalLongitude2, ":", 3)[,3]),
                                       TRUE ~ decimalLongitude2),
         decimalLatitude2 = convert_coords(decimalLatitude2),
         decimalLongitude2 = convert_coords(decimalLongitude2))

data_coords <- data_coords_a %>% 
  filter(!(is.na(decimalLongitude2))) %>% 
  bind_rows(., data_coords_b)

data_0263 %>% 
  left_join(., data_coords) %>% 
  select(-decimalLatitude, -decimalLongitude, -path) %>% 
  rename(decimalLatitude = decimalLatitude2,
         decimalLongitude = decimalLongitude2) %>% 
  mutate(samplingProtocol = "Timed swim") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----
  
rm(data_0263, data_coords, data_coords_a, data_coords_b,
   list_files, convert_coords, convert_0263)
