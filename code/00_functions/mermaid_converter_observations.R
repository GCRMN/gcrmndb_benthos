mermaid_converter_observations <- function(data, dataset, method){
  
  result <- data %>% 
    rename(locality = site, decimalLatitude = latitude, decimalLongitude = longitude, habitat = reef_type,
           verbatimDepth = depth, parentEventID = transect_number, organismID = benthic_attribute, eventDate = sample_date) %>% 
    select(locality, decimalLatitude, decimalLongitude, habitat, verbatimDepth, parentEventID, eventDate, organismID) %>% 
    group_by(pick(everything())) %>% 
    summarise(measurementValue = n()) %>% 
    ungroup() %>% 
    group_by(across(-c(organismID, measurementValue))) %>% 
    mutate(total = sum(measurementValue)) %>% 
    ungroup() %>% 
    mutate(measurementValue = (measurementValue*100)/total,
           datasetID = dataset,
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           samplingProtocol = method) %>% 
    select(-total)
  
  return(result)
  
}
