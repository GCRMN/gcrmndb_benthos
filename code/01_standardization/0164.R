# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0164" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Equivalences between old site names and new site names (PIN) ----

data_oldsites <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 1) %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(encoding = "UTF-8", na.strings = "N/A") %>% 
  rename(locality = 1, oldsite = 2) %>% 
  mutate(locality = parse_number(locality),
         oldsite = as.numeric(oldsite)) %>% 
  drop_na(oldsite)

## 2.2 New site names coordinates ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  filter(row_number() == 2) %>% 
  select(data_path) %>% 
  pull() %>% 
  readxl::read_xls(na = c("Na", "na")) %>% 
  bind_rows(., read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
              filter(datasetID == dataset & data_type == "site") %>%
              filter(row_number() == 3) %>% 
              select(data_path) %>% 
              pull() %>% 
              readxl::read_xls(na = c("Na", "na"))) %>% 
  rename(locality = PIN, decimalLatitude = Lat, decimalLongitude = Long, verbatimDepth = `Depth (m)`) %>% 
  select(-`Depth (ft)`) %>% 
  mutate(verbatimDepth = abs(verbatimDepth))

## 2.3 List of sheets to combine ----

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  readxl::excel_sheets() %>% 
  as_tibble() %>% 
  filter(str_detect(value, "Deep|Bleaching|Metadata") == FALSE) %>% 
  rename(sheet = 1)

## 2.4 Create a function to convert the data ----

convert_0164 <- function(sheet){
  
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

## 2.5 Combine the sheets ----

map_dfr(list_sheets$sheet, ~convert_0164(sheet = .)) %>% 
  mutate(year = case_when(str_detect(parentEventID, "2009") == TRUE ~ 2009,
                          str_detect(parentEventID, "2010") == TRUE ~ 2010,
                          str_detect(parentEventID, "2011") == TRUE ~ 2011,
                          str_detect(parentEventID, "2012") == TRUE ~ 2012,
                          TRUE ~ as.numeric(str_sub(parentEventID, 1, 4))),
         oldsite = case_when(year >= 2013 ~ str_split_fixed(parentEventID, "_", 4)[,4],
                         year %in% c(2011, 2012) ~ str_split_fixed(parentEventID, "_", 4)[,1],
                         year == 2009 ~ str_remove_all(parentEventID, "2009EFGBRQ|2009WFGBRQ"),
                         year == 2010 ~ str_remove_all(parentEventID, "2010EFGBRQ|2010WFGBRQ")),
         oldsite = parse_number(oldsite)) %>%  
  left_join(., data_oldsites) %>% 
  mutate(locality = ifelse(is.na(locality), oldsite, locality)) %>% 
  select(-oldsite) %>% 
  left_join(., data_site) %>% 
  select(-parentEventID, -sheet) %>% 
  filter(!(organismID %in% c("Tape", "Wand", "Shadow", "Tag", "No Data", "Monofilament", "Diver"))) %>% 
  mutate(locality = paste0("PIN", locality),
         datasetID = dataset,
         samplingProtocol = "Photo-quadrat") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_oldsites, list_sheets, convert_0164)
