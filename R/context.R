#' Render Context for Dependency Management
#'
#' Module-level environment that holds the active [depkit::DependencyManager]
#' during a knit session. The context is initialised before `knitr::knit()` and
#' torn down afterwards via `on.exit()`.
#'
#' @name context
#' @keywords internal
NULL

# Module-level storage for the active DependencyManager
.context <- new.env(parent = emptyenv())
.context$dm <- NULL

#' Initialise the render context
#'
#' Creates a [depkit::DependencyManager] and stores it for the duration of the
#' knit session.
#'
#' @param output_root Character. Filesystem path where depkit copies assets.
#' @param url_root Character. URL prefix used in emitted HTML tags.
#' @param cdn Logical. If `TRUE` (the default), depkit emits CDN URLs with
#'   SRI integrity for JS assets. Defaults to `TRUE`.
#' @return The newly created `DependencyManager` (invisibly).
#' @keywords internal
init_context <- function(output_root, url_root, cdn = TRUE) {
  .context$dm <- depkit::DependencyManager(
    output_root = output_root,
    url_root = url_root,
    cdn = cdn
  )
  invisible(.context$dm)
}

#' Retrieve the active DependencyManager
#'
#' Fails fast if the context has not been initialised.
#'
#' @return The active `DependencyManager`.
#' @keywords internal
get_dm <- function() {
  dm <- .context$dm
  if (is.null(dm)) {
    stop("Render context not initialised. Call init_context() first.", call. = FALSE)
  }
  dm
}

#' Update the stored DependencyManager
#'
#' Since depkit is functional/immutable, callers must store the updated DM back
#' after each `insert()`.
#'
#' @param dm A `DependencyManager` instance.
#' @keywords internal
set_dm <- function(dm) {
  .context$dm <- dm
  invisible(dm)
}

#' Clear the render context
#'
#' Resets the stored DependencyManager to `NULL`. Called via `on.exit()` in
#' `statdown_render()`.
#'
#' @keywords internal
clear_context <- function() {
  .context$dm <- NULL
  invisible(NULL)
}
