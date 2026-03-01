
#' Package .onLoad Function
#'
#' This function is executed when the package is loaded.
#' It registers the custom S3 method for htmlwidgets.
#'
#' @param libname The library name.
#' @param pkgname The package name.
.onLoad <-
  function(libname, pkgname) {
    # Register in knitr's namespace so our method takes priority over
    # htmlwidgets' own knit_print.htmlwidget during S3 dispatch.
    registerS3method(
      "knit_print",
      "htmlwidget",
      knit_print.htmlwidget,
      envir = asNamespace("knitr")
    )
  }
