#' statdown: Use R in Your Static Site
#'
#' Renders `.Rmd` files to [CommonMark](https://spec.commonmark.org/current/)
#' `.md` that any static site generator can consume directly — no Pandoc, no
#' second HTML engine. Your SSG stays in charge; R just provides the computed
#' content.
#'
#' statdown is for bloggers who happen to use R, not R users who need a
#' website. If you already have a [Hugo](https://gohugo.io/),
#' [Jekyll](https://jekyllrb.com/), or [Eleventy](https://www.11ty.dev/) site,
#' statdown lets you add R content without replacing your build pipeline.
#'
#' ## Key Features
#'
#' - **One engine** — [knitr](https://yihui.org/knitr/) evaluates R code and
#'   produces CommonMark. Your SSG handles everything else. No Pandoc in the
#'   middle means shortcodes, templates, and front matter all work as your SSG
#'   expects.
#' - **htmlwidgets work** — interactive widgets (`DT`, `leaflet`, `plotly`)
#'   are rendered as inline HTML with dependencies managed by
#'   [depkit](https://github.com/andrewjstryker/depkit).
#' - **CDN delivery** — JS assets are served from jsDelivr with SRI integrity
#'   and automatic local fallback by default.
#'
#' ## Usage
#'
#' ```r
#' library(statdown)
#'
#' # Render an .Rmd to .md for your SSG
#' statdown_render("posts/my-analysis.Rmd")
#'
#' # Custom asset directory and URL prefix
#' statdown_render("posts/my-analysis.Rmd",
#'   output_root = "static/libs",
#'   url_root = "/libs")
#' ```
#'
#' @name statdown
#' @aliases statdown-package
#' @importFrom knitr knit_print
#' @importFrom htmltools findDependencies renderTags
NULL
