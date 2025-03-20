library(testthat)
library(stringr)

# Helper function to normalize Markdown text
normalize_md <- function(md_text) {
  # Collapse multiple spaces and trim whitespace
  str_squish(md_text)
}

test_that("knugo_render produces expected markdown", {
  # Assume we have a test Rmd file in inst/examples/test.Rmd
  input <- system.file("examples", "test.Rmd", package = "knugo")
  output <- tempfile(fileext = ".md")
  
  # Run the knugo render function
  knugo_render(input, output)
  
  # Read and normalize the output
  output_text <- paste(readLines(output, warn = FALSE), collapse = "\n")
  normalized_text <- normalize_md(output_text)
  
  # Snapshot test the normalized output
  expect_snapshot(normalized_text)
})
