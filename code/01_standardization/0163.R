# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0163" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  readxl::read_xlsx() %>% 
  rename(locality = "Location", decimalLatitude = lat, decimalLongitude = long,
         sheet = `Bank...6`) %>% 
  select(locality, sheet, decimalLatitude, decimalLongitude) %>% 
  mutate(locality = paste(sheet, "-", gsub("[0-9]", "", locality))) %>% 
  select(-sheet) %>% 
  filter(str_detect(locality, "ooring") == FALSE) %>% 
  # Generate variability in site coordinates since its random transect
  rowwise() %>% 
  mutate(year = list(seq(2009, 2024, by = 1))) %>% 
  ungroup() %>% 
  unnest(cols = c("year")) %>%
  group_by(locality, year) %>% 
  mutate(across(c(decimalLatitude, decimalLongitude), ~.x+(sample(c(1:9), size = 1)/100000))) %>% 
  ungroup()

## 2.2 List of sheets to combine ----

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  readxl::excel_sheets() %>% 
  as_tibble() %>% 
  filter(str_detect(value, "Reefwide") == FALSE) %>% 
  rename(sheet = 1)

## 2.3 Create a function to convert the data ----

convert_0163 <- function(sheet){
  
  data <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>%
    select(data_path) %>% 
    pull() %>% 
    readxl::read_xlsx(path = ., sheet = sheet, skip = 5) %>% 
    select(-contains("...")) %>% 
    mutate(type = case_when(`TRANSECT NAME` == "SUBCATEGORIES (% of transect)" ~ 1,
                            `TRANSECT NAME` == "NOTES (% of transect)" ~ 2))%>% 
    mutate(type = zoo::na.locf(type, na.rm = FALSE)) %>% 
    filter(type == 1) %>% 
    select(-type) %>% 
    drop_na(2) %>% 
    pivot_longer(2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
    rename(organismID = 1) %>% 
    mutate(organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID),
           sheet = sheet)
  
  return(data)
  
}

## 2.4 Combine the sheets ----

map_dfr(list_sheets$sheet, ~convert_0163(sheet = .)) %>%  
  filter(!(organismID %in% c("Tape", "Wand", "Shadow", "Tag", "No Data", "Monofilament", "Diver"))) %>% 
  mutate(year = as.numeric(str_sub(sheet, 1, 4)),
         locality = case_when(year %in% c(2009, 2010) ~ str_split_fixed(parentEventID, " ", 3)[,3],
                              TRUE ~ parentEventID),
         sheet = str_split_fixed(sheet, " ", 3)[,2],
         sheet = str_remove_all(sheet, "FG"),
         parentEventID = parse_number(locality),
         locality = paste(sheet, "-", gsub("[0-9]", "", locality)),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  select(-sheet) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, list_sheets, convert_0163)
