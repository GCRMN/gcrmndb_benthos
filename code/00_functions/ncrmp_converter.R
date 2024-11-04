ncrmp_converter <- function(data_path){
  
  data <- read_csv(as.character(data_path)) %>% 
    rename(year = YEAR, month = MONTH, day = DAY, decimalLatitude = LAT_DEGREES, decimalLongitude = LON_DEGREES,
           organismID = COVER_CAT_NAME, locality = PRIMARY_SAMPLE_UNIT) %>% 
    mutate(locality = paste0("S", locality),
           eventDate = as.Date(paste0(year, "-", month, "-", day)),
           verbatimDepth = (MIN_DEPTH+MAX_DEPTH/2),
           measurementValue = HARDBOTTOM_P+SOFTBOTTOM_P+RUBBLE_P) %>% 
    select(locality, decimalLatitude, decimalLongitude, verbatimDepth, year,
           month, day, eventDate, organismID, measurementValue)
  
  return(data)
  
}
