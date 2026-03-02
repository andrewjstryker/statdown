# statdown

**Use R in your static site — without replacing your static site
generator.**

statdown renders `.Rmd` files to CommonMark `.md` that Hugo, Jekyll,
Eleventy, or any other SSG can consume directly. No Pandoc, no second
HTML engine, no shortcode workarounds. Your SSG stays in charge; R just
provides the computed content.

## The problem

Tools like **blogdown** and **Quarto** solve R + website by pulling the
website into R’s toolchain. blogdown routes output through Pandoc before
Hugo sees it, which means two HTML engines process every page.
Shortcodes must be guarded against Pandoc. Templates behave differently
depending on whether content came from `.Rmd` or `.md`. Quarto goes
further and replaces the SSG entirely.

These are good tools, but they work best when R *is* the center of your
site. If you’re a blogger who happens to use R — someone who already has
a Hugo theme, a build pipeline, and opinions about how your site works —
they ask you to give up control you don’t want to give up.

## statdown’s approach

statdown goes the other direction: just enough R scaffolding to produce
Markdown your SSG already understands.

    .Rmd → knitr → .md → your SSG → site

- **One engine.** knitr evaluates R code and produces CommonMark. Your
  SSG processes that Markdown with its own templates and shortcodes. No
  Pandoc in the middle.
- **htmlwidgets work.** Interactive widgets (DT, leaflet, plotly) are
  rendered as inline HTML with their CSS/JS dependencies managed by
  [depkit](https://github.com/andrewjstryker/depkit) — deduplicated,
  copied to your asset directory, and served via CDN with SRI integrity
  by default.
- **Your SSG stays in charge.** Front matter, shortcodes, templates, and
  build steps are all your SSG’s business. statdown doesn’t touch them.

### Comparing approaches

``` mermaid
flowchart LR

    subgraph K[statdown]
    A1(.Rmd) --> A2(knitr)
    A2 --> A3(.md)
    A3 --> A4(SSG)
    A4 --> A5(Site)
    end

    subgraph B[blogdown]
    B1(.Rmd) --> B2(knitr)
    B2 --> B3(Pandoc)
    B3 --> B4(Hugo)
    B4 --> B5(Site)
    end

    subgraph Q[Quarto]
    Q1(.qmd) --> Q2(knitr)
    Q2 --> Q3(Pandoc)
    Q3 --> Q4(Site)
    end
```

## Usage

``` r
library(statdown)

# Render an .Rmd to .md
statdown_render("posts/my-analysis.Rmd")

# Custom asset directory and URL prefix
statdown_render("posts/my-analysis.Rmd",
  output_root = "static/libs",
  url_root = "/libs")

# Serve all widget assets locally (no CDN)
statdown_render("posts/my-analysis.Rmd", cdn = FALSE)
```

The output `.md` contains: - CSS `<link>` tags at the top (if
htmlwidgets are used) - Markdown content with inline HTML for widgets -
JS `<script>` tags at the bottom (with CDN + SRI + local fallback)

Drop it into your SSG’s content directory and build as usual.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("andrewjstryker/statdown")
```

## FAQ

**Who is this for?** Bloggers who use a static site generator and
sometimes need R — not R users who need a website. If you’re happy with
Quarto or blogdown, keep using them.

**Why not blogdown with `.Rmarkdown` files?** blogdown’s `.Rmarkdown`
path avoids Pandoc, but you still inherit blogdown’s opinions about
directory structure, Hugo integration, and build workflow. statdown is a
single function with no opinions about your site.

**What about Quarto?** Quarto is excellent for R-centric sites, books,
and documents. If you want your site generator to understand R natively,
use Quarto. If you want your existing SSG to stay in charge, use
statdown.

**Do I need to handle front matter?** statdown passes front matter
through unchanged. Use whatever your SSG expects.

## Contributing

- **Issues & Ideas**: Please open an issue if you have problems or
  suggestions.
- **Pull Requests**: Contributions are welcome.
