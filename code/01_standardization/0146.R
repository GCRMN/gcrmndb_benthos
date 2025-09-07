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

#### 2.2.1 List of files to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE) %>% 
  as_tibble() %>% 
  mutate(year = str_split_fixed(value, "_", 3)[,3],
         year = case_when(str_detect(year, "2019") == TRUE ~ 2019,
                          str_detect(year, "25") == TRUE ~ 2025,
                          TRUE ~ NA))

### 2.2.2 2019 data ----

#### 2.2.2.1 Create a function to combine files ----

convert_0146 <- function(path){
  
  data_results <- read_xlsx(path, sheet = 3, skip = 1) %>% 
    mutate(locality = path)
  
  return(data_results)
  
}

#### 2.2.2.2 Map over the function ----

data_2019 <- data_path %>% 
  filter(year == 2019) %>% 
  select(value) %>% 
  pull() %>% 
  map(., ~convert_0146(path = .x)) %>% 
  list_rbind() %>% 
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
         samplingProtocol = "Video transect",
         verbatimDepth = 10,
         organismID = gsub("\\s*\\([^\\)]+\\)", "", organismID),
         locality = str_remove_all(locality, "data/01_raw-data/0146/"),
         locality = str_remove_all(locality, "_2019.xlsx")) %>% 
  left_join(., data_site)

### 2.2.3 2025 data ----

#### 2.2.3.1 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2()

#### 2.2.3.2 Create a function to combine files ----

convert_0146 <- function(path){
  
  if(str_split_fixed(path, "\\.", 2)[,2] == "xlsx"){
    
    data_results <- read_xlsx(path) %>% 
      drop_na(Name) %>% 
      select("Name":"Label code") %>% 
      select(-Island) %>% 
      rename(eventID = Name, eventDate = Date, locality = Site, verbatimDepth = Transect,
             code = "Label code")
    
  }else{
    
    data_results <- read_xls(path) %>% 
      drop_na(Name) %>% 
      select("Name":"Label code") %>% 
      select(-Island) %>% 
      rename(eventID = Name, eventDate = Date, locality = Site, verbatimDepth = Transect,
             code = "Label code")
    
  }
  
  return(data_results)
  
}

#### 2.2.3.3 Map over the function ----

data_2025 <- data_path %>% 
  filter(year == 2025) %>% 
  select(value) %>% 
  pull() %>% 
  map(., ~convert_0146(path = .x)) %>% 
  list_rbind() %>%
  group_by(eventDate, locality, verbatimDepth) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  group_by(eventID, eventDate, locality, verbatimDepth, code) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         verbatimDepth = as.numeric(str_remove_all(verbatimDepth, "m")),
         locality = str_replace_all(locality, c("Bachelors Beach" = "Bachelors",
                                                "Front Porch" = "Frontporch",
                                                "Oil Slick" = "OilSlick",
                                                "ReefScientifiko" = "ReefScientifico",
                                                "Reserve" = "NoDiveReserve"))) %>% 
  group_by(eventID, eventDate, locality, verbatimDepth) %>% 
  mutate(total_n = sum(n)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (n*100)/total_n) %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-n, -total_n, -code)

### 2.2.4 Combine data ----

bind_rows(data_2019, data_2025 )%>% 
  mutate(datasetID = dataset) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_path, data_2019, data_2025, convert_0146)
