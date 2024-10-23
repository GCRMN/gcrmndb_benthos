# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0091" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 AGRRA data version 1.0 ----

### 2.1.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>%
  pull() %>% 
  read.csv2() %>% 
  mutate(organismID = str_remove_all(organismID, "% "))

### 2.1.2 Main data ----

data_main <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 1) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2)

### 2.1.3 Data detailed for hard corals ----

data_hc <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2)

### 2.1.4 Data detailed for invertebrates ----

data_inv <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 3)

### 2.1.5 Data detailed for macroalgae ----

data_malg <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 2) %>% 
  pull() %>% 
  read_xlsx(., sheet = 4)

### 2.1.6 Combine and export data ----

data_main_1_0 <- data_main %>% 
  select(-LC, -TOTAL, -AINV, -OINV, -CMA, -FMA) %>% 
  left_join(., data_hc) %>% 
  left_join(., data_inv) %>% 
  left_join(., data_malg) %>% 
  pivot_longer(15:ncol(.), values_to = "measurementValue", names_to = "code") %>%
  left_join(., data_code) %>% 
  select(-code) %>% 
  rename(locality = Code, parentEventID = Trans, recordedBy = Surveyor, eventDate = Date,
         decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth) %>% 
  select(locality, parentEventID, recordedBy, eventDate, decimalLatitude, decimalLongitude,
         verbatimDepth, organismID, measurementValue)

## 2.2 AGRRA data version 2.0 ----

### 2.2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>%
  pull() %>% 
  read_xlsx(.,
            sheet = "Overall") %>% 
  rename(`Survey Name` = Name) %>% 
  select(`Survey ID`, `Survey Name`, Latitude, Longitude)

### 2.2.2 Date data ----

data_date <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 3) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Overall") %>% 
  select(`Survey ID`, `Survey Name`, `Transect ID`,`Surveyor`, `Surveyed`)

### 2.2.3 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 3) %>% 
  pull() %>% 
  read_xlsx(.,
            sheet = "Metadata",
            range = "B29:C203",
            col_names = c("code", "organismID"))

data_code <- bind_rows(data_code, 
                        # Generate newly dead equivalence codes
                        data_code %>%
                          filter(row_number() %in% 111:137) %>% 
                          mutate(code = paste0("ND-", code),
                                 organismID = paste0("Newly dead ", organismID))) %>% 
  add_row(code = c("GORG", "SM", "DJOL"),
          organismID = c("Gorgoniidae", "Sand-Mud", NA_character_))

### 2.2.4 List of sheets to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>%
  filter(row_number() == 3)

list_sheets <- tibble(sheet = readxl::excel_sheets(as.character(data_paths[1,1])),
                      path = as.character(data_paths[1,1])) %>% 
  filter(!(sheet %in% c("TermsOfUse", "Metadata", "Overall", "tNDCORAL")))

### 2.2.5 Create a function to combine the sheets ----

convert_data_091 <- function(index_i){
  
  data_i <- read_xlsx(path = as.character(list_sheets[index_i, "path"]),
                      sheet = as.character(list_sheets[index_i, "sheet"])) %>% 
    pivot_longer(5:ncol(.), values_to = "measurementValue", names_to = "code")
  
  return(data_i)
  
}

### 2.2.6 Map over the function ----

data_main_2_0 <- map_dfr(1:nrow(list_sheets), ~convert_data_091(.)) %>% 
  filter(!(str_starts(code, "t"))) %>% 
  mutate(measurementValue = measurementValue*100) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>%
  left_join(., data_date) %>% 
  select(-code) %>% 
  rename(locality = `Survey Name`, parentEventID = `Transect ID`, eventDate = Surveyed,
         recordedBy = Surveyor, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(-`Survey ID`, -`Transect Name`) %>% 
  mutate(eventDate = as.Date(eventDate))

# 3. Combine 1.0 and 2.0 data ----

bind_rows(data_main_1_0, data_main_2_0) %>%
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 4. Remove useless objects ----

rm(data_code, data_hc, data_inv, data_main, data_malg, data_main_1_0, data_main_2_0,
   data_paths, data_site, list_sheets, data_date, convert_data_091)
