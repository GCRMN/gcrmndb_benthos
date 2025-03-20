convert_coords <- base::Vectorize(function(x){
  
  require(tidyverse)
  
  x <- str_squish(x)
  
  degree <- as.numeric(str_split_fixed(x, "°|’|'|”|\"", 4)[,1])
  minute <- as.numeric(str_replace(str_split_fixed(x, "°|’|'|”|\"", 4)[,2], ",", "."))
  second <- as.numeric(str_replace(str_split_fixed(x, "°|’|'|”|\"", 4)[,3], ",", "."))
  
  if(is.na(second)){
    
    result <- degree + (minute/60)
    
  }else{
    
    result <- degree + (minute/60) + (second/3600)
    
  }
  
  return(result)
  
})