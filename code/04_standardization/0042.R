# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl) # To read excel files

dataset <- "0042" # Define the dataset_id

# 2. Import, standardize and export the data ----

# 2.1 Dates data --

data_date <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  select(Date, site, latitude, longitude) %>% 
  distinct() %>% 
  rename(locality = site) %>% 
  mutate(year = str_sub(Date, -4, -1),
         month = case_when(Date == "April 2013" ~ "04",
                           Date == "June 2013" ~ "06",
                           Date == "October 2013" ~ "10",
                           Date == "September 2013" ~ "09",
                           Date == "March 2013" ~ "03"),
         month = as.numeric(month),
         locality = str_replace_all(locality, " ", "")) %>% 
  select(locality, year, month)

# 2.2 Code data --

data_code <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "code") %>% 
  select(data_path) %>% 
  pull() %>%
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  select(-2) %>% 
  rename(code = ID, organismID = "Unique ID") %>% 
  mutate(code = str_replace_all(code, "HELIO\\* species change", "HELIO")) %>% 
  mutate(organismID = str_remove_all(organismID, c(" counts|All ")))
  
# 2.3 Main data --

read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  # Read the file
  read_xlsx(., sheet = 1) %>% 
  filter(GT != "Grand Total") %>% # Remove second row with column labels
  select(Lat, Long, DepthCode, SiteCode, GT, # Other variables
         BS, IT, CCA, CY, E, M, "T", TS, # Non coral categories
         ACAN, ACRO, ALVE, ANAC, ASTR, BLAS, CAUL, CNEL, COEL, COSC, CTEL,
         CTEN, CYPH, DIPL, ECHN, ENOP, EPHY, EUPH, FUNG, FVIA, FVIT, GALA,
         GARD, GNIA, GONI, HALO, HELI, HELIO, HERP, HYDN, ISOP, LOBO, LORI,
         LPTA, LPTO, MADR, MERU, MILL, MNTA, MNTI, MYCE, NEOP, OULO, OXYP,
         PACH, PARA, PAVO, PECT, PHYS, PLAY, PLES, PLRO, POCI, PODA, POLY,
         PORI, PSAM, SAND, SCAP, SCOE, SCOL, SERI, STYL, STYS, SYMP, TRAC,
         TUBA, TUBI, TURB, ZOOP) %>% # Coral categories 
  pivot_longer(6:ncol(.), names_to = "code", values_to = "measurementValue") %>% 
  filter(measurementValue > 0) %>% # Remove two "-1" value for BS category
  group_by(Lat, Long, DepthCode, SiteCode, GT) %>% 
  mutate(total = sum(measurementValue, na.rm = TRUE)) %>% 
  ungroup() %>% 
  # Stop code here to check if GT (grand total) is equal to the observed total
  drop_na(measurementValue) %>% 
  mutate(measurementValue = (measurementValue*100)/total) %>% 
  rename(locality = SiteCode, decimalLatitude = Lat,
         decimalLongitude = Long, verbatimDepth = DepthCode) %>% 
  mutate(parentEventID = str_split_fixed(locality, "_", 3)[,3],
         parentEventID = as.numeric(str_remove_all(parentEventID, "T")),
         locality = str_split_fixed(locality, "_", 3)[,1],
         verbatimDepth = as.numeric(gsub("\\D", "", verbatimDepth)),
         datasetID = dataset) %>% 
  # Randomly generate verbatimDepth based on depth range
  # D1 = <8m, D2 = 8-13m, D3 = 14-18m, D4 = 19-25m, D5 = >25m
  rowwise() %>% 
  mutate(verbatimDepth = case_when(verbatimDepth == 1 ~ sample(1:7, size = 1),
                                   verbatimDepth == 2 ~ sample(8:13, size = 1),
                                   verbatimDepth == 3 ~ sample(14:18, size = 1),
                                   verbatimDepth == 4 ~ sample(19:25, size = 1),
                                   verbatimDepth == 5 ~ sample(25:30, size = 1),
                                   TRUE ~ NA)) %>% 
  ungroup() %>% 
  # Reverse values of lat and long for some rows
  mutate(decimalLongitude2 = ifelse(decimalLatitude > 80, decimalLatitude, NA),
         decimalLatitude2 = ifelse(decimalLatitude > 80, decimalLongitude, NA),
         decimalLongitude = coalesce(decimalLongitude2, decimalLongitude),
         decimalLatitude = if_else(decimalLatitude > 80, decimalLatitude2, decimalLatitude)) %>% 
  select(-decimalLongitude2, -decimalLatitude2) %>% 
  left_join(., data_code) %>% 
  select(-total, -GT, -code) %>% 
  left_join(., data_date) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_date, data_code)
