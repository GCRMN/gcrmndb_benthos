# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0154" # Define the dataset_id

# 2. Import, standardize and export the data ----

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  read_xls() %>% 
  drop_na(Recordkey) %>% 
  select(-c("PercentTotalCoral Includes Millepora?", "PercentTotalCoral", "TotalAlgalCover",
         "TotalAlgalCover SD", "TotalMacroalgalCover SD", "Macroalgae - Fleshy", "Percent Other Living",
         "SD...85", "TotalMacroalgae includes Lobophora?", "Macroalgae - Erect Calcareous",
         "SD...88", "TotalMacroalgae Includes Erect Calcareous?", "SD...91", "SD...93",
         "SD...95", "SD...97", "SD...99", "SD...101", "SD...103", "SD...105", "SD...107")) %>% 
  pivot_longer("Acropora cervicornis":ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
  rename(decimalLatitude = "Latitude (N)", decimalLongitude = "Longitude (W)", parentEventID = TransectID,
         locality = "ReefSite", year = "StartDate (MM/DD/YY)", verbatimDepth = "MedianDepth") %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth, parentEventID,
         year, organismID, measurementValue) %>% 
  mutate(decimalLatitude = as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,1]) +
           as.numeric(str_split_fixed(decimalLatitude, " ", 2)[,2])/60,
         decimalLongitude = as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,1]) +
           as.numeric(str_split_fixed(decimalLongitude, " ", 2)[,2])/60,
         decimalLongitude = -decimalLongitude) %>% 
  mutate(samplingProtocol = "Video transect, 25 m transect length",
         datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)
