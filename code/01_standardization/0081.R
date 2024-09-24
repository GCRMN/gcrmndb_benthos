# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0081" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  select(Site, Depth_ft, LatDD, LonDD, VerbatimDate, "Site Code") %>% 
  rename(locality = Site, locality_code = "Site Code", decimalLatitude = LatDD, decimalLongitude = LonDD,
         verbatimDepth = Depth_ft, eventDate = VerbatimDate) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = str_replace_all(verbatimDepth, c("20-30" = "25",
                                                          "20-31" = "25.5",
                                                          "40-45" = "42.5")),
         # Convert feet to meters
         verbatimDepth = as.numeric(verbatimDepth)/3.28084) %>% 
  # Remove duplicated sites (multiples dates, but not possible to take this into account for the join)
  filter(!(locality == "Dairy Bull" & eventDate == as.Date("2020-02-07")),
         !(locality == "Noranda Relocation" & eventDate == as.Date("2020-06-19")))

## 2.2 Main data ----

### 2.2.1 List of files to combine ----

data_files <- tibble(path = list.files(path = "data/01_raw-data/0081/", full.names = TRUE)) %>% 
  filter(str_detect(path, ".xlsx|.xls") == TRUE & str_detect(path, "UWI") == FALSE) %>% 
  pull(path)

### 2.2.2 Create a function to standardize data ----

convert_data_081 <- function(index_i){
  
  data_files_i <- data_files[index_i]
  
  if(endsWith(data_files_i, ".xlsx") == TRUE){
    
    data <- read_xlsx(data_files_i, sheet = "Data Summary", range = "A27:F133", col_names = FALSE) %>% 
      pivot_longer(2:6, values_to = "measurementValue", names_to = "parentEventID") %>% 
      mutate(locality_code = str_split_fixed(data_files_i, "_", 7)[,5],
             parentEventID = str_replace_all(parentEventID, c("...2" = "1",
                                                              "...3" = "2",
                                                              "...4" = "3",
                                                              "...5" = "4",
                                                              "...6" = "5")),
             parentEventID = as.numeric(parentEventID)) %>% 
      rename(organismID = "...1") %>% 
      drop_na(measurementValue)
    
  }else if (endsWith(data_files_i, ".xlsx") == FALSE){
    
    data <- read_xls(data_files_i, sheet = "Data Summary", range = "A27:F133", col_names = FALSE) %>% 
      pivot_longer(2:6, values_to = "measurementValue", names_to = "parentEventID") %>% 
      mutate(locality_code = str_split_fixed(data_files_i, "_", 7)[,5],
             parentEventID = str_replace_all(parentEventID, c("...2" = "1",
                                                              "...3" = "2",
                                                              "...4" = "3",
                                                              "...5" = "4",
                                                              "...6" = "5")),
             parentEventID = as.numeric(parentEventID)) %>% 
      rename(organismID = "...1") %>% 
      drop_na(measurementValue)
    
  }else{
    
    stop("The file extension must be .xls or .xlsx")
    
  }
  
  return(data)
  
}

### 2.2.3 Map over the function ----

map_dfr(1:length(data_files), ~convert_data_081(index_i = .)) %>% 
  left_join(., data_site) %>%
  select(-locality_code) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 30 m transect length",
         organismID = str_remove(organismID, "\\s*\\([^\\)]+\\)")) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_files, convert_data_081)
