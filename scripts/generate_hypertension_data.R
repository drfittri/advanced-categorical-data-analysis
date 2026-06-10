# Synthetic dataset for demonstrating GLMM (random intercept + random slope) and GEE
# Public health theme: hypertension risk across primary care clinics
# 1000 patients nested within 25 clinics (40 patients per clinic)

set.seed(20260524)

if (!requireNamespace("writexl", quietly = TRUE)) {
  install.packages("writexl", repos = "https://cloud.r-project.org")
}
library(writexl)

# -----------------------------
# Cluster structure
# -----------------------------
n_clinics    <- 25
per_clinic   <- 40
n            <- n_clinics * per_clinic   # 1000

clinic_id <- rep(sprintf("C%02d", 1:n_clinics), each = per_clinic)

# Random intercept per clinic (clinic-level baseline hypertension risk)
u0 <- rnorm(n_clinics, mean = 0, sd = 0.6)

# Random slope per clinic for physical_activity (effect of exercise varies by clinic)
# Correlated with intercept (rho = -0.3): clinics with higher baseline risk get
# stronger protective effect from activity
rho <- -0.3
u1_raw <- rnorm(n_clinics, mean = 0, sd = 0.15)
u1 <- rho * (u0 / 0.6) * 0.15 + sqrt(1 - rho^2) * u1_raw

# Map cluster-level random effects to each row
u0_i <- rep(u0, each = per_clinic)
u1_i <- rep(u1, each = per_clinic)

# -----------------------------
# Patient-level predictors
# -----------------------------
age <- round(rnorm(n, mean = 50, sd = 12))
age <- pmin(pmax(age, 25), 80)

bmi <- round(rnorm(n, mean = 26.5, sd = 4.2), 1)
bmi <- pmin(pmax(bmi, 17), 45)

physical_activity_hrs <- round(pmax(0, rgamma(n, shape = 2, scale = 1.8)), 1)
physical_activity_hrs <- pmin(physical_activity_hrs, 15)

smoker <- rbinom(n, 1, prob = 0.28)

# -----------------------------
# Linear predictor (logit scale)
# -----------------------------
beta0 <- -1.3                  # intercept (targets ~30% prevalence)
beta_age <- 0.045              # older -> higher risk
beta_bmi <- 0.110              # higher BMI -> higher risk
beta_pa  <- -0.180             # more activity -> lower risk (fixed effect)
beta_smk <- 0.650              # smoker -> higher risk

eta <- beta0 +
  beta_age * (age - 50) +
  beta_bmi * (bmi - 26.5) +
  (beta_pa + u1_i) * physical_activity_hrs +   # random slope on activity
  beta_smk * smoker +
  u0_i                                          # random intercept

p_hyp <- plogis(eta)
hypertension <- rbinom(n, 1, p_hyp)

# -----------------------------
# Assemble
# -----------------------------
dat <- data.frame(
  patient_id            = sprintf("P%04d", 1:n),
  clinic_id             = clinic_id,
  age                   = age,
  bmi                   = bmi,
  physical_activity_hrs = physical_activity_hrs,
  smoker                = smoker,
  hypertension          = hypertension
)

# Sanity checks
cat("Rows:", nrow(dat), "\n")
cat("Clinics:", length(unique(dat$clinic_id)), "\n")
cat("Hypertension prevalence:", round(mean(dat$hypertension), 3), "\n")
cat("Prevalence range by clinic:",
    paste(round(range(tapply(dat$hypertension, dat$clinic_id, mean)), 3),
          collapse = " - "), "\n")

out_path <- "/Users/fittri/Desktop/glmm/synthetic/hypertension_clinics.xlsx"
write_xlsx(dat, out_path)
cat("Saved:", out_path, "\n")
