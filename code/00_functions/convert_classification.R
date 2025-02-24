convert_classification <- function(data, i){
  
  result <- data[[i]]
  
  if(length(result) == 1){
    
    result <- tibble(organismID = names(data)[i],
                     category = NA,
                     subcategory = NA,
                     condition = NA)
    
  }else{
    
    result <- result %>% 
      as_tibble() %>%
      mutate(rank = str_replace_all(rank, c("Phylum \\(Division\\)" = "Phylum")),
             rank = str_to_lower(rank)) %>%
      filter(rank %in% c("phylum", "class", "subclass", "order", "family", "genus", "species")) %>% 
      pivot_wider(names_from = "rank", values_from = "name") %>% 
      mutate(organismID = names(data)[i], .before = "phylum") %>% 
      mutate(category = NA, subcategory = NA, condition = NA, .after = organismID)
    
  }
  
  return(result)
  
}
