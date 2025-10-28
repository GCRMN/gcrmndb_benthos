# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0076" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1) %>% 
  drop_na(Site) %>% 
  rename(locality = Site, eventDate = SurveyDate, recordedBy = Observer, verbatimDepth = "Depth (m)") %>% 
  mutate(samplingProtocol = "Photo-quadrat, 30 m transect length, every 2.8 m, area of 0.25 x 0.25 m",
         eventDate = as.Date(as.numeric(eventDate), origin = "1899-12-30"),
         locality = str_to_title(locality)) %>% 
  select(locality, eventDate, recordedBy, verbatimDepth, samplingProtocol)

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 2) %>% 
  drop_na(SiteName) %>% 
  rename(locality = SiteName, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  select(locality, decimalLatitude, decimalLongitude) %>% 
  mutate(locality = str_to_title(locality)) %>% 
  left_join(., data_site) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

## 2.2 Main data --

### 2.2.1 List of files and path to combine ----

data_range <- tibble(file = c(rep("Jana Island 2018 19 20 23_KFUPM", 7),
                              rep("KARAN ISLAND 2018 19 23_KFUPM", 5)),
                     sheet = c("JANA 2018", "JANA 2019", "JANA 2019", "JANA 2020", "JANA 2020", "JANA 2023", "JANA 2023",
                               "KARAN 2018", "KARAN 2019", "KARAN 2019", "KARAN 2023", "KARAN 2023"),
                     locality = c("Jana East", "Jana West", "Jana East", "Jana West", "Jana East", "Jana West", "Jana East",
                                  "Karan East", "Karan West", "Karan East", "Karan East", "Karan West"),
                     year = c(2018, 2019, 2019, 2020, 2020, 2023, 2023,
                              2018, 2019, 2019, 2023, 2023),
                     range = c("B18:H36", "B17:H44", "K16:Q41", "B17:E36", "H15:K31", "B18:H38", "K18:Q39",
                               "B18:H34", "B17:E35", "H17:K40", "A19:G39", "J19:P39"))

### 2.2.2 Create a function to standardize data ----

convert_data_076 <- function(index_i){
  
  data_range_i <- data_range %>% 
    filter(row_number(.) == index_i)
  
  data <- read_xlsx(path = paste0("data/01_raw-data/0076/", data_range_i[1,"file"], ".xlsx"),
                    sheet = as.character(data_range_i[1,"sheet"]),
                    range = as.character(data_range_i[1,"range"])) %>% 
    pivot_longer(., 2:ncol(.), names_to = "parentEventID", values_to = "measurementValue") %>% 
    drop_na(measurementValue) %>% 
    rename("organismID" = 1) %>% 
    mutate(parentEventID = str_remove_all(parentEventID, "T")) %>% 
    bind_cols(., data_range_i) %>% 
    select(-file, -sheet, -range) %>% 
    mutate(across(c(parentEventID, measurementValue), ~as.numeric(.)))
  
  return(data)
  
}

### 2.2.3 Map over the function ----

map_dfr(1:nrow(data_range), ~convert_data_076(index_i = .)) %>% 
  # Join with sites
  left_join(., data_site) %>% 
  mutate(organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID),
         datasetID = dataset) %>% 
  # Exclude tape, wand, shadow (otherwise, the % cover is greater than 100)
  filter(!(organismID %in% c("Shadow", "Tape", "Wand"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_range, convert_data_076)
