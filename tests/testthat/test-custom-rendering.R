library(testthat)
library(htmlwidgets)
library(knitr)
library(htmltools)

test_that("knit_print.htmlwidget registers deps with depkit and returns HTML", {
  tmp_out <- tempfile("depkit-test")
  on.exit({
    unlink(tmp_out, recursive = TRUE)
    clear_context()
  }, add = TRUE)

  # Initialise the render context so knit_print can find a DM
  init_context(output_root = tmp_out, url_root = "/libs")

  # Create a widget and attach a real dependency so depkit has something to register
  widget <- htmlwidgets::createWidget(
    name = "dummy",
    x = list(message = "Hello World"),
    width = 300,
    height = 300,
    dependencies = list(
      htmltools::htmlDependency(
        name = "test-dep",
        version = "1.0.0",
        src = c(file = system.file("www", package = "htmlwidgets")),
        script = "htmlwidgets.js"
      )
    )
  )

  output <- knit_print.htmlwidget(widget, list())

  # Returns knit_asis class with HTML content
  expect_true(inherits(output, "knit_asis"))
  expect_type(output, "character")
  expect_match(output, "Hello World")

  # Verify dependencies were registered with the DM
  dm <- get_dm()
  expect_true(length(dm) > 0L)
  expect_true(depkit::has(dm, "test-dep@1.0.0"))
})

test_that("knit_print.htmlwidget errors without render context", {
  # Ensure context is clean
  clear_context()

  widget <- htmlwidgets::createWidget(
    name = "dummy",
    x = list(message = "test"),
    width = 100,
    height = 100
  )

  expect_error(
    knit_print.htmlwidget(widget, list()),
    "Render context not initialised"
  )
})
