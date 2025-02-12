# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0153" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Dominican Republic ----

### 2.1.1 Dominican Republic 2020 ----

data_dr_2020 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos_Coco_2020", range = "A1:O601") %>% 
  rename(day = "Día", month = "Mes", year = "Año", locality = "Sitio",
         recordedBy = "Observador", verbatimDepth = "Profundidad", parentEventID = "N. Transecto",
         organismID = "Especie") %>% 
  select(-"Temp.", -"Conteo", -"clave", -"Grupo", -"P. Final", -"Hotel", -"N. Registro") %>% 
  mutate(eventDate = as.Date(paste(as.character(year),
                                   str_pad(as.character(month), 2, pad = "0"),
                                   str_pad(as.character(day), 2, pad = "0"),
                                   sep = "-"))) %>% 
  # Convert from number of points to percentage cover
  group_by(pick(everything())) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total)

### 2.1.2 Dominican Republic 2021 ----

data_dr_2021 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "AGRRA_Coco_2021", col_names = FALSE) %>% 
  drop_na(...1) %>% 
  mutate(parentEventID = rep(1:6, each = 10)) %>% 
  pivot_longer(1:10, names_to = "remove", values_to = "organismID") %>% 
  select(-remove) %>% 
  # Convert from number of points to percentage cover
  group_by(pick(everything())) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  drop_na(organismID) %>% 
  mutate(locality = "Coco Reef",
         year = 2020,
         day = 10,
         month = 3,
         eventDate = as.Date("2021-03-10"))

### 2.1.3 Dominican Republic 2022 ----

data_dr_2022 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos_2022", col_names = FALSE) %>% 
  filter(str_detect(`...1`, " cm")) %>% 
  select(2:11) %>% 
  mutate(parentEventID = rep(1:6, each = 10)) %>% 
  pivot_longer(1:10, names_to = "remove", values_to = "organismID") %>% 
  select(-remove) %>% 
  # Convert from number of points to percentage cover
  group_by(pick(everything())) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  drop_na(organismID) %>% 
  mutate(locality = "Coco Reef",
         year = 2022,
         day = 3,
         month = 3,
         eventDate = as.Date("2022-03-03"))

### 2.1.4 Dominican Republic 2023 ----

data_dr_2023 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx() %>% 
  pivot_longer(8:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(locality = Site, parentEventID = Transect) %>% 
  select(locality, parentEventID, organismID, measurementValue) %>% 
  filter(!(organismID %in% c("Cobertura coral vivo", "Cobertura alga", "Suma"))) %>% 
  mutate(year = 2023,
         day = 11,
         month = 24,
         eventDate = as.Date("2023-11-24"))

### 2.1.5 Dominican Republic 2024 (1) ----

data_dr_2024_1 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos_2024_1") %>% 
  rename(day = "Día", month = "Mes", year = "Año", locality = "Sitio",
         recordedBy = "Observador", verbatimDepth = "Profundidad", parentEventID = "N. Transecto",
         organismID = "Grupo") %>% 
  select(-"Temp.", -"Conteo", -"Código", -"N. Registro") %>% 
  mutate(eventDate = as.Date(paste(as.character(year),
                                   str_pad(as.character(month), 2, pad = "0"),
                                   str_pad(as.character(day), 2, pad = "0"),
                                   sep = "-"))) %>% 
  # Convert from number of points to percentage cover
  group_by(pick(everything())) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total)

### 2.1.6 Dominican Republic 2024 (2) ----

data_dr_2024_2 <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Benthos_2024_2") %>% 
  rename(day = "Día", month = "Mes", year = "Año", locality = "Sitio",
         recordedBy = "Observador", verbatimDepth = "Profundidad", parentEventID = "N. Transecto",
         organismID = "Especie") %>% 
  select(-"Temp.", -"Conteo", -"clave", -"Grupo", -"P. Final", -"Localidad", -"N. Registro") %>% 
  mutate(eventDate = as.Date(paste(as.character(year),
                                   str_pad(as.character(month), 2, pad = "0"),
                                   str_pad(as.character(day), 2, pad = "0"),
                                   sep = "-"))) %>% 
  # Convert from number of points to percentage cover
  group_by(pick(everything())) %>% 
  summarise(measurementValue = n()) %>% 
  ungroup() %>% 
  group_by(across(c(-organismID, -measurementValue))) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total)

