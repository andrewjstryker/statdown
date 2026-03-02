# Set Suggested knitr Options

Sets sensible default knitr chunk options for web-oriented rendering.
These defaults are applied unconditionally before
[`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html) runs. Users
can still override them per-chunk or in an Rmd setup chunk, since knitr
evaluates chunk options after these defaults are set.

## Usage

``` r
set_suggested_options()
```

## Value

None. Called for its side effects.
