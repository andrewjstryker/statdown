# Render Context for Dependency Management

Module-level environment that holds the active
[depkit::DependencyManager](https://rdrr.io/pkg/depkit/man/DependencyManager.html)
during a knit session. The context is initialised before
[`knitr::knit()`](https://rdrr.io/pkg/knitr/man/knit.html) and torn down
afterwards via [`on.exit()`](https://rdrr.io/r/base/on.exit.html).
