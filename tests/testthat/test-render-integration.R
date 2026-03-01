library(testthat)

test_that("rendering a widget Rmd produces link and script tags", {
  skip_on_cran()
  skip_if_not_installed("DT")

  input <- system.file("examples", "test-htmlwidget.Rmd", package = "statdown")
  skip_if(input == "", message = "test-htmlwidget.Rmd not found")

  tmp_dir <- tempfile("statdown-int")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  tmp_input <- file.path(tmp_dir, "test-htmlwidget.Rmd")
  file.copy(input, tmp_input)

  output <- statdown_render(
    tmp_input,
    output_root = file.path(tmp_dir, "libs"),
    url_root = "libs",
    quiet = TRUE
  )

  expect_true(file.exists(output))
  md <- readLines(output, warn = FALSE)

  # CSS <link> tags should appear near the top
  link_lines <- grep("<link ", md)
  expect_true(length(link_lines) > 0, info = "Expected <link> tags in output")

  # JS <script> tags should appear near the bottom
  script_lines <- grep("<script ", md)
  expect_true(length(script_lines) > 0, info = "Expected <script> tags in output")

  # <link> tags should come before <script> tags
  expect_true(min(link_lines) < min(script_lines))

  # libs/ directory should exist and contain asset files
  libs_dir <- file.path(tmp_dir, "libs")
  expect_true(dir.exists(libs_dir))
  asset_files <- list.files(libs_dir, recursive = TRUE)
  expect_true(length(asset_files) > 0, info = "Expected asset files in libs/")
})

test_that("cdn = FALSE produces only local script tags", {
  skip_on_cran()
  skip_if_not_installed("DT")

  input <- system.file("examples", "test-htmlwidget.Rmd", package = "statdown")
  skip_if(input == "", message = "test-htmlwidget.Rmd not found")

  tmp_dir <- tempfile("statdown-cdn")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  tmp_input <- file.path(tmp_dir, "test-htmlwidget.Rmd")
  file.copy(input, tmp_input)

  output <- statdown_render(
    tmp_input,
    output_root = file.path(tmp_dir, "libs"),
    url_root = "libs",
    cdn = FALSE,
    quiet = TRUE
  )

  md <- readLines(output, warn = FALSE)
  script_lines <- grep("<script ", md, value = TRUE)

  # No CDN URLs should appear
  expect_false(any(grepl("cdn.jsdelivr.net", script_lines)),
               info = "Expected no CDN URLs with cdn = FALSE")
  # All script src tags should be local
  src_tags <- grep("<script src=", script_lines, value = TRUE)
  expect_true(all(grepl('src="libs/', src_tags)),
              info = "Expected all script src to be local paths")
})

test_that("cdn = TRUE (default) produces CDN script tags with SRI", {
  skip_on_cran()
  skip_if_not_installed("DT")

  input <- system.file("examples", "test-htmlwidget.Rmd", package = "statdown")
  skip_if(input == "", message = "test-htmlwidget.Rmd not found")

  tmp_dir <- tempfile("statdown-cdn")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  tmp_input <- file.path(tmp_dir, "test-htmlwidget.Rmd")
  file.copy(input, tmp_input)

  output <- statdown_render(
    tmp_input,
    output_root = file.path(tmp_dir, "libs"),
    url_root = "libs",
    cdn = TRUE,
    quiet = TRUE
  )

  md <- readLines(output, warn = FALSE)
  script_lines <- grep("<script ", md, value = TRUE)

  # At least one CDN URL should appear
  cdn_tags <- grep("cdn.jsdelivr.net", script_lines, value = TRUE)
  expect_true(length(cdn_tags) > 0,
              info = "Expected CDN URLs with cdn = TRUE")
  # CDN tags should have integrity attributes
  expect_true(all(grepl("integrity=", cdn_tags)),
              info = "Expected SRI integrity on CDN tags")
  # CDN tags should have local fallback via onerror
  expect_true(all(grepl("onerror=", cdn_tags)),
              info = "Expected onerror fallback on CDN tags")
})

test_that("rendering a plain Rmd produces no link or script tags", {
  skip_on_cran()

  input <- system.file("examples", "test-plain.Rmd", package = "statdown")
  skip_if(input == "", message = "test-plain.Rmd not found")

  tmp_dir <- tempfile("statdown-int")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  tmp_input <- file.path(tmp_dir, "test-plain.Rmd")
  file.copy(input, tmp_input)

  output <- statdown_render(
    tmp_input,
    output_root = file.path(tmp_dir, "libs"),
    url_root = "libs",
    quiet = TRUE
  )

  expect_true(file.exists(output))
  md <- readLines(output, warn = FALSE)

  # Plain Rmd should have no dependency tags
  expect_equal(length(grep("<link ", md)), 0)
  expect_equal(length(grep("<script ", md)), 0)
})
