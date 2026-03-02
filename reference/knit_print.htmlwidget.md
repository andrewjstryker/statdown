# Custom knit_print Method for HTMLWidgets

Registers the widget's CSS/JS dependencies with the active
[depkit::DependencyManager](https://rdrr.io/pkg/depkit/man/DependencyManager.html)
and returns the widget HTML as a raw block.

## Usage

``` r
# S3 method for class 'htmlwidget'
knit_print(x, options, ...)
```

## Arguments

- x:

  An htmlwidget object.

- options:

  A list of knitr chunk options.

- ...:

  Additional arguments passed to downstream functions.

## Value

An object of class `asis_output` containing the rendered HTML.