### 2.1.7 Bind data ----

data_dr <- bind_rows(data_dr_2020, data_dr_2021, data_dr_2022,
                     data_dr_2023, data_dr_2024_1, data_dr_2024_2)

rm(data_dr_2020, data_dr_2021, data_dr_2022,
   data_dr_2023, data_dr_2024_1, data_dr_2024_2)

## 2.2 Mexico ----

### 2.2.1 Create a function to convert the data ----

convert_0153 <- function(path, sheet, date, site){
  
  data <- readxl::read_xlsx(path = path, sheet = sheet, col_names = FALSE) %>% 
    filter(str_detect(`...1`, " cm")) %>% 
    select(2:11) %>% 
    mutate(parentEventID = rep(1:6, each = 10)) %>% 
    pivot_longer(1:10, names_to = "remove", values_to = "code") %>% 
    select(-remove) %>% 
    # Convert from number of points to percentage cover
    group_by(pick(everything())) %>% 
    summarise(measurementValue = n()) %>% 
    ungroup() %>% 
    group_by(across(c(-code, -measurementValue))) %>% 
    mutate(total = sum(measurementValue)) %>% 
    ungroup() %>% 
    mutate(measurementValue = (measurementValue*100)/total) %>% 
    select(-total) %>% 
    drop_na(code) %>% 
    mutate(eventDate = as.Date(date),
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           locality = site)
  
  return(data)
  
}

### 2.2.2 Apply the function to each sheet ----

data_mexico <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 6) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0153(path = ., sheet = "Benthos_Manchoncitos_II_1902202", site = "Manchoncitos II", date = "2024-02-19") %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_I_16022024", site = "Manchoncitos I", date = "2024-02-16")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_II_1402202", site = "Manchoncitos I", date = "2023-02-14")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_ll_3110202", site = "Manchoncitos II", date = "2023-10-31")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_I_12042023", site = "Manchoncitos I", date = "2023-04-12")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Francesita_18082022", site = "La Francesita", date = "2022-08-18")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_II_2610202", site = "La Francesita", date = "2022-10-26")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 6) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Manchoncitos_I_25102022", site = "Manchoncitos I", date = "2022-10-25"))

## 2.3 Jamaica ----

data_jamaica <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  filter(row_number() == 4) %>% 
  select(data_path) %>% 
  pull() %>% 
  convert_0153(path = ., sheet = "Bentos", site = "Canyons Reef", date = "2024-10-20") %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 5) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Canyons_17112023", site = "Canyons Reef", date = "2023-11-17")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 5) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Canyons_02112022", site = "Canyons Reef", date = "2022-11-02")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 5) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Canyons_01112021", site = "Canyons Reef", date = "2021-11-01")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "main") %>%
              filter(row_number() == 5) %>% 
              select(data_path) %>% 
              pull() %>% 
              convert_0153(path = ., sheet = "Benthos_Canyons_02032020", site = "Canyons Reef", date = "2020-03-02"))

## 2.4 Combine data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()

bind_rows(data_jamaica, data_mexico) %>% 
  left_join(., data_code) %>% 
  select(-code) %>% 
  bind_rows(., data_dr) %>% 
  mutate(decimalLatitude = case_when(locality == "Canyons Reef" ~ 18.52514,
                                     locality == "Coco Reef" ~ 18.33883,
                                     locality == "Manchoncitos II" ~ 20.75028,
                                     locality == "Manchoncitos I" ~ 20.73964,
                                     locality == "La Francesita" ~ 20.36275),
         decimalLongitude = case_when(locality == "Canyons Reef" ~ -77.77761,
                                      locality == "Coco Reef" ~ -68.82389,
                                      locality == "Manchoncitos II" ~ -86.95078,
                                      locality == "Manchoncitos I" ~ -86.95539,
                                      locality == "La Francesita" ~ -87.02736),
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_dr, data_jamaica, data_mexico)
