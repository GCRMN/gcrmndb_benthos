# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0231" # Define the dataset_id

# 2. Combine data from 1998 to 2019 ----

## 2.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2(encoding = "latin1") %>% 
  mutate(code = str_squish(code))

## 2.2 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "1998") == TRUE) %>% 
  select(value) %>% 
  pull()

list_sheets <- list_files %>% 
  excel_sheets(path = .) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "CODE BENTHOS") == FALSE) %>% 
  # Set the number of rows to skip
  mutate(skip = case_when(value %in% c("Planch Alizé PE", "Étang Salé Platier",
                                       "Étang Salé PE", "Ravine Blanche Platier",
                                       "Ravine Blanche PE", "Alizés Plage Platier",
                                       "Alizés Plage PE") ~ 11,
                          TRUE ~ 10))
  
## 2.3 Create a function ----

convert_data_231 <- function(sheet_i){
  
  skip_i <- list_sheets %>% 
    filter(value == sheet_i) %>% 
    select(skip) %>% 
    pull()
  
  data <- read_xlsx(path = list_files, sheet = sheet_i, skip = skip_i) %>% 
    mutate(name_1998 = sheet_i)
  
  return(data)
  
}

## 2.4 Map over the function ----

data_1998 <- map(list_sheets$value, ~convert_data_231(sheet_i = .x)) %>% 
  list_rbind() %>% 
  drop_na("Code Benthos") %>% 
  filter(!(`Code Benthos` %in% c("TOTAL", "Remarques", "Vérification%",
                                 "Coordonnées de la station centrale en degrés.décimaux (WGS 84)",
                                 "Sud", "-21.096350000000001"))) %>% 
  select(-`...20`, -`...21`, -`...22`, -`...23`) %>% 
  relocate(name_1998, .before = "Code Benthos") %>% 
  pivot_longer("1998":ncol(.), names_to = "year", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  # Add month to separate surveys done on the same year
  arrange(name_1998, year) %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         month = str_split_fixed(year, "\\.\\.\\.", 2)[,2],
         year = str_split_fixed(year, "\\.\\.\\.", 2)[,1]) %>% 
  group_by(name_1998, year) %>% 
  mutate(month = as.numeric(as.factor(month)),
         month = ifelse(month == 1, 2, 6),
         year = as.numeric(year)) %>% 
  ungroup() %>% 
  rename(code = `Code Benthos`) %>% 
  left_join(., data_code) %>% 
  select(-code)

# 3. Combine data from 2020 to 2024 ----

## 3.1 Path of files to combine ----

list_files <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(., recursive = TRUE, full.names = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "1998|\\.csv") == FALSE)

## 3.2 Create a function ----

convert_data_231 <- function(path_i){
  
    data <- read_xlsx(path = path_i, sheet = 2, skip = 8) %>% 
      mutate(name_2020 = path_i)
    
  return(data)
  
}

## 3.3 Map over the function ----

data_2020 <- map(list_files$value, ~convert_data_231(path_i = .x)) %>% 
  list_rbind() %>% 
  drop_na(Date) %>% 
  select(-`Année`, -`Années`, -`Identifiant`, -"% corail vivant", -"% Algues",
         -"Vérification %", -"% coraux vivants", -"% d'algues") %>% 
  mutate(name_2020 = str_remove_all(name_2020, "data/01_raw-data/0231/GCRMN Réunion | de 2020 à 2024.xlsx| 2020 à 2024.xlsx")) %>% 
  pivot_longer("Corail Acropora spp.":"Abiotique", values_to = "measurementValue", names_to = "organismID") %>% 
  rename(eventDate = Date) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

# 4. Bind datasets and export ----

## 4.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read.csv2(encoding = "latin1")

## 4.2 Bind datasets ----

bind_rows(data_1998 %>% left_join(., data_site),
                      data_2020 %>% left_join(., data_site)) %>% 
  select(-name_1998, -name_2020) %>% 
  mutate(datasetID = dataset,
         locality = paste(locality, habitat, sep = " "),
         samplingProtocol = "LIT, 20 m length transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 5. Remove useless objects ----

rm(data_code, data_site, data_1998, data_2020, list_files, list_sheets, convert_data_231)
