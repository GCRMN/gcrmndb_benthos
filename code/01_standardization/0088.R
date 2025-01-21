# 1. Packages ----

library(tidyverse)
library(readxl)

source("code/00_functions/convert_coords.R")

dataset <- "0088" # Define the dataset_id

# 2. Import, standardize and export the data ----

## 2.1 Site data ----

data_site <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "site") %>% 
  select(data_path) %>% 
  pull() %>% 
  read.csv2(.) %>% 
  mutate(across(c("decimalLatitude", "decimalLongitude"), ~str_remove_all(.x, "N|W")),
         across(c("decimalLatitude", "decimalLongitude"), ~convert_coords(.x)),
         decimalLongitude = -decimalLongitude)

## 2.2 List of files and path to combine ----

data_paths <- read_csv("data/01_raw-data/benthic-cover_paths.csv") %>% 
  filter(datasetID == dataset & data_type == "main") %>% 
  select(data_path) %>% 
  pull() %>% 
  list.files(full.names = TRUE) %>% 
  as_tibble(.) %>% 
  filter(str_detect(value, ".csv") == FALSE) %>% 
  rename(path = value) %>% 
  mutate(locality = str_remove_all(path, "data/01_raw-data/0088/"),
         locality = str_remove_all(locality, ".xlsx"),
         locality = str_remove_all(locality, "Quadrats"),
         locality = str_trim(locality),
         year = str_sub(locality, -4, -1),
         locality = str_trim(str_remove_all(locality, "[0-9]|\\_")),
         locality = case_when(locality == "Andes Reef" ~ "Andes",
                              locality == "Seaview Reef" ~ "Seaview",
                              locality == "Oro Verde Reef" ~ "Oro Verde",
                              locality == "Deep Control West" ~ "DCW",
                              locality == "Shallow Control west" ~ "SCW",
                              locality == "BigTunnels" ~ "Big Tunnels",
                              locality == "IronshoreGardens" ~ "Ironshore Gardens",
                              locality == "OroVerde" ~ "Oro Verde",
                              locality == "PinnacleReef" ~ "Pinnacles Reef",
                              locality == "PinnaclesReef" ~ "Pinnacles Reef",
                              locality == "McKenny's Canyon" ~ "Mc Kennys Canyon",
                              locality == "McKennysCanyon" ~ "Mc Kennys Canyon",
                              locality == "TarponTaproom" ~ "Tarpon Taproom",
                              TRUE ~ locality)) %>% 
  arrange(locality, year)

## 2.3 Create a function to standardize data ----

