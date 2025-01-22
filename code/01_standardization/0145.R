# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0145" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)),
         decimalLongitude = -decimalLongitude)

## 2.2 Main data ----

# /!\ Data from the original .xlsx file were copied, pasted,
# and transposed to another .xlsx file to avoid issues with the dates

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

map_dfr(1:4, ~read_xlsx(data_path, sheet = .)) %>% 
  mutate(parentEventID = rep(seq(1, 4), nrow(.)/4), .after = "Site") %>% 
  rename(locality = "Site", eventDate = "Date", verbatimDepth = "Depth (m)") %>% 
  pivot_longer(5:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  filter(!(organismID %in% c("Stony Coral %", "Turf  CH (mm)", "Macro CH (mm)",
                             "Art CH (mm)", "Stony coral %"))) %>% 
  drop_na(measurementValue) %>% 
  # Standardize site names
  mutate(locality = str_remove_all(locality, "^[0-9].."),
         locality = str_squish(locality),
         locality = str_replace_all(locality, c("Pedernales-1" = "Pedernales 1",
                                                "Pedernales-2" = "Pedernales 2",
                                                "Paisiaito" = "Paisanito",
                                                "Paisianito" = "Paisanito",
                                                "El Peñon" = "El Penon",
                                                "El Peñón" = "El Penon",
                                                "Butuse Bank" = "Banco Butuse",
                                                "Banco Butuses" = "Banco Butuse",
                                                "La Bamba" = "La Bomba",
                                                "Punta Aguilas" = "Pedernales 1",
                                                "Torre Bahia" = "Pedernales 2",
                                                "Square Bank" = "Banco Cuadrado",
                                                "Restoration" = "Punta Cana restoration",
                                                "Control" = "Punta Cana control")),
         locality = ifelse(locality == "Coral Garden", "Coral Garden 1", locality)) %>%
  filter(!(locality %in% c("La Herradura", "Coral Garden 3"))) %>% 
  left_join(., data_site) %>% 
  mutate(datasetID = dataset,
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         organismID = str_replace_all(organismID, c("NCC %" = "Algae (ncc)",
                                                    "Articulated %" = "Algae articulated",
                                                    "Macro %" = "Macroalgae"))) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_coords, data_path)
