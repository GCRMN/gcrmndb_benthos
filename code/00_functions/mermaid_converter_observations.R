mermaid_converter_observations <- function(data, dataset, method){
  
  if(method == "Photo-quadrat"){
  
  result <- data %>% 
    rename(locality = site, habitat = reef_zone, decimalLatitude = latitude,
           decimalLongitude = longitude, verbatimDepth = depth, eventDate = sample_date,
           parentEventID = transect_number, eventID = quadrat_number, recordedBy = observers,
           measurementValue = num_points) %>% 
    mutate(organismID = case_when(benthic_attribute == benthic_category ~ benthic_category,
                                  benthic_attribute != benthic_category ~ paste(benthic_category,
                                                                                benthic_attribute, sep = " - ")),
           year = year(eventDate),
           month = month(eventDate),
           day = day(eventDate),
           datasetID = dataset,
           samplingProtocol = method) %>% 
    select(datasetID, locality, habitat, parentEventID, eventID, decimalLatitude,
           decimalLongitude, verbatimDepth, year, month, day, eventDate, samplingProtocol,
           recordedBy, organismID, measurementValue) %>% 
    group_by(datasetID, locality, habitat, parentEventID, eventID, decimalLatitude,
             decimalLongitude, verbatimDepth, year, month, day, eventDate, samplingProtocol,
             recordedBy) %>% 
    mutate(measurementValue = (measurementValue*100)/sum(measurementValue)) %>% 
    ungroup()
  
  }else if(method == "Point intersect transect"){
    
    result <- data %>% 
      rename(locality = site, habitat = reef_zone, decimalLatitude = latitude,
             decimalLongitude = longitude, verbatimDepth = depth, eventDate = sample_date,
             parentEventID = transect_number, recordedBy = observers) %>% 
      mutate(organismID = case_when(benthic_attribute == benthic_category ~ benthic_category,
                                    benthic_attribute != benthic_category ~ paste(benthic_category,
                                                                                  benthic_attribute, sep = " - "))) %>% 
      select(locality, habitat, decimalLatitude, decimalLongitude, verbatimDepth, eventDate,
             parentEventID, interval, organismID, recordedBy) %>% 
      group_by(across(c(-interval))) %>% 
      count() %>% 
      ungroup() %>% 
      group_by(across(c(-organismID, -n))) %>% 
      mutate(total = sum(n)) %>% 
      ungroup() %>% 
      mutate(measurementValue = (n*100)/total,
             year = year(eventDate),
             month = month(eventDate),
             day = day(eventDate),
             datasetID = dataset,
             samplingProtocol = method) %>% 
      select(-n, -total)
    
  }
  
  return(result)
  
}
