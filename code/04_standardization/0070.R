# 1. Packages ----

library(tidyverse)
library(readxl)

dataset <- "0070" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 List of datasets to combine ----

data_path <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull()

files_list <- list.files(data_path, pattern = ".xls", full.names = TRUE)

files_list <- tibble(path = c(files_list, files_list),
                     sheet = c(rep(1, 6), rep(2, 6)),
                     verbatimDepth = c(rep(4, 6), rep(9, 6))) %>% 
  mutate(locality = str_split_fixed(path, "/", 4)[,4],
         locality = str_remove_all(locality, "Video.xlsx|Video.xls"),
         locality = str_replace_all(locality, c("CatIsld" = "Cat Island",
                                                "KhayranPor" = "Khayran")),
         # Add latitude and longitude as provided in the README file
         # For Khayran 5 m, longitude "58.539373" replaced by "58.739373"
         decimalLatitude = case_when(locality == "NicksBay" & sheet == 1 ~ 23.507529,
                                     locality == "NicksBay" & sheet == 2 ~ 23.507411,
                                     locality == "Fahl" & sheet == 1 ~ 23.679288,
                                     locality == "Fahl" & sheet == 2 ~ 23.679187,
                                     locality == "Cat Island" & sheet == 1 ~ 23.585648,
                                     locality == "Cat Island" & sheet == 2 ~ 23.585636,
                                     locality == "Jissah" & sheet == 1 ~ 23.557325,
                                     locality == "Jissah" & sheet == 2 ~ 23.557218,
                                     locality == "Khayran" & sheet == 1 ~ 23.526252,
                                     locality == "Khayran" & sheet == 2 ~ 23.526264),
         decimalLongitude = case_when(locality == "NicksBay" & sheet == 1 ~ 58.761507,
                                      locality == "NicksBay" & sheet == 2 ~ 58.761513,
                                      locality == "Fahl" & sheet == 1 ~ 58.501617,
                                      locality == "Fahl" & sheet == 2 ~ 58.501695,
                                      locality == "Cat Island" & sheet == 1 ~ 58.609077,
                                      locality == "Cat Island" & sheet == 2 ~ 58.608952,
                                      locality == "Jissah" & sheet == 1 ~ 58.650562,
                                      locality == "Jissah" & sheet == 2 ~ 58.650602,
                                      locality == "Khayran" & sheet == 1 ~ 58.739177,
                                      locality == "Khayran" & sheet == 2 ~ 58.739373)) %>%  
  filter(locality != "Sifah")

## 2.2 Create a function to combine the datasets ----

