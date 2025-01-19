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

## 2.2 Depth data ----

data_depth <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "date") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(sheet = 2) %>% 
  rename(locality = Site, depth_min = "Depth (m) min", depth_max = "Depth (m) max") %>% 
  mutate(verbatimDepth = (depth_min + depth_max)/ 2) %>% 
  select(locality, verbatimDepth)

## 2.3 Date data ----

data_date <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "date") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  rename(time = "Time Point", locality = Site, year = Year, month = Month, day = Day) %>% 
  select(-Locality) %>% 
  left_join(., data_depth) %>% 
  mutate(eventDate = as_date(paste0(year,
                                    str_pad(month, pad = "0", width = 2),
                                    str_pad(day, pad = "0", width = 2),
                                    sep = "-")),
         time = zoo::na.locf(time),
         locality = case_when(locality == "Coralina profunda" ~ "Coralina Profundo",
                              locality == "Orbicella" ~ "Orbicellas",
                              locality == "Palmata" ~ "Palmatas",
                              locality == "Peñón" ~ "Penon",
                              locality == "Fundemar" ~ "Vivero FUNDEMAR",
                              TRUE ~ locality))

## 2.3 Main data ----

### 2.3.1 List of files to combine ----

data_files <- list.files(path = "data/01_raw-data/0080/", pattern = ".xlsx", full.names = TRUE)

### 2.3.2 Create a function to standardize data ----

convert_data_080 <- function(index_i, sheet_i = "cobertura"){
  
  data_files_i <- data_files[index_i]
  
  if(index_i != 8){ # Expressed in percentage
  
  data <- read_xlsx(data_files_i, sheet = sheet_i) %>% 
    pivot_longer("Acropora cervicornis":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    filter(!(organismID %in% c("Cobertura alga", "Cobertura coral vivo", "Suma"))) %>% 
    select(Site, Transect, organismID, measurementValue) %>% 
    rename(locality = Site, parentEventID = Transect) %>% 
    mutate(time = str_split_fixed(data_files_i, n = 5, pattern = "_")[,3])
  
  }else{ # Expressed in number of points
    
    data <- read_xlsx(data_files_i, sheet = 1) %>% 
      pivot_longer("Acropora cervicornis":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      select(Site, Transect, organismID, measurementValue) %>% 
      rename(locality = Site, parentEventID = Transect) %>% 
      group_by(locality, parentEventID) %>% 
      mutate(total = sum(measurementValue)) %>% 
      ungroup() %>% 
      mutate(measurementValue = (measurementValue*100)/total,
             time = str_split_fixed(data_files_i, n = 5, pattern = "_")[,3]) %>% 
      select(-total)
    
  }
  
  return(data)
  
}

### 2.3.3 Map over the function ----

map_dfr(1:7, ~convert_data_080(index_i = .)) %>% 
  bind_rows(., convert_data_080(index_i = 8, sheet = 1)) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 10 m transect length, every 2 m",
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
  left_join(., data_date) %>%
  select(-time) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_files, convert_data_080, data_depth, data_date)
