#' knugo: A Minimal Knitr Wrapper for Hugo-Based Sites
#'
#' `{knugo}` is a lightweight R package designed to integrate `knitr` output seamlessly into a Hugo-based static site.
#' Unlike heavier alternatives like `{blogdown}` or `{rmarkdown}`, `{knugo}` prioritizes a **Hugo-centric workflow**,
#' allowing users to take full advantage of Hugo’s native features—such as **shortcodes, layouts, and archetypes**—while
#' maintaining direct control over how `.Rmd` and `.Rmarkdown` files are processed.
#'
#' ## Key Features
#'
#' - **Minimalist Approach:** `{knugo}` only provides the essential functionality to render R code, plots, and htmlwidgets for Hugo.
#' - **Direct Hugo Integration:** Works with Hugo's standard Markdown format, avoiding the additional layers of `{blogdown}` or `{rmarkdown}`.
#' - **Custom Knitr Options:** Configures `knitr::opts_chunk` and `knitr::opts_knit` to ensure smooth integration with Hugo.
#' - **Automatic Dependency Handling:** Manages JavaScript/CSS dependencies for **htmlwidgets**, placing them in a Hugo-friendly location.
#'
#' ## How It Works
#'
#' `{knugo}` primarily provides a function to render `.Rmd` and `.Rmarkdown` files into plain `.md` for Hugo:
#'
#' - `knugo_render(input, quiet = FALSE)`: Calls `knitr::knit()` with pre-configured options to ensure compatibility with Hugo.
#'
#' ## Example Usage
#'
#' ```r
#' library(knugo)
#'
#' # Render an R Markdown file for Hugo
#' knugo_render("content/post/example.Rmd")
#'
#' # Render quietly (suppress messages and output)
#' knugo_render("content/post/example.Rmarkdown", quiet = TRUE)
#' ```
#'
#' Once rendered, simply run:
#' ```bash
#' hugo
#' ```
#' to build the final site.
#'
#' ## When to Use `{knugo}`
#'
#' - If you **prefer a lightweight, Hugo-centric** workflow without `{blogdown}` or `{rmarkdown}`.
#' - If you **want full control** over how R-generated Markdown integrates with Hugo.
#' - If you **work directly with `.md` files**, instead of wrapping everything in Pandoc’s ecosystem.
#' - If you **need htmlwidgets support**, but without the overhead of `{blogdown}` or `{quarto}`.
#'
#' ## Comparing `{knugo}` vs. `{blogdown}` vs. `{Quarto}`
#'
#' | Feature        | `{knugo}` | `{blogdown}` | `{Quarto}` |
#' |--------------|------------|-------------|-----------|
#' | **Minimal Setup** | ✅ Yes | ❌ No | ❌ No |
#' | **Hugo-Centric** | ✅ Yes | ⚠️ Partially | ❌ No (Quarto-first) |
#' | **Uses knitr Directly** | ✅ Yes | ❌ No (Wraps rmarkdown) | ❌ No (Quarto engine) |
#' | **Htmlwidget Support** | ✅ Yes (custom method) | ✅ Yes | ✅ Yes |
#' | **Works Without Pandoc** | ✅ Yes | ❌ No | ❌ No |
#'
#' ## Future Development
#'
#' - Automatic detection and management of **htmlwidget** dependencies.
#' - Improved automation via `knugo::build_site()`.
#' - Expanded support for **interactive** widgets inside Hugo content.
#'
#' ## Contributing
#'
#' - Report issues or suggest features via GitHub.
#' - Contributions (especially for widget support and dependency management) are welcome!
#'
#' @name knugo
#' @docType package
#' @keywords package, Hugo, knitr
#' @import knitr
#' @exportPattern "^[^\\.]"
#' @section Required knitr Options:
#'
#' `{knugo}` **automatically sets the following options** to ensure Hugo compatibility:
#'
#' | Option | Default | Purpose |
#' |--------|---------|---------|
#' | `dev`  | `"svglite"` | Forces vector-based graphics |
#' | `fig.path` | `""` | Saves figures in the working directory |
#' | `highlight` | `FALSE` | Disables knitr syntax highlighting (Hugo handles it) |
#' | `rmarkdown.pandoc.to` | `"markdown"` | Ensures inline R expressions are treated correctly |
#'
#' @section Suggested knitr Options:
#'
#' `{knugo}` **also provides recommended defaults**, but these respect user settings if already set:
#'
#' | Option | Default | Purpose |
#' |--------|---------|---------|
#' | `cache` | `FALSE` | Prevents caching unless enabled manually |
#' | `tidy` | `FALSE` | Prevents automatic reformatting unless opted in |
#' | `fig.width` | `7` | Default plot width for Hugo rendering |
#' | `fig.height` | `5` | Default plot height for Hugo rendering |
#' | `dpi` | `96` | Ensures standard web resolution for bitmap images |
#' | `warning` | `FALSE` | Suppresses warnings by default |
#' | `message` | `FALSE` | Suppresses messages by default |
#'
NULL
