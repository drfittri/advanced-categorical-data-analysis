# Reproducibility Guide

This guide lists everything needed to rebuild the report
`analysis/categorical_data_analysis_combined.html` from source on a clean machine.

## 1. Software

| Tool | Version used | Notes |
|------|--------------|-------|
| R | ≥ 4.3.0 | Any recent 4.x release works |
| Quarto | ≥ 1.4 | <https://quarto.org/docs/get-started/> |
| Pandoc | bundled with Quarto | no separate install needed |

Check your installation:

```bash
R --version
quarto --version
quarto check
```

## 2. R packages

The combined document loads the union of all packages used by the three analyses.
Install them all in one step:

```r
install.packages(c(
  # core
  "tidyverse", "here", "knitr", "kableExtra",
  # Part I — ordinal
  "ordinal", "gtsummary", "broom", "car",
  # Part II — multinomial
  "VGAM", "nnet",
  # Part III — correlated data (GLMM / GEE)
  "readxl", "summarytools", "flextable",
  "lme4", "gee", "geepack", "mfp",
  "broom.mixed", "performance", "sjPlot", "ggplot2"
))
```

A convenience script is provided:

```bash
Rscript -e 'source("scripts/install_packages.R")'
```

## 3. Build

From the repository root:

```bash
quarto render analysis/categorical_data_analysis_combined.qmd
```

Quarto sets the working directory to the document's folder, so the relative data paths
(`read_csv("cmc.csv")`, `read_csv("diabetes_sample_2200.csv")`,
`read_excel("hypertension_clinics.xlsx")`) resolve against the colocated files in
`analysis/`. No path editing is required.

To place the rendered HTML in `docs/` (e.g. for GitHub Pages):

```bash
quarto render analysis/categorical_data_analysis_combined.qmd --output-dir ../docs
```

## 4. Notes

- **Single R session.** Rendering runs all three analyses in one knitr session, so all
  packages above are attached together. The analyses use distinct object names and data
  frames, so there are no cross-analysis object collisions. If you adapt the code and hit
  a function-masking issue (for example between `VGAM` and a tidyverse verb), qualify the
  call with its namespace (`dplyr::select`, etc.).
- **Synthetic Part III data.** `hypertension_clinics.xlsx` can be regenerated exactly
  (the seed is fixed) with `Rscript scripts/generate_hypertension_data.R`. Update the
  output path at the bottom of that script to your local folder before running.
- **Runtime.** A full render fits several mixed models and bootstrapped/leave-one-out
  refits; expect a few minutes on a typical laptop.
