# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
library(lubridate) # For dates format
source("code/00_functions/convert_coords.R")

dataset <- "0021" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Site data --

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(range = "A4:K98") %>% 
  rename(habitat = "Type de récif", decimalLatitude = "Latitude Sud", decimalLongitude = "Longitude Est",
         recordedBy = "Observateurs", locality = "Station") %>% 
  select(locality, habitat, decimalLatitude, decimalLongitude, recordedBy) %>% 
  mutate(decimalLatitude = -convert_coords(decimalLatitude),
         decimalLongitude = convert_coords(decimalLongitude),
         locality = str_to_sentence(locality),
         locality = iconv(locality, from = 'UTF-8', to = 'ASCII//TRANSLIT'), # Convert accent letters
         locality = str_replace_all(locality, c("M'bere" = "Mbere",
                                                "Ilot maitre" = "Maitre",
                                                "Plateau d'amos" = "Amos",
                                                "Balade" = "Recif balade",
                                                "Recif tombo" = "Tombo",
                                                "Waunyi" = "Waugni",
                                                "Anemaac" = "Anemeec",
                                                "Ilot isie" = "Isie",
                                                "Grand recif de pum" = "Gr pum",
                                                "Ilot sable" = "Sable")))

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls(., sheet = "CODES") %>% 
  rename("organismID" = "Description") %>% 
  mutate(organismID = str_replace_all(organismID, c("Coraux morts récemment \\(blancs\\)" = "dead coral",
                                                    "Macroalgues et turf algal épais" = "macroalgae and turf",
                                                    "Roches, blocs > 15 cm et dalle" = "rock",
                                                    "Débris, blocs < 15 cm" = "rubble")))

# 2.3 Main data --

# 2.3.1 Get list of sheets -

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  excel_sheets() %>% 
  as_tibble() %>% 
  filter(!(value %in% c("2022", "CODES")))
  
# 2.3.2 Get the path of the file -

file_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

# 2.3.3 Combine data -

data <- map_dfr(list_sheets$value, ~read_xls(file_path, sheet = ., col_types = "text", na = "NI")) %>% 
  drop_na(Site) %>% 
  select(-"CV", -"...19", -"...20") %>% 
  pivot_longer("HCB":"OT", names_to = "Code", values_to = "measurementValue") %>% 
  left_join(., data_code) %>% 
  select(-Code) %>% 
  rename(locality = Station) %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         Transect = as.numeric(Transect),
         locality = str_to_sentence(locality),
         locality = iconv(locality, from = 'UTF-8', to = 'ASCII//TRANSLIT'), # Convert accent letters
         locality = str_replace_all(locality, c("N'goni" = "Ngoni",
                                                "Bordure faille de poe" = "Faille de poe",
                                                "Signal" = "Ilot signal"))) %>% 
  left_join(., data_site)

# 3. Remove useless objects ----

rm(data_code, data_site, list_sheets, file_path)
