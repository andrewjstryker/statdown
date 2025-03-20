#' Render an R Markdown file for Hugo
#'
#' This function wraps knitr's render process with knugo-specific settings.
#' @param input The path to the R Markdown file.
#' @param output The path for the rendered output.
#' @param ... Additional arguments passed to knitr::knit.
#' @export
knugo_render <- function(input, output, ...) {
  # Set up or modify knitr options here as needed
  knitr::opts_chunk$set(
    comment = NA,
    dev = "svglite",
    dpi = 300,
    fig.path = "figures/"
  )
  knitr::knit(input, output, ...)
}
