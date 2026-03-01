#' Custom knit_print Method for HTMLWidgets
#'
#' Registers the widget's CSS/JS dependencies with the active
#' [depkit::DependencyManager] and returns the widget HTML as a raw block.
#'
#' @param x An htmlwidget object.
#' @param options A list of knitr chunk options.
#' @param ... Additional arguments passed to downstream functions.
#' @return An object of class \code{asis_output} containing the rendered HTML.
#' @export
#' @importFrom htmltools findDependencies renderTags
#' @importFrom knitr asis_output
knit_print.htmlwidget <- # nolint
  function(x, options, ...) {
    # Extract and register dependencies with depkit
    deps <- htmltools::findDependencies(x)
    dm <- get_dm()
    update <- depkit::insert(dm, deps)
    set_dm(depkit::dm(update))

    # Render the widget to HTML
    rendered <- htmltools::renderTags(x)
    html <- rendered$html

    # Return the HTML as-is so knitr does not alter it
    knitr::asis_output(html)
  }
