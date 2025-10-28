# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files
source("code/00_functions/convert_coords.R")

dataset <- "0021" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(range = "A4:K106") %>% 
  rename(habitat = "Type de récif", decimalLatitude = "Latitude Sud", decimalLongitude = "Longitude Est",
         recordedBy = "Observateurs", locality = "Station", verbatimDepth = "Profondeur maximale (m)") %>% 
  select(locality, habitat, decimalLatitude, decimalLongitude, recordedBy, verbatimDepth) %>% 
  mutate_at(c("locality", "habitat", "recordedBy"), ~iconv(., from = 'UTF-8', to = "ASCII//TRANSLIT")) %>% # Convert accent letters
  mutate(decimalLatitude = -convert_coords(decimalLatitude),
         decimalLongitude = convert_coords(decimalLongitude),
         locality = str_to_sentence(locality),
         locality = str_replace_all(locality, c("M'bere" = "Mbere",
                                                "Ilot maitre" = "Maitre",
                                                "Plateau d'amos" = "Amos",
                                                "Recif balade" = "Balade",
                                                "Recif tombo" = "Tombo",
                                                "Wenere - paradis" = "Mwaremwa",
                                                "Saint coq" = "Nde",
                                                "Waunyi" = "Waugni",
                                                "Anemaac" = "Anemeec",
                                                "Passe de toemo" = "We jouo",
                                                "Ilot isie" = "Isie",
                                                "Grand recif de pum" = "Gr pum",
                                                "Ilot sable" = "Sable")),
         habitat = str_replace_all(habitat, c("Recif intermediaire \\(ilot\\)" = "Patch reef",
                                              "Recif intermediaire \\(massif de lagon\\)" = "Lagoon",
                                              "Recif cotier sous influence oceanique" = "Fringing reef",
                                              "Recif cotier" = "Fringing reef",
                                              "Recif barriere \\(interne\\)" = "Barrier reef",
                                              "Recif barriere \\(externe\\)" = "Barrier reef",
                                              "Recif barriere \\(passe\\)" = "Barrier reef",
                                              "Massif oceanique" = "Platform reef")))

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xls(., sheet = "CODES") %>% 
  rename("organismID" = "Description") %>% 
  mutate(organismID = str_replace_all(organismID, c("Coraux morts récemment \\(blancs\\)" = "dead coral",
                                                    "Macroalgues et turf algal épais" = "macroalgae and turf",
                                                    "Roches, blocs > 15 cm et dalle" = "rock",
                                                    "Débris, blocs < 15 cm" = "rubble")))

## 2.3 Main data ----

### 2.3.1 Get list of sheets -----

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  excel_sheets() %>% 
  as_tibble() %>% 
  filter(!(value %in% c("2024")))
  
### 2.3.2 Get the path of the file ----

file_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

### 2.3.3 Create a function to combine the files ----

convert_0021 <- function(sheet_i ){
  
  data_results <- read_xlsx(file_path, sheet = sheet_i, col_types = "text") %>% 
    select(1:"CV") %>% 
    drop_na(Campagne) %>% 
    pivot_longer(5:ncol(.), names_to = "Code", values_to = "measurementValue")
  
  return(data_results)
  
}

### 2.3.4 Map over the function ----

map(list_sheets$value, ~convert_0021(sheet_i = .)) %>% 
  list_rbind() %>% 
  rename(year = Campagne, locality = Station, parentEventID = Transect) %>% 
  select(-Site) %>% 
  mutate(across(c("parentEventID", "measurementValue"), ~as.numeric(.x)),
         Code = str_split_fixed(Code, "\\.", 2)[,1]) %>% 
  filter(Code != "CV") %>% # CV is Corail vivant, the sum of HCB, HCM, HCO, and HCT
  drop_na(measurementValue) %>% 
  left_join(., data_code) %>% 
  select(-Code) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Point intersect transect, 20 m transect length, every 50 cm",
         locality = str_to_sentence(locality),
         locality = iconv(locality, from = 'UTF-8', to = 'ASCII//TRANSLIT'), # Convert accent letters
         locality = str_replace_all(locality, c("N'goni" = "Ngoni",
                                                "Bordure faille de poe" = "Faille de poe",
                                                "Signal" = "Ilot signal",
                                                "We jouo" = "We jouo - passe de toemo",
                                                "Mwaremwa" = "Mwaremwa - paradis")),
         date = case_when(str_length(year) == 5 ~ as.Date(as.numeric(year), origin = "1899-12-31"),
                          TRUE ~ NA),
         month = case_when(year == "2021 post-cyclones" ~ 5,
                           year == "2018-1" ~ 1,
                           year == "2018-1" ~ 2,
                           !is.na(date) ~ month(date)),
         year = str_replace_all(year, c("2021 post-cyclones" = "2021",
                                        "2018-1" = "2018",
                                        "2018-2" = "2018")),
         year = as.numeric(year),
         year = case_when(!is.na(date) ~ year(date), TRUE ~ year)) %>% 
  select(-date) %>% 
  left_join(., data_site) %>% 
  group_by(year, month, locality, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_code, data_site, list_sheets, file_path, convert_coords, convert_0021)
