# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0146" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2() %>% 
  # Same coordinates than datasetID 0098,
  # add a very small number to avoid getting 200 % of
  # percentage cover per sampling unit later
  mutate(decimalLongitude = -decimalLongitude,
         decimalLatitude = decimalLatitude + 0.00001,
         decimalLongitude = decimalLongitude + 0.00001)

## 2.2 Main data ----

### 2.2.1 List of files to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, pattern = "xlsx")

### 2.2.2 Create a function to combine files ----

convert_0146 <- function(path){
  
  data_results <- read_xlsx(path, sheet = 3, skip = 1) %>% 
    mutate(locality = path)
  
  return(data_results)
  
}

### 2.2.3 Map over the function ----

map_dfr(data_path, ~convert_0146(path = .)) %>% 
  select(-"...1", -"X", -"Y", -"Major Categories (% of photo excluding TWS)", -"Coral...6",
         -"Gorgonians...7", -"Sponges...8", -"Zoanthids...9", -"Macroalgae...10", -"Other live...11",
         -"Dead coral with Algae...12", -"Coralline Algae...13", -"Diseased corals...14", -"Sand, pavement, rubble...15",
         -"Unknowns...16", -"Tape, wand, shadow...17", -"Number of points classified in image",
         -"Sub-Categories (% of photo excluding TWS)", -"Coral...20", -"Unknowns...127", -"Unknown (UNK)",
         -"Tape, wand, shadow...129", -"Shadow (SHAD)", -"Tape (TAPE)", -"Wand (WAND)",
         -"NOTES (% of image)", -"Cyanobacteria", -"Aspergillus", -"Bleached coral point",
         -"Black Band Disease", -"Other disease", -"Plague, Type II (White Plague, Type II)",
         -"White Band Disease", -"Yellow Blotch Disease", -"Gorgonians...75", -"Zoanthids...90",
         -"Macroalgae...93", -"Sponges...88", -"Other live...110", -"Sand, pavement, rubble...123",
         -"Dead coral with Algae...114", -"Diseased corals...121", -"Coralline Algae...119") %>% 
  pivot_longer(2:98, values_to = "measurementValue", names_to = "organismID") %>% 
  rename(eventID = `Photo Name`) %>% 
  group_by(locality) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  group_by(locality, eventID) %>% 
  mutate(total = sum(measurementValue)) %>% 
  ungroup() %>% 
  # Remove data for which the sum per quadrat is lower than 99
  # (because of "Unknowns" category), categories as 0 not as NA
  filter(total >= 99) %>% 
  select(-total) %>% 
  mutate(year = 2019,
         datasetID = dataset,
         samplingProtocol = "Video transect",
         verbatimDepth = 10,
         organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID),
         locality = str_remove_all(locality, "data/01_raw-data/0146/"),
         locality = str_remove_all(locality, "_2019.xlsx")) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_path, convert_0146)
