#' Validate the statdown environment
#'
#' Checks that all required runtime dependencies are installed. Called
#' automatically by `statdown_render()` and can also be called directly.
#'
#' @return `TRUE` (invisibly) if all dependencies are met; otherwise stops with
#'   an informative error.
#' @export
validate_environment <- function() {
  required <- c("knitr", "depkit", "htmltools")
  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) > 0L) {
    stop(
      "The following required packages are missing: ",
      paste(missing, collapse = ", "),
      ".\nInstall them with install.packages(c(",
      paste(sprintf('"%s"', missing), collapse = ", "),
      ")).",
      call. = FALSE
    )
  }

  invisible(TRUE)
}
