# 1. Required packages ----

library(tidyverse) # Core tidyverse packages
library(readxl)
library(janitor)

dataset <- "0108" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(.) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~as.numeric(.)))

## 2.2 Create a function to standardize data ----

convert_data_108 <- function(sheet_i){
  
  if(sheet_i %in% c(2010, 2011)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A4:AK71",
                col_types = "text", col_names = c("eventDate", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "abiotic - total", "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", "hard coral - total",
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "algae - total", "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "gorgonians - total",
                                                  "sponges - erect", "sponges - encrusting", "sponges - total", "cyanobacteria",
                                                  "cyanobacteria - total", "other - attached", "other - cnidaria",
                                                  "other - total")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, " total") == FALSE)
    
  }else if(sheet_i %in% c(2015, 2016, 2017, 2018, 2019)){
  
  data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
    filter(datasetID == dataset & data_type == "main") %>% 
    select(data_path) %>% 
    pull() %>% 
    read_xlsx(sheet = as.character(sheet_i), range = "A4:AW71",
              col_types = "text", col_names = c("eventDate", "locality", "coords", "dive", "parentEventID",
                                                "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                "abiotic - total", "hard coral - massive", "hard coral - branching",
                                                "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                "hard coral - unknown", "hard coral - diseased", "hard coral - total",
                                                "hard coral - massive perc", "hard coral - branching perc",
                                                "hard coral - plate foliose perc", "hard coral - fire perc", "hard coral - encrusting perc",
                                                "hard coral - unknown perc", "hard coral - diseased perc",
                                                "algae - macroalgae", "algae - turf", "algae - coralline",
                                                "algae - total", "algae - macroalgae perc", "algae - turf perc",
                                                "algae - coralline perc", "gorgonians - branching", "gorgonians - fan",
                                                "gorgonians - encrusting", "gorgonians - diseased", "gorgonians - total",
                                                "sponges - erect", "sponges - encrusting", "sponges - total", "cyanobacteria",
                                                "cyanobacteria - total", "other - attached", "other - cnidaria",
                                                "other - total")) %>% 
    janitor::remove_empty(., which = "rows") %>% 
    mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
    pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
    filter(str_detect(organismID, " total") == FALSE) %>% 
    filter(str_detect(organismID, " perc") == FALSE)
  
  }else if(sheet_i %in% c(2012, 2022, 2023, 2024)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A4:AM71",
                col_types = "text", col_names = c("eventDate", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "abiotic - total", "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", "hard coral - diseased", "hard coral - total",
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "algae - total", "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "gorgonians - diseased", "gorgonians - total",
                                                  "sponges - erect", "sponges - encrusting", "sponges - total", "cyanobacteria",
                                                  "cyanobacteria - total", "other - attached", "other - cnidaria",
                                                  "other - total")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, " total") == FALSE)
    
  }else if(sheet_i %in% c(2007)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A3:AH38",
                col_types = "text", col_names = c("eventDate", "country", "locality", "coords", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "column null 1", "hard coral - massive", "hard coral - branching",
                                                  "column null 2", "column null 3",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", 
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "algae - other algae", "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "cnidarians", 
                                                  "sponges - erect", "sponges - encrusting", "other - attached", "other - invert")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, "column null") == FALSE)
    
  }else if(sheet_i %in% c(2008)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A3:AD56",
                col_types = "text", col_names = c("eventDate", "country", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", 
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "cnidarians", 
                                                  "sponges - erect", "sponges - encrusting", "other - attached")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(11:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, "column null") == FALSE)
    
  }else if(sheet_i %in% c(2009)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A4:AD63",
                col_types = "text", col_names = c("eventDate", "country", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", 
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "cnidarians", 
                                                  "sponges - erect", "sponges - encrusting", "other - attached")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(11:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, "column null") == FALSE)
    
  }else if(sheet_i %in% c(2013)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A4:AP71",
                col_types = "text", col_names = c("eventDate", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "abiotic - total", "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", "hard coral - diseased", "hard coral - total",
                                                  "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "algae - total", "algae - macroalgae perc", "algae - turf perc",
                                                  "algae - coralline perc", "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "gorgonians - diseased", "gorgonians - total",
                                                  "sponges - erect", "sponges - encrusting", "sponges - total", "cyanobacteria",
                                                  "cyanobacteria - total", "other - attached", "other - cnidaria",
                                                  "other - total")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, " total") == FALSE) %>% 
      filter(str_detect(organismID, " perc") == FALSE)
    
  }else if(sheet_i %in% c(2014)){
    
    data_i <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
      filter(datasetID == dataset & data_type == "main") %>% 
      select(data_path) %>% 
      pull() %>% 
      read_xlsx(sheet = as.character(sheet_i), range = "A4:AT71",
                col_types = "text", col_names = c("eventDate", "locality", "coords", "dive", "parentEventID",
                                                  "length", "depth", "observer", "abiotic - rubble", "abiotic - sand silt",
                                                  "abiotic - hard substrate", "abiotic - boulder", "abiotic - dead coral",
                                                  "abiotic - total", "hard coral - massive", "hard coral - branching",
                                                  "hard coral - plate foliose", "hard coral - fire", "hard coral - encrusting",
                                                  "hard coral - unknown", "hard coral - diseased", "hard coral - total",
                                                  "hard coral - massive perc", "hard coral - branching perc",
                                                  "hard coral - plate foliose perc", "hard coral - fire perc",
                                                  "hard coral - encrusting perc", "hard coral - unknown perc",
                                                  "hard coral - diseased perc", "algae - macroalgae", "algae - turf", "algae - coralline",
                                                  "algae - total", "gorgonians - branching", "gorgonians - fan",
                                                  "gorgonians - encrusting", "gorgonians - diseased", "gorgonians - total",
                                                  "sponges - erect", "sponges - encrusting", "sponges - total", "cyanobacteria",
                                                  "cyanobacteria - total", "other - attached", "other - cnidaria",
                                                  "other - total")) %>% 
      janitor::remove_empty(., which = "rows") %>% 
      mutate(sheet = as.character(sheet_i), .before = "observer") %>% 
      pivot_longer(10:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      filter(str_detect(organismID, " total") == FALSE) %>% 
      filter(str_detect(organismID, " perc") == FALSE)
    
  }
  
  return(data_i)
  
}

