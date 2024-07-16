render_rmd <- function(i){
  
  if(file.exists(paste0("../output/dataset_", i, ".html")) == FALSE){
    
    render("../code/00_functions/individual_checks.Rmd", 
           output_file = paste0("dataset_", i),
           output_dir = "../output",
           quiet = TRUE)
    
  }
  
}