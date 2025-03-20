#' Render an R Markdown file for Hugo
#'
#' This function wraps `knitr::knit()` to render `.Rmd` or `.Rmarkdown` files 
#' into plain Markdown (`.md`), which is the expected format for Hugo. 
#' It automatically determines the output filename by replacing the input 
#' extension with `.md`. The function ensures a controlled environment 
#' by setting the appropriate knitr options while allowing users to specify 
#' whether the rendering should be quiet.
#'
#' @param input A character string specifying the input file (must have `.Rmd` 
#'   or `.Rmarkdown` extension).
#' @param quiet A logical value indicating whether to suppress knitr output 
#'   messages (default: `FALSE`).
#'
#' @return The function renders the file but does not return a value.
#' @export
#'
#' @examples
#' # Render an Rmd file for Hugo
#' knugo_render("content/post/example.Rmd")
#'
#' # Render quietly
#' knugo_render("content/post/example.Rmarkdown", quiet = TRUE)
knugo_render <- function(input, quiet = FALSE) {
  output <- sub("\\.(Rmd|Rmarkdown)$", ".md", input, ignore.case = TRUE)

  set_required_options()
  set_suggested_options()
  
  # Call knitr::knit with constrained options
  knitr::knit(
    input = input,
    output = output,
    tangle = FALSE,
    text = NULL,
    quiet = quiet,
    envir = parent.frame(),
    encoding = "UTF-8"
  )
}

set_required_options <-
  function() {
    knitr::opts_chunk$set(
      dev = "svglite",        # Use SVG for plots
      fig.path = "",          # Save figures in the working directory
      highlight = FALSE       # Disable knitr highlighting (Hugo handles it)
    )

    knitr::opts_knit$set(
      rmarkdown.pandoc.to = "markdown"  # Ensure inline R is treated as Markdown
    )
}

set_suggested_options <-
  function() {
    knitr::opts_chunk$set(
      cache = if (!is.null(knitr::opts_chunk$get("cache")))
        knitr::opts_chunk$get("cache") else FALSE,

      cache.lazy = if (!is.null(knitr::opts_chunk$get("cache.lazy")))
        knitr::opts_chunk$get("cache.lazy") else FALSE,

      tidy = if (!is.null(knitr::opts_chunk$get("tidy")))
        knitr::opts_chunk$get("tidy") else FALSE,

      fig.width = if (!is.null(knitr::opts_chunk$get("fig.width")))
        knitr::opts_chunk$get("fig.width") else 7,

      fig.height = if (!is.null(knitr::opts_chunk$get("fig.height")))
        knitr::opts_chunk$get("fig.height") else 5,

      dpi = if (!is.null(knitr::opts_chunk$get("dpi")))
        knitr::opts_chunk$get("dpi") else 96,

      warning = if (!is.null(knitr::opts_chunk$get("warning")))
        knitr::opts_chunk$get("warning") else FALSE,

      message = if (!is.null(knitr::opts_chunk$get("message")))
        knitr::opts_chunk$get("message") else FALSE
    )
}
