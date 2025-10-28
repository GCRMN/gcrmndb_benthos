# 1. Packages ----

library(tidyverse)
library(readxl)
library(pdftools)

dataset <- "0090" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  filter(row_number() == 1) %>% 
  pull() %>% 
  pdf_text() %>% 
  magrittr::extract2(3) %>% 
  str_split("\n")

data_site_col <- data_site[[1]][6]

data_site_col <- as.vector(strsplit(data_site_col, split = " ")[[1]])

data_site_col <- data_site_col[nchar(data_site_col) > 2]

data_site <- data_site[[1]][c(8:43)]

data_site <- as_tibble(data_site) %>% 
  separate(data = .,
           col = "value",
           into = c(data_site_col),
           sep = "[\\s]{3,}") %>% 
  select(Site, Latitude, Longitude, Year, Month) %>% 
  rename(decimalLatitude = Latitude,
         decimalLongitude = Longitude, year = Year, month = Month) %>% 
  mutate(month = str_replace_all(month, c("Mar" = "3",
                                          "Feb" = "2",
                                          "Oct" = "10",
                                          "Jan" = "1",
                                          "Apr" = "4")),
         Site = str_to_title(Site),
         Site = str_replace_all(Site, c("Cote" = "Boca De Cote",
                                        "Las Salinas" = "Salinas",
                                        "Cayo De Agua" = "Cayo Agua",
                                        "Dos Mosquises" = "Dos Mosquises Sur",
                                        "Madriski" = "Madrisqui",
                                        "Rabuski" = "Pelona De Rabusqui"))) %>% 
  mutate(across(c("decimalLongitude", "decimalLatitude", "year", "month"), ~as.numeric(.x)))

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  filter(row_number() == 2) %>% 
  pull() %>% 
  read.csv2() %>% 
  mutate(Site = str_replace_all(Site, "_", " "),
         Site = str_replace_all(Site, "Playa Tibur\xf3n", "Playa Tiburon"),
         Site = str_to_title(Site)) %>% 
  left_join(., data_site) %>% 
  select(-Country, -Locality) %>% 
  rename(locality = Site, recordedBy = Observer)

## 2.2 List of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, pattern = ".csv") %>% 
  as_tibble() %>% 
  rename(path = 1) %>% 
  filter(path != "data/01_raw-data/0090/Venezuela_localities.csv") %>% 
  mutate(File = str_remove_all(path, "data/01_raw-data/0090/|.rndpts.csv"),
         parentEventID = as.numeric(str_sub(File, -1, -1))) %>% 
  left_join(., data_site) %>% 
  select(-File)

## 2.3 Create a function to standardize data ----

convert_data_090 <- function(index_i){
  
  data_paths_i <- data_paths %>% 
    filter(row_number() == index_i)
  
  if(as.character(data_paths_i$path) %in% c("data/01_raw-data/0090/charagato_t4.rndpts.csv",
                                            "data/01_raw-data/0090/gabarra_t3.rndpts.csv",
                                            "data/01_raw-data/0090/gabarra_t4.rndpts.csv",
                                            "data/01_raw-data/0090/medio_t4.rndpts.csv",
                                            "data/01_raw-data/0090/norte_t1.rndpts.csv",
                                            "data/01_raw-data/0090/norte_t3.rndpts.csv",
                                            "data/01_raw-data/0090/rabusqui_t2.rndpts.csv",
                                            "data/01_raw-data/0090/salinas_t1.rndpts.csv",
                                            "data/01_raw-data/0090/sombrero_t3.rndpts.csv",
                                            "data/01_raw-data/0090/sombrero_t4.rndpts.csv")){
    
    data_i <- read.csv(as.character(data_paths_i$path), col.names = c("Image", "Path", "spp.Name", "spp.ID",
                                                                      "N.pts.per.species", "Cov..per.species",
                                                                      "N.pts.ALL.species", "Cov..ALL.species",
                                                                      "Reference.random.pts")) %>% 
      rename(eventID = Image, organismID = spp.Name, measurementValue = Cov..per.species) %>% 
      select(eventID, organismID, measurementValue) %>% 
      bind_cols(., data_paths_i)
    
  }else{
    
    data_i <- read.csv(as.character(data_paths_i$path)) %>% 
      rename(eventID = Image, organismID = spp.Name, measurementValue = Cov..per.species) %>% 
      select(eventID, organismID, measurementValue) %>% 
      bind_cols(., data_paths_i)
    
  }
  
  return(data_i)
  
}

### 2.4 Map over the function ----

map_dfr(1:nrow(data_paths), ~convert_data_090(index_i = .)) %>% 
  group_by(path) %>% 
  mutate(eventID = as.numeric(as.factor(eventID))) %>% 
  ungroup() %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat, 30 m transect length",
         verbatimDepth = 9) %>% # Based on the data paper
  select(-path) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, data_paths, convert_data_090, data_site_col)
