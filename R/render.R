#' Render an R Markdown file to CommonMark
#'
#' Wraps [knitr::knit()] to render `.Rmd` or `.Rmarkdown` files into
#' [CommonMark](https://spec.commonmark.org/current/) `.md`. When htmlwidgets
#' are present, their HTML is inlined and CSS/JS dependency tags are injected
#' via depkit.
#'
#' The output `.md` is compatible with any static site generator that accepts
#' CommonMark (Hugo, Jekyll, Eleventy, etc.).
#'
#' The output filename is derived by replacing the input extension with `.md`.
#'
#' @param input A character string specifying the input file (must have `.Rmd`
#'   or `.Rmarkdown` extension).
#' @param output_root Character. Filesystem directory where depkit copies widget
#'   assets. Defaults to a `libs/` directory next to the input file.
#' @param url_root Character. URL prefix used in emitted `<link>` / `<script>`
#'   tags. Defaults to `"libs"`.
#' @param cdn Logical. If `TRUE` (the default), depkit emits CDN URLs with
#'   SRI integrity for JS assets, falling back to local copies when the CDN
#'   is unreachable. Set to `FALSE` to serve all assets locally.
#' @param quiet A logical value indicating whether to suppress knitr output
#'   messages (default: `FALSE`).
#'
#' @return The path to the rendered `.md` file (invisibly).
#' @export
statdown_render <- function(input, output_root = NULL, url_root = NULL,
                            cdn = TRUE, quiet = FALSE) {
  # ensure required packages are present
  validate(input)

  output <- sub("\\.(Rmd|Rmarkdown)$", ".md", input, ignore.case = TRUE)

  # Default asset paths relative to the input file
  input_dir <- dirname(input)
  if (is.null(output_root)) output_root <- file.path(input_dir, "libs")
  if (is.null(url_root)) url_root <- "libs"

  # Initialise the depkit render context and guarantee cleanup

  init_context(output_root = output_root, url_root = url_root, cdn = cdn)
  on.exit(clear_context(), add = TRUE)

  # Ensure inline R is treated as Markdown
  knitr::opts_knit$set(rmarkdown.pandoc.to = "markdown")

  # Set sensible default chunk options
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

  # Inject dependency tags if any widgets were registered
  dm <- get_dm()
  if (length(dm) > 0L) {
    md_content <- readLines(output, warn = FALSE)
    css_tags <- depkit::emit_css(dm)
    js_tags <- depkit::emit_js(dm)

    final <- c(css_tags, "", md_content, "", js_tags)
    writeLines(final, output)
  }

  invisible(output)
}


#' Set Suggested knitr Options
#'
#' Sets sensible default knitr chunk options for web-oriented rendering.
#' These defaults are applied unconditionally before `knitr::knit()` runs.
#' Users can still override them per-chunk or in an Rmd setup chunk, since
#' knitr evaluates chunk options after these defaults are set.
#'
#' @return None. Called for its side effects.
#' @keywords internal
set_suggested_options <- function() {
  svg_device <- if (requireNamespace("svglite", quietly = TRUE)) "svglite" else "svg"

  knitr::opts_chunk$set(
    dev       = svg_device,
    dpi       = 96,
    fig.width = 7,
    fig.height = 5,
    warning   = FALSE,
    message   = FALSE,
    render    = statdown_knit_render
  )
}

#' Custom knitr render function
#'
#' Routes htmlwidget results through [knit_print.htmlwidget()] to register
#' dependencies with depkit. For all other objects, falls back to
#' [knitr::knit_print()]. This is necessary because htmlwidgets' `.onLoad`
#' re-registers its own `knit_print.htmlwidget` in knitr's S3 method table,
#' overriding statdown's registration.
#'
#' @param x The object to print.
#' @param options A list of knitr chunk options for the current chunk.
#' @param ... Additional arguments passed to the print method.
#' @return The printed result.
#' @keywords internal
statdown_knit_render <- function(x, options, ...) {
  if (inherits(x, "htmlwidget")) {
    knit_print.htmlwidget(x, options = options, ...)
  } else {
    knitr::knit_print(x, options = options, ...)
  }
}

validate <- function(input) {
  if (!grepl("\\.(Rmd|Rmarkdown)$", input, ignore.case = TRUE)) {
    stop("Input file must have a '.Rmd' or '.Rmarkdown' extension.", call. = FALSE)
  }
  validate_environment()
  invisible(TRUE)
}


