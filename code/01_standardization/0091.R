# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0091" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Hard coral data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull()

### 2.1.1 Code data ----

data_code <- read_xlsx(data_path, sheet = 1,
                       range = "A23:B97", col_names = c("code", "organismID"))

### 2.1.2 Main data ----

data_coral <- read_xlsx(data_path, sheet = 2) %>% 
  pivot_longer("ACER":"UNKN", names_to = "code", values_to = "measurementValue") %>% 
  left_join(., data_code) %>% 
  # MPHA and FAVI are codes without equivalences
  mutate(organismID = case_when(code %in% c("UNKN", "MPHA", "FAVI") ~ "Hard coral unknown species",
                                TRUE ~ organismID))

## 2.2 Algae data ----

data_algae <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  pivot_longer("CCA":"CMI", names_to = "organismID", values_to = "measurementValue") %>% 
  filter(organismID %in% c("CCA", "FMA", "CMA")) %>% 
  mutate(organismID = case_when(organismID == "CCA" ~ "Crustose algae",
                                organismID == "FMA" ~ "Fleshy macroalgae",
                                organismID == "CMA" ~ "Calcareous macroalgae"))
  
## 2.3 Combine ----

bind_rows(data_coral, data_algae) %>% 
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

rm(data_code, data_coral, data_algae, data_path)
