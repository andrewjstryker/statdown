  #' Dependency Manager for htmlwidget Dependencies
#'
#' This S4 class manages htmlwidget dependencies, including caching,
#' attempting to load dependencies from CDNs, and extracting them locally
#' from R packages.
#'
#' @slot cache A list storing already processed dependencies.
#' @slot use_cdn Logical flag indicating whether to attempt to load dependencies from a CDN.
#' @slot cdn_list A character vector of CDN base URLs to try.
#'
#' @export
setClass(
  "DependencyManager",
  slots = c(
    cache = "list",
    use_cdn = "logical",
    cdn_list = "character",
    cdn_attempts = "integer"
  )
)

#' Create a new DependencyManager
#'
#' Constructs a new DependencyManager with default settings.
#'
#' @param use_cdn Logical. Should the manager attempt to retrieve dependencies from a CDN?
#'
#' @return An object of class \code{DependencyManager}.
#' @export
DependencyManager <-
  function(use_cdn = FALSE, cdn_urls = NA, cdn_attempts = 3) {
  new("DependencyManager",
      cache = list(),
      use_cdn = use_cdn,
      cdn_urls = if (is.na(cds)) {
        c(
          "https://cdn.jsdelivr.net/npm/",
          "https://unpkg.com/",
          "https://cdnjs.cloudflare.com/ajax/libs/"
        )
      } else {
        cdn_urls
      },
      cdn_attempts = cdn_attempts
  )
}
