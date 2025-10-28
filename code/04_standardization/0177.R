# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0177" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Load site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()
  
## 2.2 Load code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx()

## 2.3 Path of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, recursive = TRUE) %>% 
  as_tibble() %>% 
  filter(str_detect(value, "form|Fish|Form|data_code|data_site") == FALSE)

## 2.4 Create a function to combine the files ----

convert_data_177 <- function(path_i){
  
  data <- read_xls(path = path_i, sheet = 1, range = "A15:P34", col_names = FALSE) %>% 
    select(-c(seq(1, 16, by = 2))) %>% 
    pivot_longer(1:ncol(.), names_to = "remove", values_to = "code") %>% 
    select(-remove) %>% 
    mutate(rownb = row_number(),
           parentEventID = case_when(rownb >= 0 & rownb <= 40 ~ 1,
                                     rownb >= 41 & rownb <= 80 ~ 2,
                                     rownb >= 81 & rownb <= 120 ~ 3,
                                     rownb >= 121 & rownb <= 160 ~ 4),
           locality = read_xls(path = path_i, sheet = 1, range = "D1:D1", col_names = FALSE) %>% 
             pull(),
           eventDate = read_xls(path = path_i, sheet = 1, range = "L2:L2", col_names = FALSE) %>% 
             pull()) %>% 
    select(-rownb) %>% 
    mutate(eventDate = as.character(eventDate))

  return(data)
  
}

## 2.5 Map over the function ----

map(data_paths$value, ~convert_data_177(path_i = .x)) %>%
  list_rbind() %>% 
  mutate(code = str_to_upper(code),
         locality = str_replace_all(locality, c("Japanease Garden" = "Japanese Garden",
                                                "JAPANES GARDEN" = "Japanese Garden",
                                                "Japanese Gaden" = "Japanese Garden",
                                                "Japanese garden" = "Japanese Garden",
                                                "JAPNESS GARDEN" = "Japanese Garden",
                                                "Marine Sceine Station" = "Marine Science Station")),
         eventDate = case_when(eventDate == "15th April 2015" ~ "2015-04-15",
                               str_detect(eventDate, "\\.") == TRUE ~ paste(str_split_fixed(eventDate, "\\.", 3)[,3],
                                                                            str_pad(str_split_fixed(eventDate, "\\.", 3)[,2],
                                                                                    width = 2, pad = "0"),
                                                                            str_split_fixed(eventDate, "\\.", 3)[,1],
                                                                            sep = "-"),
                               TRUE ~ eventDate),
         eventDate = as.Date(eventDate)) %>% 
  # Convert from number of points to percentage cover
  group_by(locality, eventDate, parentEventID, code) %>% 
  count(name = "measurementValue") %>% 
  ungroup() %>% 
  group_by(locality, eventDate, parentEventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  select(-total) %>% 
  left_join(., data_code) %>%
  select(-code) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         samplingProtocol = "Line interpect transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_data_177, data_paths, data_site, data_code)
