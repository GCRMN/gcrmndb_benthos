# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(zoo)

dataset <- "0233" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., range = "D41:F59") %>% 
  rename(locality = `Reef site`, decimalLatitude = Latitude, decimalLongitude = Longitude) %>% 
  mutate(locality = str_split_fixed(locality, "\\(", 2)[,1],
         locality = str_squish(locality),
         locality = str_replace_all(locality, c("Fernando de Noronha Archipelago" = "Noronha",
                                                "Rocas Atoll" = "Rocas",
                                                "São José da Coroa Grande" = "Coroa Grande",
                                                "Maragogi" = "Maragogi",
                                                "Rio do Fogo" = "Rio Do Fogo",                                
                                                "Porto de Galinhas" = "Porto De Galinhas",
                                                "Pedra do Abaís" = "Pedra Do Abaís",
                                                "Itaparica Island" = "Itaparica",
                                                "Recife de Fora" = "Recife De Fora",
                                                "Abrolhos Archipelago" = "Abrolhos",
                                                "Tartaruga Beach" = "Tartaruga",
                                                "Forno Beach" = "Forno Beach",
                                                "Anchieta Island" = "Anchieta",
                                                "Alcatrazes Archipelago" = "Alcatrazes",
                                                "Laje de Santos" = "Laje De Santos",
                                                "Galé Island" = "Galé Island")))

## 2.2 Main data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(., range = "B2:AL33") %>% 
  rename(organismID = 1) %>% 
  pivot_longer(2:ncol(.), names_to = "locality", values_to = "measurementValue") %>% 
  filter(organismID != "species") %>% 
  mutate(year = ifelse(str_detect(locality, "\\.\\.\\.") == TRUE, 2024, 2023),
         locality = ifelse(str_detect(locality, "\\.\\.\\.") == TRUE, NA, locality),
         locality = na.locf(locality),
         locality = str_to_title(locality),
         measurementValue = as.numeric(measurementValue)*100,
         datasetID = dataset) %>% 
  left_join(., data_site) %>% 
  filter(organismID != "RLT  CORAL COVER") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site)
