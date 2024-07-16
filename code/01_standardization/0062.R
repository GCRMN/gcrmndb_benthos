# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0062" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = "Metadata") %>% 
  mutate(decimalLatitude = as.numeric(str_split_fixed(Coordinates, ", ", 2)[,1]),
         decimalLongitude = as.numeric(str_split_fixed(Coordinates, ", ", 2)[,2])) %>% 
  rename(eventDate = Date, locality = Site, verbatimDepth = "Depth (m)") %>% 
  select(eventDate, locality, verbatimDepth, decimalLatitude, decimalLongitude) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate))

## 2.2 Main data ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

extract_xlsx <- function(sheet){
  
  data <- read_xlsx(path = data_path, sheet = sheet, range = "A29:B119") %>% 
    mutate(locality = str_remove_all(sheet, "Benthic_"))
  
  return(data)
  
}

map_dfr(c("Benthic_Jeff Davis", "Benthic_Punt Vierkant", "Benthic_Oilslick"),
        ~extract_xlsx(sheet = .)) %>% 
  rename(organismID = 1, measurementValue = 2) %>% 
  drop_na(measurementValue) %>% 
  left_join(., data_site) %>% 
  mutate(organismID = str_split_fixed(organismID, " \\(", 2)[,1],
         samplingProtocol = "Photo-quadrat",
         datasetID = dataset) %>% 
  # Export data
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_path, extract_xlsx, data_site)
