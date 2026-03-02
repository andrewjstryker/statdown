# statdown DESIGN

> **Scope:** statdown lets bloggers add R content to an existing static
> site without replacing their site generator. It knits `.Rmd` to
> CommonMark `.md` and uses **depkit** to manage htmlwidget CSS/JS
> dependencies at build time. The output is plain Markdown that any SSG
> (Hugo, Jekyll, Eleventy, etc.) consumes directly — no Pandoc, no
> second HTML engine.

------------------------------------------------------------------------

## Goals

1.  **Keep the SSG in charge**

    The site builder (Hugo, Jekyll, Eleventy, or any Markdown engine) is
    the only HTML engine in the pipeline. statdown produces `.md` and
    asset files — it never calls Pandoc and never produces HTML
    documents. Shortcodes, templates, and front matter remain the SSG’s
    business.

2.  **Minimal surface area**

    One public function:
    [`statdown_render()`](https://andrewjstryker.github.io/statdown/reference/statdown_render.md).
    Everything else is internal.

3.  **First-class htmlwidget support via depkit**

    Widgets render as inline HTML fragments in the `.md` output. Their
    CSS/JS dependencies are deduplicated, copied to an output directory,
    and injected as `<link>` / `<script>` tags by depkit, with CDN
    delivery and SRI integrity by default.

4.  **Build-time responsibility boundaries**

    statdown handles build-time knitting and dependency collection. The
    downstream engine handles Markdown-to-HTML conversion at render
    time.

------------------------------------------------------------------------

## Non-goals

- Replace blogdown, rmarkdown, or Quarto. (Quarto is the right tool when
  R is the center of the site rather than an occasional guest.)
- Full site orchestration (finding posts, running Hugo, managing
  archetypes).
- Supporting Pandoc features (citations, cross-refs, multi-format
  output).

------------------------------------------------------------------------

## Core concept

statdown is a **knitr wrapper** with two responsibilities:

1.  **Knit `.Rmd` to `.md`** with predictable chunk defaults suitable
    for static-site Markdown engines.
2.  **Capture and materialize widget dependencies** using depkit during
    the same build step, emitting `<link>` and `<script>` tags directly
    into the `.md` output.

------------------------------------------------------------------------

## Architecture

### Layers

#### Porcelain API (user-facing)

``` r
statdown_render(input, output_root = NULL, url_root = NULL, cdn = TRUE, quiet = FALSE)
```

- Validates the input file and required packages.
- Creates a depkit `DependencyManager` in a render context, passing
  `cdn` through to enable CDN delivery with SRI integrity.
- Sets knitr options and chunk defaults (including a custom `render`
  function that routes htmlwidgets through statdown’s dep-tracking
  path).
- Runs [`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html).
- After knitting, injects CSS tags at the top and JS tags at the bottom
  of the `.md` if any widgets were encountered.
- Cleans up the render context via
  [`on.exit()`](https://rdrr.io/r/base/on.exit.html).

#### Plumbing (internal)

- **Render context** (`context.R`) — module-level environment
  (`.context`) holding the active `DependencyManager`. Provides
  [`init_context()`](https://andrewjstryker.github.io/statdown/reference/init_context.md),
  [`get_dm()`](https://andrewjstryker.github.io/statdown/reference/get_dm.md),
  [`set_dm()`](https://andrewjstryker.github.io/statdown/reference/set_dm.md),
  and
  [`clear_context()`](https://andrewjstryker.github.io/statdown/reference/clear_context.md).

- **knitr print method** (`custom-render.R`) —
  [`knit_print.htmlwidget()`](https://andrewjstryker.github.io/statdown/reference/knit_print.htmlwidget.md)
  extracts widget dependencies, registers them with depkit, and returns
  the widget HTML as
  [`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html).

- **knitr configuration** (`render.R`) —
  [`set_suggested_options()`](https://andrewjstryker.github.io/statdown/reference/set_suggested_options.md)
  sets device, DPI, figure dimensions, message/warning defaults, and a
  custom `render` chunk option (`statdown_knit_render`) that ensures
  htmlwidget output is routed through statdown’s dep-tracking print
  method.

- **Environment validation** (`validate-environment.R`) —
  [`validate_environment()`](https://andrewjstryker.github.io/statdown/reference/validate_environment.md)
  checks that knitr, depkit, htmltools, and svglite are installed.

- **S3 registration** (`zzz.R`) — `.onLoad` registers
  `knit_print.htmlwidget` via
  [`registerS3method()`](https://rdrr.io/r/base/ns-internal.html) in
  **knitr’s** namespace. This is a fallback; the primary dispatch path
  is the custom `render` chunk option (see “Widget dispatch” below).

------------------------------------------------------------------------

## Rendering pipeline

``` mermaid
flowchart TD
  A["input.Rmd"] --> B["statdown_render()"]
  B --> C["validate + init DependencyManager"]
  C --> D["set knitr options"]
  D --> E["knitr::knit()"]
  E --> F["output.md (raw)"]
  E --> G["widget chunks trigger knit_print.htmlwidget"]
  G --> H["deps registered with depkit via insert()"]
  H --> I["updated DM stored in .context"]
  F --> J{"any deps registered?"}
  J -- yes --> K["emit_css(dm) prepended to .md"]
  J -- yes --> L["emit_js(dm) appended to .md"]
  K --> M["output.md (final)"]
  L --> M
  J -- no --> M
```

------------------------------------------------------------------------

## Dependency injection: inline tags

Widget dependencies are injected as raw HTML directly into the `.md`
output:

- `<link>` tags (CSS) are prepended before the Markdown content.
- `<script>` tags (JS) are appended after the Markdown content.

This approach was chosen over a shortcode/manifest mechanism because it
is simpler, renderer-agnostic, and requires no Hugo-specific templates
or configuration.

If no widgets are encountered during knitting, the `.md` output is left
unchanged — no empty tags, no markers.

------------------------------------------------------------------------

## Render context

[`statdown_render()`](https://andrewjstryker.github.io/statdown/reference/statdown_render.md)
creates a short-lived render context stored in a module-level
environment (`.context`):

``` r
.context <- new.env(parent = emptyenv())
.context$dm <- NULL
```

The context holds a single field — the active `DependencyManager` — and
exposes four internal functions:

| Function                                                                                  | Purpose                                                                          |
|-------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| [`init_context()`](https://andrewjstryker.github.io/statdown/reference/init_context.md)   | Creates a new `DependencyManager` and stores it.                                 |
| [`get_dm()`](https://andrewjstryker.github.io/statdown/reference/get_dm.md)               | Retrieves the active DM; errors if not initialised.                              |
| [`set_dm()`](https://andrewjstryker.github.io/statdown/reference/set_dm.md)               | Stores an updated DM (depkit is functional/immutable).                           |
| [`clear_context()`](https://andrewjstryker.github.io/statdown/reference/clear_context.md) | Resets to `NULL`. Called via [`on.exit()`](https://rdrr.io/r/base/on.exit.html). |

Because depkit’s `insert()` returns a new `InsertUpdate` containing the
updated `DependencyManager`, callers must call
`set_dm(depkit::dm(update))` after each insertion to persist the change.

------------------------------------------------------------------------

## Widget handling

When knitr encounters an htmlwidget chunk, it dispatches to
[`knit_print.htmlwidget()`](https://andrewjstryker.github.io/statdown/reference/knit_print.htmlwidget.md),
which:

1.  Extracts `htmlDependency` objects via
    `htmltools::findDependencies(x)`.
2.  Calls `depkit::insert(dm, deps)` to register them.
3.  Stores the updated DM back via `set_dm(depkit::dm(update))`.
4.  Renders the widget to HTML via `htmltools::renderTags(x)`.
5.  Returns the HTML string wrapped in
    [`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
    so knitr passes it through without escaping.

### Widget dispatch

htmlwidgets ships its own `knit_print.htmlwidget` method and
re-registers it in knitr’s S3 method table via `s3_register()` inside
its `.onLoad`. Because [`library(DT)`](https://github.com/rstudio/DT)
(or any widget package) triggers that `.onLoad`, the htmlwidgets method
overrides any earlier S3 registration — including ours.

statdown solves this with a **custom `render` chunk option** set in
[`set_suggested_options()`](https://andrewjstryker.github.io/statdown/reference/set_suggested_options.md):

``` r
knitr::opts_chunk$set(render = statdown_knit_render)
```

`statdown_knit_render(x, options, ...)` checks
`inherits(x, "htmlwidget")` and calls statdown’s `knit_print.htmlwidget`
directly, bypassing S3 dispatch entirely. For all other objects it falls
through to
[`knitr::knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html).

The S3 registration in `.onLoad` (into `asNamespace("knitr")`) is
retained as a belt-and-suspenders fallback for edge cases where the
`render` option is overridden by user code.

------------------------------------------------------------------------

## knitr options policy

### Hard requirements

Set unconditionally before
[`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html) runs:

- `knitr::opts_knit$set(rmarkdown.pandoc.to = "markdown")` — ensures
  inline R expressions are formatted for Markdown output.

### Suggested defaults (user-overridable per chunk)

Set via
[`set_suggested_options()`](https://andrewjstryker.github.io/statdown/reference/set_suggested_options.md):

| Option       | Value                                        |
|--------------|----------------------------------------------|
| `dev`        | `"svglite"` if installed, else `"svg"`       |
| `dpi`        | `96`                                         |
| `fig.width`  | `7`                                          |
| `fig.height` | `5`                                          |
| `warning`    | `FALSE`                                      |
| `message`    | `FALSE`                                      |
| `render`     | `statdown_knit_render` (see Widget dispatch) |

Users can override any of these in individual chunks or in a setup
chunk, since knitr evaluates per-chunk options after these defaults are
set.

**Design rule:** options are set deterministically. statdown does not
probe whether settings already exist or try to merge with pre-existing
state.

------------------------------------------------------------------------

## Fail-fast philosophy

statdown follows a fail-fast approach throughout:

- **No runtime probing.** The package does not check method resolution
  order, inspect knitr internals, or guess at dependency shapes. It
  registers its methods via standard R mechanisms and trusts the
  dispatch.

- **Missing context is an error.** If `knit_print.htmlwidget` is called
  outside a
  [`statdown_render()`](https://andrewjstryker.github.io/statdown/reference/statdown_render.md)
  session (i.e. without an active `DependencyManager`),
  [`get_dm()`](https://andrewjstryker.github.io/statdown/reference/get_dm.md)
  raises an immediate error.

- **Missing packages are an error.**
  [`validate_environment()`](https://andrewjstryker.github.io/statdown/reference/validate_environment.md)
  checks for all required packages and stops with an actionable install
  command if any are missing.

- **Invalid input is an error.** Files without `.Rmd` or `.Rmarkdown`
  extensions are rejected immediately.

------------------------------------------------------------------------

## Public API

### `statdown_render(input, output_root, url_root, cdn, quiet)`

| Parameter     | Default               | Description                                        |
|---------------|-----------------------|----------------------------------------------------|
| `input`       | (required)            | Path to `.Rmd` or `.Rmarkdown` file.               |
| `output_root` | `libs/` next to input | Filesystem directory where depkit copies assets.   |
| `url_root`    | `"libs"`              | URL prefix for emitted `<link>` / `<script>` tags. |
| `cdn`         | `TRUE`                | Use CDN URLs with SRI integrity for JS assets.     |
| `quiet`       | `FALSE`               | Suppress knitr progress messages.                  |

**Returns:** the path to the rendered `.md` file (invisibly).

### `validate_environment()`

Exported utility that checks whether all required packages (knitr,
depkit, htmltools) are installed. Called automatically by
[`statdown_render()`](https://andrewjstryker.github.io/statdown/reference/statdown_render.md)
but can also be called directly.

------------------------------------------------------------------------

## File layout

    R/
      render.R               Porcelain API: statdown_render(), set_suggested_options(),
                             statdown_knit_render(), validate()
      context.R              Render context: init/get/set/clear the DependencyManager
      custom-render.R        knitr integration: knit_print.htmlwidget()
      validate-environment.R Package dependency checks
      statdown-package.R     Package-level roxygen documentation
      zzz.R                  .onLoad: S3 method registration (fallback)

------------------------------------------------------------------------

## Error handling

| Condition                 | Behaviour                                                                                                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| Invalid input extension   | [`stop()`](https://rdrr.io/r/base/stop.html) with message about required extensions.                                                                  |
| Missing required package  | [`stop()`](https://rdrr.io/r/base/stop.html) listing missing packages and install command.                                                            |
| Missing render context    | [`stop()`](https://rdrr.io/r/base/stop.html) from [`get_dm()`](https://andrewjstryker.github.io/statdown/reference/get_dm.md) with init instructions. |
| Widget dependency failure | depkit propagates errors; statdown does not suppress.                                                                                                 |
| Missing svglite           | Graceful fallback to `"svg"` device (not an error).                                                                                                   |
