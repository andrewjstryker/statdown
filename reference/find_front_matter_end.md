# Find the closing line of YAML front matter

Looks for a document that starts with `---` and returns the line number
of the matching closing `---`. Returns 0 if no front matter is found.

## Usage

``` r
find_front_matter_end(lines)
```

## Arguments

- lines:

  Character vector of file lines.

## Value

Integer line number of the closing `---`, or 0.