convert_data_088 <- function(index_i){
  
  data_paths_i <- data_paths %>% 
    filter(row_number() == index_i)
  
  if(str_detect(as.character(data_paths_i$path), "2023") == FALSE){
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path), sheet = 3, skip = 1) %>% 
      select("...1", "Antipatharia (ANTI)", "Briareidae (BRIA)", "Encrusting Gorgonian (ENGO)", "Gorgonian (GORG)",
             "Plexauridae (PLEX)", "Soft coral (SOFT)", "Acropora cervicornis (ACER)", "Acropora palmata (APAL)",
             "Acropora prolifera (APRO)", "Agaracia agaricites (AAGA)", "Agaricia species (AGAR)",
             "Colpophyllia natans (CNAT)", "Coral general (CORAL)", "Coral juvenile (CJUV)", "Dendrogyra cylindrus (DCYL)",
             "Dichocoenia stellaris (DSTE)", "Dichocoenia stokesii (DSTO)", "Diploria clivosa (DCLI)",
             "Diploria labyrinthiformis (DLAB)", "Diploria strigosa (DSTR)", "Eusmilia fastigiata (EFAS)", "Favia fragum (FFRA)",
             "Isophyllastrea rigida (IRIG)", "Isophyllia sinuosa (ISIN)", "Leptoseris cucullata (LCUC)", "Madracis decactis (MDEC)", 
             "Madracis formosa (MFOR)", "Madracis mirabilis (MMIR)", "Madracis pharensis (MPHA)",
             "Madracis species (MADR)", "Manicina areolata (MARE)", "Meandrina meandrites (MMEA)",
             "Millepora alcicornis (MALC)", "Millipora complanata (MCOM)", "Millipora squarrosa (MSQU)",
             "Montastraea annularis (MANN)", "Montastraea cavernosa (MCAV)", "Montastraea faveolata (MFAV)", 
             "Montastraea franksi (MFRA)", "Montastraea species (MONT)", "Mussa angulosa (MANG)",
             "Mycetophyllia aliciae (MALI)", "Mycetophyllia danaana (MDAN)", "Mycetophyllia ferox (MFER)", 
             "Mycetophyllia lamarckiana (MLAM)", "Oculina diffusa (ODIF)", "Porites astreoides (PAST)",
             "Porites branneri (PBAN)", "Porites colonensis (PCOL)", "Porites divaricata (PDIV)",
             "Porites furcata (PFUR)", "Porites porites (PPOR)", "Porites species (PORI)", 
             "Scolymia cubensis (SCUB)", "Scolymia species (SCOL)", "Siderastrea radians (SRAD)", 
             "Siderastrea siderea (SSID)", "Solenastrea bournoni (SBOU)", "Solenastrea hyades (SHYA)",
             "Stephanocoenia intersepts (SINT)", "Tubastraea aurea (TAUR)",
             "Cliona sponge (CLSP)", "Encrusting sponge (ENSP)", "Erect sponge (ERSP)", "Other Zoanthid (ZOAN)",
             "Palythoa sp. (PALY)", "Tunicate (TUNI)", "Amphiroa (AMPH)", "Dictyota (DICT)", "Halimeda (HALI)",
             "Liagora (LIAG)", "Lobophora (LOBO)", "Macroalgae general (MALG)", "Microdictyon (MICR)", "Padina (PADI)",
             "Porolithon (PORO)", "Sargassum (SARG)", "Schizothrix (SCHIZ)", "Stypopodium (STYP)",
             "Turbinaria (TURB)", "Turf (TURF)", "Ascidian (ASCI)", "Other (OTHR)",
             "Dead coral with algae (DCA)", "Old dead coral (ODC)", "Recently dead coral (RDC)",
             "Crustose Coralline algae (CCA)", "Dead gorgonian (DG)", "Bare rock (ROCK)",
             "Rubble (RUBB)", "Rubble with turf (RWT)", "Sand (SAND)", "holes, gaps, overhangs (GAPS)", "Unknown (UNK)") %>% 
      pivot_longer(2:ncol(.), names_to = "organismID", values_to = "measurementValue") %>% 
      rename(eventID = "...1") %>% 
      bind_cols(., data_paths_i)
    
  }else if(as.character(data_paths_i$path) == "data/01_raw-data/0088/Shallow Control west 2023.xlsx"){
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path), sheet = "Data Summary",
                        range = "A28:W126", col_names = c("organismID", paste0("Q", seq(1:22)))) %>% 
      pivot_longer(2:ncol(.), names_to = "eventID", values_to = "measurementValue") %>% 
      bind_cols(., data_paths_i) %>% 
      mutate(eventID = as.numeric(str_remove_all(eventID, "Q")))
    
  }else if(as.character(data_paths_i$path) %in% c("data/01_raw-data/0088/Ironshore Gardens 2023.xlsx",
                                                  "data/01_raw-data/0088/Pallas Reef 2023.xlsx")){
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path), sheet = "Data Summary",
                        range = "A28:S126", col_names = c("organismID", paste0("Q", seq(1:18)))) %>% 
      pivot_longer(2:ncol(.), names_to = "eventID", values_to = "measurementValue") %>% 
      bind_cols(., data_paths_i) %>% 
      mutate(eventID = as.numeric(str_remove_all(eventID, "Q")))
    
  }else{
    
    data_i <- read_xlsx(path = as.character(data_paths_i$path), sheet = "Data Summary",
                        range = "A28:U126", col_names = c("organismID", paste0("Q", seq(1:20)))) %>% 
      pivot_longer(2:ncol(.), names_to = "eventID", values_to = "measurementValue") %>% 
      bind_cols(., data_paths_i) %>% 
      mutate(eventID = as.numeric(str_remove_all(eventID, "Q")))
    
  }
  
  return(data_i)
  
}

### 2.4 Map over the function ----

map_dfr(1:nrow(data_paths), ~convert_data_088(index_i = .)) %>% 
  drop_na(organismID, measurementValue) %>% 
  mutate(datasetID = dataset,
         samplingProtocol = "Photo-quadrat",
         organismID = str_remove(organismID, "\\s*\\([^\\)]+\\)")) %>% 
  select(-path) %>% 
  left_join(., data_site) %>% 
  write.csv(., file = paste0("data/02_standardized-data/", dataset, ".csv"), row.names = FALSE)

# 3. Remove useless objects ----

rm(data_paths, convert_data_088, data_site, convert_coords)
