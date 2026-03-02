# Custom knitr render function

Routes htmlwidget results through
[`knit_print.htmlwidget()`](https://andrewjstryker.github.io/statdown/reference/knit_print.htmlwidget.md)
to register dependencies with depkit. For all other objects, falls back
to
[`knitr::knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html).
This is necessary because htmlwidgets' `.onLoad` re-registers its own
`knit_print.htmlwidget` in knitr's S3 method table, overriding
statdown's registration.

## Usage

``` r
statdown_knit_render(x, options, ...)
```

## Arguments

- x:

  The object to print.

- options:

  A list of knitr chunk options for the current chunk.

- ...:

  Additional arguments passed to the print method.

## Value

The printed result.
