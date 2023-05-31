mermaid_converter_sampleunits <- function(data){
  
  split_benthic_categories <- function(data){
    
    result <- str_split_fixed(data$percent_cover_by_benthic_category_avg, ",", n = Inf)
    
    result <- tibble(raw = as.vector(result)) %>% 
      mutate(organismID = str_squish(str_split_fixed(raw, ": ", 2)[,1]), 
             measurementValue = str_split_fixed(raw, ": ", 2)[,2]) %>% 
      mutate_all(., ~str_replace_all(.x, "\\{|\\'|\\}", "")) %>% 
      mutate(measurementValue = as.numeric(measurementValue)) %>% 
      select(-raw)
    
    return(result)
    
  }
  
  mermaid_reformat <- function(data){
    
    result <- bind_cols(data, split_benthic_categories(data))
    
    return(result)
    
  }
  
  mermaid_reformat(data) %>% 
    select(project_id, site_name, latitude, longitude, sample_date_year, 
           sample_date_month, sample_date_day, depth_avg, organismID, measurementValue) %>% 
    rename(decimalLatitude = latitude, decimalLongitude = longitude, year = sample_date_year,
           month = sample_date_month, day = sample_date_day, verbatimDepth = depth_avg, locality = site_name) %>% 
    mutate(eventDate = as_date(paste(year, month, day, sep = "-")))
  
}