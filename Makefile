# Makefile for statdown R package

PACKAGE := $(shell grep '^Package:' DESCRIPTION | awk '{print $$2}')
VERSION := $(shell grep '^Version:' DESCRIPTION | awk '{print $$2}')
TARBALL := $(PACKAGE)_$(VERSION).tar.gz

.PHONY: all
all: test pkgdown #> Run tests and build pkgdown website (default)

# ── Development environment ──────────────────────────────────────────

.PHONY: install_deps
install_deps: #> Install required packages for development
	R -e "install.packages(c('devtools', 'testthat', 'pkgdown', 'lintr'), repos = 'https://cloud.r-project.org')"

.PHONY: snapshot
snapshot: #> Snapshot package versions with renv
	R -e "renv::snapshot()"

.PHONY: restore
restore: #> Restore pinned package versions from renv.lock
	R -e "renv::restore()"

# ── Build and install ────────────────────────────────────────────────

.PHONY: document
document: #> Update documentation and NAMESPACE using roxygen2
	R -e "devtools::document()"

.PHONY: build
build: document #> Build the package tarball
	R CMD build .

.PHONY: install
install: build #> Install the package locally
	R CMD INSTALL $(TARBALL)

# ── Quality checks ──────────────────────────────────────────────────

.PHONY: test
test: #> Run tests using testthat via devtools
	R -e "devtools::test()"

.PHONY: lint
lint: #> Lint the package source with lintr
	R -e "lintr::lint_package()"

.PHONY: check
check: build #> Run R CMD check on the built package
	R CMD check $(TARBALL)

# ── Documentation ───────────────────────────────────────────────────

.PHONY: vignettes
vignettes: #> Build vignettes
	R -e "devtools::build_vignettes()"

.PHONY: pkgdown
pkgdown: #> Build the pkgdown website
	R -e "pkgdown::build_site()"

# ── Cleanup ─────────────────────────────────────────────────────────

.PHONY: clean
clean: #> Remove generated files
	rm -rf *.tar.gz *.Rcheck docs doc Meta

.PHONY: help
help: #> Print this help message
	@gawk -f generate-help.awk ${MAKEFILE_LIST}
