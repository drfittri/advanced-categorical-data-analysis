# Install all R packages required to render
# analysis/categorical_data_analysis_combined.qmd
# Usage:  Rscript -e 'source("scripts/install_packages.R")'

pkgs <- c(
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
)

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
} else {
  message("All required packages are already installed.")
}
