render_rmd <- function(i){
  
  render("../code/00_functions/individual_checks.Rmd", 
         output_file = paste0("dataset_", i),
         output_dir = "../output")
  
}