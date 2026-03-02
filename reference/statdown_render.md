# Render an R Markdown file to CommonMark

Wraps [`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html) to
render `.Rmd` or `.Rmarkdown` files into
[CommonMark](https://spec.commonmark.org/current/) `.md`. When
htmlwidgets are present, their HTML is inlined and CSS/JS dependency
tags are injected via depkit.

## Usage

``` r
statdown_render(
  input,
  output_root = NULL,
  url_root = NULL,
  cdn = TRUE,
  quiet = FALSE
)
```

## Arguments

- input:

  A character string specifying the input file (must have `.Rmd` or
  `.Rmarkdown` extension).

- output_root:

  Character. Filesystem directory where depkit copies widget assets.
  Defaults to a `libs/` directory next to the input file.

- url_root:

  Character. URL prefix used in emitted `<link>` / `<script>` tags.
  Defaults to `"libs"`.

- cdn:

  Logical. If `TRUE` (the default), depkit emits CDN URLs with SRI
  integrity for JS assets, falling back to local copies when the CDN is
  unreachable. Set to `FALSE` to serve all assets locally.

- quiet:

  A logical value indicating whether to suppress knitr output messages
  (default: `FALSE`).

## Value

The path to the rendered `.md` file (invisibly).

## Details

The output `.md` is compatible with any static site generator that
accepts CommonMark (Hugo, Jekyll, Eleventy, etc.).

The output filename is derived by replacing the input extension with
`.md`.
