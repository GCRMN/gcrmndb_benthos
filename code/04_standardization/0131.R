# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
source("code/00_functions/convert_coords.R")

dataset <- "0131" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 2, col_names = c("row", "locality", "reef", "coords",
                                               "2019_date", "2021_2022_date", "depth"), skip = 1) %>% 
  select(-row, -reef) %>% 
  mutate(decimalLatitude = str_split_fixed(coords, ", ", 2)[,1],
         decimalLatitude = convert_coords(decimalLatitude),
         decimalLongitude = str_split_fixed(coords, ", ", 2)[,2],
         decimalLongitude = convert_coords(decimalLongitude)) %>% 
  select(-coords) %>% 
  pivot_longer("2019_date":"2021_2022_date", names_to = "year", values_to = "eventDate") %>% 
  mutate(depth_1 = str_split_fixed(depth, ", ", 2)[,1],
         depth_2 = str_split_fixed(depth, ", ", 2)[,2]) %>% 
  pivot_longer("depth_1":"depth_2", names_to = "v2", values_to = "verbatimDepth") %>% 
  select(-depth, -v2) %>% 
  mutate(year = str_replace_all(year, c("2021_2022_date" = "2021/22",
                                        "2019_date" = "2019")),
         verbatimDepth = as.numeric(str_squish(verbatimDepth)),
         eventDate = str_squish(eventDate),
         eventDate = case_when(eventDate == "08/08/2019 (10m) and 21/07/19 (5m)" & verbatimDepth == 15 ~ "21/07/2019",
                               eventDate == "08/08/2019 (10m) and 21/07/19 (5m)" & verbatimDepth == 10 ~ "08/08/2019",
                               eventDate == "27/11/2021 (15m) 06/03/2021 (10m)" & verbatimDepth == 10 ~ "06/03/2021",
                               eventDate == "27/11/2021 (15m) 06/03/2021 (10m)" & verbatimDepth == 15 ~ "27/11/2021",
                               TRUE ~ eventDate),
         eventDate3 = case_when(str_length(eventDate) == 10 ~ as.Date(eventDate, tryFormat = "%d/%m/%Y"),
                                TRUE ~ as.Date(as.numeric(eventDate), origin = "1899-12-30")),
         locality = str_squish(locality)) %>% 
  select(-eventDate) %>% 
  rename(eventDate = eventDate3)

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(path = ., sheet = 1) %>% 
  pivot_longer("Hard coral":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  select(-`...1`, -"Site.ID", -"Reef type") %>% 
  rename(verbatimDepth = Depth, locality = Site) %>% 
  mutate(verbatimDepth = as.numeric(str_remove_all(verbatimDepth, "m")),
         locality = str_to_title(locality),
         locality = str_replace_all(locality, c("Olhuveli Reef" = "Olhuveli Island",
                                                "Rahdashuhaa" = "Rahdhashuhaa")),
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate)) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
