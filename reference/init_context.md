# Initialise the render context

Creates a
[depkit::DependencyManager](https://rdrr.io/pkg/depkit/man/DependencyManager.html)
and stores it for the duration of the knit session.

## Usage

``` r
init_context(output_root, url_root, cdn = TRUE)
```

## Arguments

- output_root:

  Character. Filesystem path where depkit copies assets.

- url_root:

  Character. URL prefix used in emitted HTML tags.

- cdn:

  Logical. If `TRUE` (the default), depkit emits CDN URLs with SRI
  integrity for JS assets. Defaults to `TRUE`.

## Value

The newly created `DependencyManager` (invisibly).