## 2.3 Map over the function ----

map_dfr(c(2007:2019, 2022:2024), ~convert_data_108(sheet_i = .)) %>% 
  drop_na(locality) %>%
  select(-country, -dive, -length, -coords) %>% 
  rename(verbatimDepth = depth, recordedBy = observer) %>% 
  # Corrections and homogenization
  mutate(verbatimDepth = str_remove_all(verbatimDepth, "ft|f| ft|\\.|t"),
         verbatimDepth = str_replace_all(verbatimDepth, "/", "-"),
         verbatimDepth = case_when(verbatimDepth == 235 ~ as.numeric("23.5"),
                                   str_length(verbatimDepth) == 2 ~ as.numeric(verbatimDepth),
                                   str_length(verbatimDepth) == 5 ~ (as.numeric(str_sub(verbatimDepth, 1, 2)) +
                                     as.numeric(str_sub(verbatimDepth, 4, 5))/2)),
         verbatimDepth = round(verbatimDepth*0.3048, 1),
         parentEventID = as.numeric(parentEventID),
         locality = case_when(locality == "Beausejour Point" ~ "Beausejour",
                              locality %in% c("N.E. Deep", "N. Exposure Deep", "Northern Exposure End") ~ "Northern Exposure Deep",
                              locality %in% c("N.E. Shallow", "N. Exposure Shallow") ~ "Northern Exposure Shallow",
                              TRUE ~ locality),
         measurementValue = str_replace_all(measurementValue, "41+", "41"),
         measurementValue = as.numeric(measurementValue),
         measurementValue = replace_na(measurementValue, 0),
         eventDate = case_when(eventDate == "22. May 2007" ~ "2007-05-22",
                               eventDate == "23. May 2007" ~ "2007-05-23",
                               eventDate == "24. May 2007" ~ "2007-05-24",
                               eventDate == "25.May 2007"  ~ "2007-05-25",  
                               eventDate == "25. May 2007"  ~ "2007-05-25",
                               eventDate == "28. May 2007"  ~ "2007-05-28",
                               eventDate == "17/5/08" ~ "2008-05-17",
                               eventDate == "19/5/08" ~ "2008-05-19",      
                               eventDate == "20/5/08" ~ "2008-05-20",     
                               eventDate == "21/5/08" ~ "2008-05-21",     
                               eventDate == "22/5/08" ~ "2008-05-22",     
                               eventDate == "23/5/08" ~ "2008-05-23", 
                               eventDate == "527/2013" ~ "2013-05-27",
                               str_length(eventDate) == 5 & sheet %in% c(2007, 2008) ~
                                 as.character(as.Date(as.numeric(eventDate), origin = "1903-01-01")),
                               str_length(eventDate) == 5 & sheet %in% c(2009) ~
                                 as.character(as.Date(as.numeric(eventDate), origin = "1904-01-01")),
                               str_length(eventDate) == 5 & !(sheet %in% c(2007, 2008, 2009)) ~
                                 as.character(as.Date(as.numeric(eventDate), origin = "1900-01-01")),
                               TRUE ~ NA_character_),
         eventDate = as.Date(eventDate)) %>% 
  # Add additional variables
  left_join(., data_site) %>% 
  mutate(samplingProtocol = "Point intersect transect, 30 m transect length",
         year = year(eventDate),
         month = month(eventDate),
         day = day(eventDate),
         datasetID = dataset) %>% 
  # Convert to percentage cover
  group_by(eventDate, locality, parentEventID, verbatimDepth, decimalLatitude, decimalLongitude) %>% 
  mutate(tot = sum(measurementValue, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(measurementValue = (measurementValue*100)/tot) %>% 
  select(-sheet, -tot) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_site, convert_data_108)
