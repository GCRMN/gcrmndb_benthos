# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0176" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Path of files to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>%
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE, pattern = ".xls")

### 2.2 Function to combine the files ----

convert_data_176 <- function(path_i){
  
  if(str_detect(path_i, "Mexico") == TRUE){
    
    data <- read_xlsx(path = path_i, sheet = 1, na = c("", "NA")) %>% 
      mutate(BenthicCat = str_to_upper(BenthicCat)) %>% 
      left_join(., read_xlsx(path = path_i, sheet = 2, na = c("", "NA")) %>% 
                  rename(BenthicCat = 1, organismID = 2))%>% 
      left_join(., read_xlsx(path = path_i, sheet = 3, na = c("", "NA")) %>% 
                  select(2, 4) %>% 
                  rename(Site = 1, coords = 2))
    
  }else{
    
    data <- read_xlsx(path = path_i, sheet = 1, na = c("", "NA")) %>% 
      mutate(BenthicCat = str_to_upper(BenthicCat)) %>% 
      left_join(., read_xlsx(path = path_i, sheet = 2, na = c("", "NA")) %>% 
                  rename(BenthicCat = 1, organismID = 2)) %>% 
      left_join(., read_xlsx(path = path_i, sheet = 3, na = c("", "NA")) %>% 
                  select(2, 5) %>% 
                  rename(Site = 1, coords = 2))
    
  }
  
  return(data)
  
}

### 2.3 Map over the function ----

map_dfr(data_paths, ~convert_data_176(.x)) %>% 
  mutate(coords = str_remove_all(coords, "N |W |°N|°W|,"),
         coords = str_replace_all(coords, " ", " - "),
         decimalLatitude = str_split_fixed(coords, " - ", 2)[,1],
         decimalLongitude = str_split_fixed(coords, " - ", 2)[,2],
         decimalLongitude = case_when(Site == "ALD" ~ "87.49841",
                                      TRUE ~ decimalLongitude),
         decimalLatitude = case_when(Site == "ALD" ~ "15.86496",
                                     TRUE ~ decimalLatitude),
         across(c(decimalLatitude, decimalLongitude), ~as.numeric(.x)),
         decimalLongitude = ifelse(decimalLatitude > 5, -decimalLongitude, decimalLongitude),
         Species = case_when(!is.na(Genus) & !is.na(Species) ~ paste0(Genus, " ", Species),
                                is.na(Genus) & is.na(Species) ~ NA,
                                !is.na(Genus) & is.na(Species) ~ Genus),
         Species = str_squish(Species),
         Species = ifelse(Species == "", NA, Species),
         Species = ifelse(Species == "d", NA, Species),
         organismID = case_when(organismID == "Turf Algae" & !is.na(Species) ~ paste0(organismID, " - ", Species),
                                Species %in% c("Tubinaria", "Turbinaria spp.",
                                               "Turbinaria", "Fuzz ball", "Other") ~ paste0(organismID, " - ", Species),
                                is.na(Species) ~ organismID,
                                TRUE ~ Species)) %>% 
  select(Site, Transect, decimalLatitude, decimalLongitude, Year, organismID, Depth) %>% 
  rename(locality = Site, parentEventID = Transect, year = Year, verbatimDepth = Depth) %>% 
  group_by(locality, parentEventID, year, decimalLatitude, decimalLongitude, verbatimDepth, organismID) %>% 
  count() %>% 
  ungroup() %>% 
  group_by(locality, parentEventID, year, decimalLatitude, decimalLongitude, verbatimDepth) %>% 
  mutate(total = sum(n)) %>%
  ungroup() %>% 
  filter(total != 1) %>% 
  mutate(measurementValue = (n*100)/total,
         datasetID = dataset,
         samplingProtocol = "Point intercept transect") %>% 
  select(-total, -n) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(convert_data_176, data_paths)
