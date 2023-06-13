data_descriptors <- function(data){
  
  # Number of sites 
  
  nb_sites <- data %>% 
    select(decimalLongitude, decimalLatitude) %>%
    distinct() %>% 
    count(name = "nb_sites")
  
  # Number of surveys
  
  nb_surveys <- data %>% 
    select(decimalLongitude, decimalLatitude, year, month, eventDate) %>%
    distinct() %>% 
    count(name = "nb_surveys")
  
  # Number of individual datasets
  
  nb_datasets <- data %>% 
    select(datasetID) %>%
    distinct() %>% 
    count(name = "nb_datasets")
  
  # First and last year with data
  
  first_last_year <- data %>% 
    mutate(first_year = min(year),
           last_year = max(year)) %>% 
    select(first_year, last_year) %>% 
    distinct()
  
  # Return the results
  
  if (is.grouped_df(data) == TRUE) {
    
    result <- nb_sites %>% 
      left_join(., nb_surveys) %>% 
      left_join(., nb_datasets) %>% 
      left_join(., first_last_year)
    
  }else{
    
    result <- bind_cols(nb_sites, nb_surveys, nb_datasets, first_last_year)
    
  } 
  
  return(result)
  
}