convert_data_070 <- function(row_nb){
  
  files_list_i <- files_list %>% filter(row_number() == row_nb)
  
  data <- read_xlsx(path = files_list_i$path, sheet = files_list_i$sheet, range = "A1:BD132")
  
  if(files_list_i$locality == "Cat Island" & files_list_i$sheet == 2){
    
    data <- data %>% 
      rename("2007" = "2007Sept",
             "2008" = "Octobre 2008",
             "2009" = "38352")
    
  }else if(files_list_i$locality == "Fahl" & files_list_i$sheet == 2){
    
    data <- data %>% 
      rename("X12" = "2004",
             "2004" = "...8",
             "X13" = "2006",
             "2006" = "...13",
             "2007" = "Spt2007")
    
  }else if(files_list_i$locality == "Fahl" & files_list_i$sheet == 1){
    
    data <- data %>% 
      rename("X12" = "2003",
             "2003" = "...3",
             "X13" = "2004",
             "2004" = "...8",
             "X14" = "2006",
             "2006" = "...13",
             "2007" = "37864",
             "2008" = "sept 08",
             "2009" = "Jan 2009")
    
  }else if(files_list_i$locality == "Jissah" & files_list_i$sheet == 1){
    
    data <- data %>% 
      rename("X12" = "2003",
             "2003" = "...3",
             "X13" = "2004",
             "2004" = "...8",
             "2007" = "2007 Sept",
             "2008" = "2008 Sept",
             "2009" = "38384")
    
  }else if (files_list_i$locality == "Khayran" & files_list_i$sheet == 1){
    
    data <- data %>% 
      rename("2007" = "2007Sept",
             "2008" = "Octobre 2008",
             "2009" = "38352")
    
  }else if (files_list_i$locality == "NicksBay" & files_list_i$sheet == 1){
    
    data <- data %>% 
      rename("2007" = "2007Sept",
             "2008" = "Octobre 2008",
             "2009" = "38383")
    
  }else{
    
    data <- data
    
  }
  
  result <- data %>% 
    purrr::discard(~all(is.na(.))) %>%  
    mutate(organismID = case_when(`...1` == "Genus" ~ NA_character_,
                                  `...1` != "Genus" & !(is.na(`...1`)) & !(is.na(`...2`)) ~ paste(`...1`, `...2`),
                                  `...1` != "Genus" & !(is.na(`...1`)) & is.na(`...2`) ~ `...1`,
                                  TRUE ~ NA_character_), .before = 1) %>% 
    filter(!(is.na(organismID))) %>% 
    select(-`...1`, -`...2`) %>% 
    pivot_longer(2:ncol(.), names_to = "year", values_to = "measurementValue") %>% 
    mutate(parentEventID = rep(1:4, nrow(.)/4),
           measurementValue = as.numeric(measurementValue),
           measurementValue = ifelse(is.na(measurementValue), 0, measurementValue),
           year = as.numeric(year)) %>% 
    fill(year) %>% 
    mutate(locality = files_list_i$locality,
           verbatimDepth = files_list_i$verbatimDepth,
           decimalLongitude = files_list_i$decimalLongitude,
           decimalLatitude = files_list_i$decimalLatitude)
  
  return(result)
  
}

## 2.3 Map over the function ----

data_all <- map_dfr(1:nrow(files_list), ~convert_data_070(row_nb = .))

## 2.4 Add dataset for Sifah ----

data_sifah <- read_xls(path = paste0(data_path, "SifahVideo.xls"), sheet = 1, range = "A1:U132") %>% 
  purrr::discard(~all(is.na(.))) %>%  
  rename("2003" = "...3") %>% 
  mutate(organismID = case_when(`...1` == "Genus" ~ NA_character_,
                                `...1` != "Genus" & !(is.na(`...1`)) & !(is.na(`...2`)) ~ paste(`...1`, `...2`),
                                `...1` != "Genus" & !(is.na(`...1`)) & is.na(`...2`) ~ `...1`,
                                TRUE ~ NA_character_), .before = 1) %>% 
  filter(!(is.na(organismID))) %>% 
  select(-`...1`, -`...2`) %>% 
  pivot_longer(2:ncol(.), names_to = "year", values_to = "measurementValue") %>% 
  mutate(parentEventID = rep(1:4, nrow(.)/4),
         measurementValue = as.numeric(measurementValue),
         measurementValue = ifelse(is.na(measurementValue), 0, measurementValue),
         year = as.numeric(year)) %>% 
  fill(year) %>% 
  mutate(verbatimDepth = 4,
         locality = "Sifah",
         decimalLatitude = 23.420425,
         decimalLongitude = 58.792597)

## 2.5 Combine and export ----

bind_rows(data_all, data_sifah) %>% 
  mutate(datasetID = dataset,
         # Add months as provided in the README file
         month = case_when(year == 2003 ~ 9,
                           year == 2004 ~ 12,
                           year == 2006 ~ 12,
                           year == 2007 ~ 10,
                           year == 2008 ~ 9,
                           year == 2009 ~ 2,
                           year == 2010 ~ 10,
                           year == 2011 ~ 10,
                           year == 2012 ~ 12,
                           year == 2014 ~ 2,
                           year == 2015 ~ 3),
         samplingProtocol	= "Video transect, 50 m long, 100 points per transect") %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_all, data_sifah, files_list)
