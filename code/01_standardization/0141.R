# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)

dataset <- "0141" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read_xlsx(.) %>% 
  rename(decimalLatitude = Lat, decimalLongitude = Long, verbatimDepth = Depth_m) %>% 
  mutate(site_name = str_split_fixed(`Site details`, "_", 3)[,2],
         site_number = str_split_fixed(`Site details`, "_", 3)[,3],
         across(c(site_name, site_number), ~str_squish(.x)),
         locality = paste0(site_name, " - ", site_number),
         # Correct issue of duplicated site number
         locality = case_when((row_number() == 4) == TRUE ~ "Shingle - 4",
                              TRUE ~ locality),
         # Correct mispelling issues
         locality = str_replace_all(locality, c("valimunai" = "Valimunai",
                                                "Thalaiyari" = "Thalayari",
                                                "Manoliputi" = "Manoliputti"))) %>% 
  select(locality, decimalLatitude, decimalLongitude, verbatimDepth)

## 2.2 Code data ----

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2()

## 2.3 List of Excel sheets to combine ----

list_sheets <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  readxl::excel_sheets(.)
  
## 2.4 Combine Excel sheets ----

map(list_sheets, ~read_xlsx(path = read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
                              filter(datasetID == dataset & data_type == "main") %>% 
                              select(data_path) %>% 
                              pull(),
                            sheet = .,
                            range = "A1:U229",
                            col_types = "text")) %>% 
  list_rbind() %>% 
  mutate(across(c("LIT_Number","Site_Number","Year", "ACB", "ACT", "ACD", "ACF", "ACE", 
                  "CM", "CS", "CB", "CF", "CE", "LCC", "Soft coral", "Algae", "CCA", "Others", "Abiotic"), ~as.numeric(.x)),
         LIT_Number = rep(c(1,2,3), nrow(.)/3)) %>%
  pivot_longer("ACB":ncol(.), names_to = "code", values_to = "measurementValue") %>% 
  filter(code != "LCC") %>% 
  rename(parentEventID = LIT_Number, year = Year) %>% 
  mutate(locality = str_squish(paste0(Island, " - ", Site_Number)),
         datasetID = dataset,
         samplingProtocol = "Line intersect transect") %>% 
  left_join(., data_site) %>% 
  left_join(., data_code) %>% 
  select(-Site_Number, -Island, -Region, -code) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(list_sheets, data_code, data_site)
