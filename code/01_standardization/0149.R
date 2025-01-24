# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0149" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Data site ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 3, range = "A1:B31") %>% 
  mutate(Station = zoo::na.locf(Station),
         type = str_sub(Coordinates, start = 1, end = 1),
         type = str_replace_all(type, c("N" = "decimalLatitude",
                                        "W" = "decimalLongitude"))) %>% 
  pivot_wider(names_from = type, values_from = Coordinates) %>% 
  rename(locality = Station) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~str_remove_all(.x, "N|W")),
         across(c("decimalLatitude", "decimalLongitude"), ~str_squish(.x)),
         across(c("decimalLatitude", "decimalLongitude"), ~str_replace_all(.x, " ", "")),
         across(c("decimalLatitude", "decimalLongitude"), ~str_replace_all(.x, "o", "°")),
         across(c("decimalLatitude", "decimalLongitude"), ~str_replace_all(.x, "º", "°")),
         decimalLongitude = str_sub(decimalLongitude, 2, str_length(decimalLongitude)),
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)),
         decimalLongitude = -decimalLongitude,
         locality = str_split_fixed(locality, " ", 2)[,2],
         locality = str_replace_all(locality, c("BJack H" = "BJH",
                                                "Pirate Bay" = "Pirates",
                                                "Lit E Bay" = "LEB"))) 

## 2.2 Main data ----

data <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., sheet = 1, col_names = FALSE, range = "A1:BY130") %>% 
  drop_na(`...1`) %>% 
  filter(`...1` != "Kariwak") %>% 
  mutate(`...1` = case_when(`...1` == "Kariwak Apr 07" ~ "locality",
                            `...1` == "MAJOR CATEGORY (% of transect)" ~ "parentEventID",
                            TRUE ~ `...1`)) %>% 
  filter(!(`...1` %in% c("CORAL", "GORGONIANS", "SPONGES", "ZOANTHIDS", "MACROALGAE", "OTHER LIVE",
                       "DEAD CORAL WITH ALGAE", "CORALLINE ALGAE", "DISEASED CORALS", "SAND, PAVEMENT, RUBBLE",
                       "UNKNOWNS", "TAPE, WAND, SHADOW", "Sum (excluding tape+shadow+wand)",
                       "SUBCATEGORIES (% of transect)")))

data <- t(data) %>% 
  as_tibble(.name_repair = "unique")

colnames(data) <- data[1,]

data %>%  
  filter(parentEventID %in% c("T1", "T2", "T3")) %>% 
  pivot_longer(3:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  mutate(measurementValue = as.numeric(measurementValue),
         parentEventID = as.numeric(str_sub(parentEventID, -1, -1)),
         locality = str_remove_all(locality, " Apr 07"),
         year = 2007,
         month = 4,
         datasetID = dataset) %>% 
  filter(!(organismID %in% c("Shadow", "Tape", "Wand"))) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data, convert_coords)
