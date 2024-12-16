# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0091" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Benthic cover 1.0 ----

### 2.1.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(.)

### 2.1.2 Main data ----

data_main_coral <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  pivot_longer("ACER":ncol(.), names_to = "code", values_to = "measurementValue")

data_main_algae <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  pivot_longer("NQ":ncol(.), names_to = "code", values_to = "measurementValue") %>% 
  filter(!(code %in% c("NQ", "MH", "MI", "FH", "FMI", "CH", "CMI", "M")))

data_main_1_0 <- bind_rows(data_main_coral, data_main_algae) %>% 
  left_join(., data_code) %>% 
  mutate(locality = ifelse(is.na(Site), Code, Site)) %>% 
  rename(decimalLatitude = Latitude, decimalLongitude = Longitude, verbatimDepth = Depth, eventDate = Date,
         parentEventID = Trans, recordedBy = Surveyor, habitat = Zone) %>% 
  select(-Batch, -Code, -Site, -Subregion, -Shelf, -Ecoregion, -Length, -code)

rm(data_code, data_main_algae, data_main_coral)

## 2.2 Benthic cover 2.0 ----

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
  filter(datasetID == dataset & data_type == "date") %>% 
  select(data_path) %>% 
  pull() %>%
  read_xlsx(.,
            sheet = "Overall") %>% 
  select(`Survey ID`, `Survey Name`, `Transect ID`,`Surveyor`, `Surveyed`)

### 2.2.3 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
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

list_sheets <- tibble(sheet = readxl::excel_sheets("data/01_raw-data/0091/2.0 BenthicCoverByTransect.xlsx"),
                      path = as.character("data/01_raw-data/0091/2.0 BenthicCoverByTransect.xlsx")) %>% 
  filter(!(sheet %in% c("TermsOfUse", "Metadata", "Overall", "tNDCORAL")))

### 2.2.5 Create the function ----

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

rm(data_code, data_site, data_date, list_sheets, convert_data_091)

## 2.3 Combine and export data ----

bind_rows(data_main_1_0, data_main_2_0) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Point intersect transect, 10 m transect length, every 0.1 m") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_main_1_0, data_main_2_0)
