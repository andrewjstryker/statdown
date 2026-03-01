library(testthat)
library(stringr)

# Helper function to normalize Markdown text
normalize_md <- function(md_text) {
  # Collapse multiple spaces and trim whitespace
  md_text <- str_squish(md_text)
  # Normalize random htmlwidget IDs to a stable placeholder
  md_text <- gsub("htmlwidget-[0-9a-f]+", "htmlwidget-NORMALIZED", md_text)
  md_text
}

test_files <- list.files(
  system.file("examples", package = "statdown"),
  pattern = "^test-.*\\.Rmd$",
  full.names = TRUE
)


for (input in test_files) {
  test_name <- basename(input)

  test_that(
    paste("statdown_render snapshot for", test_name),
    {
      tmp_dir <- tempfile("statdown-snap")
      dir.create(tmp_dir)
      on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

      tmp_input <- file.path(tmp_dir, test_name)
      file.copy(input, tmp_input)

      output <- statdown_render(
        tmp_input,
        output_root = file.path(tmp_dir, "libs"),
        url_root = "libs",
        quiet = TRUE
      )

      # Read and normalize the output
      output_text <- paste(readLines(output, warn = FALSE), collapse = "\n")
      normalized_text <- normalize_md(output_text)

      # Snapshot test the normalized output
      expect_snapshot(normalized_text)
    }
  )
}
