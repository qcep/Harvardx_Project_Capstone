# =============================================================================
# 00_setup.R
# Project: Micro Gas Turbine Electrical Power Prediction
# Purpose: Install/load packages, set seed, define constants
# Run order: First (every other script starts with source("00_setup.R"))
# =============================================================================

# -----------------------------------------------------------------------------
# SECTION 1: CONFIGURATION AND LIBRARIES
# -----------------------------------------------------------------------------

required_packages <- c(
  "tidyverse",    # Data manipulation and visualization (dplyr, ggplot2, readr...)
  "caret",        # Model training utilities and resampling
  "randomForest", # Random Forest model
  "ranger",       # Fast Random Forest implementation
  "xgboost",      # Gradient boosting
  "zoo",          # Rolling means (rollmean / rollapply)
  "scales",       # Axis formatting for plots
  "patchwork",    # Combine ggplots into one figure
  "knitr",        # Tables and report rendering
  "kableExtra",   # Professional table formatting
  "rmarkdown"     # Report generation (Rmd -> PDF)
)

installed_packages <- installed.packages()[, "Package"]
missing_packages   <- required_packages[!(required_packages %in% installed_packages)]

if (length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, dependencies = TRUE,
                   repos = "https://cloud.r-project.org")
} else {
  message("All required packages are already installed.")
}

invisible(lapply(required_packages, library, character.only = TRUE))
message("Section 1 completed: Packages loaded.")

# -----------------------------------------------------------------------------
# SECTION 2: GLOBAL SETTINGS
# -----------------------------------------------------------------------------

SEED <- 123
set.seed(SEED)

options(scipen = 999)        # Avoid scientific notation
options(dplyr.summarise.inform = FALSE)

message("Section 2 completed: Seed set to ", SEED, ".")

# -----------------------------------------------------------------------------
# SECTION 3: PROJECT CONSTANTS
# -----------------------------------------------------------------------------

# Experiment split (following Bielski et al., 2024)
TRAIN_EXPERIMENTS   <- c(1, 9, 20, 21, 23, 24)
HOLDOUT_EXPERIMENTS <- c(4, 22)

# File names (all files live in the project root folder)
RAW_FILES <- c(
  setNames(sprintf("train_ex_%d.csv", TRAIN_EXPERIMENTS),   TRAIN_EXPERIMENTS),
  setNames(sprintf("test_ex_%d.csv",  HOLDOUT_EXPERIMENTS), HOLDOUT_EXPERIMENTS)
)

# Output file names
FILE_ALL_DATA   <- "all_experiments.rds"
FILE_FEATURES   <- "features_data.rds"
FILE_CV_RESULTS <- "tbl_cv_results.csv"
FILE_FINAL      <- "tbl_final_results.csv"

# Feature engineering parameters (lags are ROWS back, not exact seconds)
LAGS           <- c(1, 2, 5, 10, 20, 30, 60, 120, 180, 300, 450, 600)
ROLL_WINDOWS   <- c(10, 30, 60, 120, 300, 600)
JUMP_THRESHOLD <- 1   # volts; a voltage change larger than this counts as a "ju


message("Section 3 completed: Constants defined.")
message("Setup finished: environment ready.")