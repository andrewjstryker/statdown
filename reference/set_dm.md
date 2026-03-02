# Update the stored DependencyManager

Since depkit is functional/immutable, callers must store the updated DM
back after each `insert()`.

## Usage

``` r
set_dm(dm)
```

## Arguments

- dm:

  A `DependencyManager` instance.
