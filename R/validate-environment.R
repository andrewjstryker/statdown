  #' Validate the knugo environment
#'
#' This function checks if all required dependencies for `{knugo}` are installed.
#' If any required package is missing, it throws an informative error.
#'
#' @return Returns `TRUE` if all dependencies are met, otherwise stops execution.
#' @export
validate_environment <- function() {
  required_packages <- c("knitr", "svglite")
  
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  
  if (length(missing_packages) > 0) {
    stop(
      "The following required packages are missing: ", 
      paste(missing_packages, collapse = ", "), 
      ".\nInstall them with install.packages(c(", 
      paste(sprintf('"%s"', missing_packages), collapse = ", "), 
      ")).",
      call. = FALSE
    )
  }
  
  TRUE
}
