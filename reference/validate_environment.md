# Validate the statdown environment

Checks that all required runtime dependencies are installed. Called
automatically by
[`statdown_render()`](https://andrewjstryker.github.io/statdown/reference/statdown_render.md)
and can also be called directly.

## Usage

``` r
validate_environment()
```

## Value

`TRUE` (invisibly) if all dependencies are met; otherwise stops with an
informative error.
