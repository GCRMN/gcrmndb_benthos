# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0091" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Version 4 ----

data_algae <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  select(-Site, -NQ, -M, -MH, -MI, -FH, -FMI, -CH, -CMI)

## 2.2 Version 5 -----

### 2.2.1 Hard coral data A ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull()

data_code_coral <- read_xlsx(data_path, sheet = 1,
                             range = "A23:B97", col_names = c("code", "organismID"))

data_coral_a <- read_xlsx(data_path, sheet = 2) %>% 
  select(-Site, -Length)

### 2.2.2 Hard coral data B ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 4) %>% 
  select(data_path) %>% 
  pull()

data_coral_b <- read_xlsx(data_path, sheet = 2) %>% 
  select(-Site, -Length, -SLength, -SLC)

## 2.2.3 Non hard coral categories ----

data_code_other <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Key", range = "A17:B36", col_names = c("code", "organismID")) %>% 
  mutate(organismID = str_remove_all(organismID, "% ")) 

data_other <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 3) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = "Data") %>% 
  select(-Site, -Length)

## 2.3 Combine all ----

data_all <- full_join(data_coral_a, data_coral_b) %>% 
  full_join(., data_other) %>% 
  full_join(data_algae, .) %>% 
  rowwise() %>% 
  mutate(sum_hc = sum(c_across("ACER":"UNKN"), na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(LC = case_when(sum_hc == LC ~ 0,
                        sum_hc != LC ~ LC)) %>% 
  rowwise() %>% 
  mutate(sum = sum(c_across("CCA":"O"), na.rm = TRUE)) %>% 
  ungroup()

## 2.4 Misc checks ----

hist(data_all$sum)

nrow(data_all %>% filter(sum == 0))

nrow(data_all %>% filter(sum > 101))

min(year(data_all$Date))

max(year(data_all$Date))

## 2.5 Add codes ----

data_code <- bind_rows(data_code_coral, data_code_other)

data_all %>% 
  select(-TOTAL, -sum_hc, -sum) %>% 
  pivot_longer("CCA":"O", names_to = "code", values_to = "measurementValue") %>% 
  drop_na(measurementValue) %>% 
  left_join(., data_code) %>% 
  # MPHA and FAVI are codes without equivalences
  mutate(organismID = case_when(code %in% c("UNKN", "MPHA", "FAVI") ~ "Hard coral unknown species",
                                TRUE ~ organismID)) %>% 
  rename(locality = Code, parentEventID = Trans, eventDate = Date, decimalLatitude = Latitude,
         decimalLongitude = Longitude, verbatimDepth = Depth) %>% 
  select(locality, decimalLatitude, decimalLongitude, eventDate, parentEventID,
         verbatimDepth, organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
  
# 3. Remove useless objects ----
  
rm(data_algae, data_all, data_code, data_code_coral, data_code_other,
   data_coral_a, data_coral_b, data_other, data_path)
