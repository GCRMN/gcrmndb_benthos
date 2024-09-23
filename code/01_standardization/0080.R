# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0080" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude, locality = Name) %>% 
  select(locality, decimalLatitude, decimalLongitude) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~as.numeric(.)))

## 2.2 Main data ----

### 2.2.1 List of files to combine ----

data_files <- list.files(path = "data/01_raw-data/0080/", pattern = ".xlsx", full.names = TRUE)

### 2.2.2 Create a function to standardize data ----

convert_data_080 <- function(index_i, sheet_i = "cobertura"){
  
  data_files_i <- data_files[index_i]
  
  data <- read_xlsx(data_files_i, sheet = sheet_i) %>% 
    pivot_longer("Acropora cervicornis":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    filter(!(organismID %in% c("Cobertura alga", "Cobertura coral vivo", "Suma"))) %>% 
    select(Site, Transect, organismID, measurementValue) %>% 
    rename(locality = Site, parentEventID = Transect) %>% 
    mutate(year = as.numeric(str_split_fixed(data_files_i, n = 5, pattern = "_")[,4]))
  
  return(data)
  
}

### 2.2.3 Map over the function ----

map_dfr(1:7, ~convert_data_080(index_i = .)) %>% 
  bind_rows(., convert_data_080(index_i = 8, sheet = 1)) %>% 
  mutate(datasetID = dataset,
         locality = str_replace_all(locality, c("Cervivornis" = "Cervicornis",
                                                "CocoReef" = "Coco Reef",
                                                "CooReef" = "Coco Reef",
                                                "Coralina Profunda" = "Coralina Profundo",
                                                "CoralinaProfundo" = "Coralina Profundo",
                                                "Minitas1" = "Minitas 1",
                                                "Minitas2" = "Minitas 2",
                                                "Minitas3" = "Minitas 3",
                                                "VivaShallow" = "Viva Shallow")),
         locality = case_when(locality == "Orbicella" ~ "Orbicellas",
                              locality == "Palmata" ~ "Palmatas",
                              str_detect(locality, "Dominicus") == TRUE ~ "Dominicus Reef",
                              str_detect(locality, "Fundemar|FUNDEMAR") == TRUE ~ "Vivero FUNDEMAR",
                              TRUE ~ locality)) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_files, convert_data_080)
