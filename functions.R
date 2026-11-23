# =============================================================================
# functions.R
# Purpose: Helper functions (metrics, feature engineering, plotting theme)
# =============================================================================

# -----------------------------------------------------------------------------
# SECTION 1: EVALUATION METRICS
# -----------------------------------------------------------------------------

# Root Mean Squared Error
rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2, na.rm = TRUE))
}

# Mean Absolute Error
mae <- function(actual, predicted) {
  mean(abs(actual - predicted), na.rm = TRUE)
}

# R-squared
r2 <- function(actual, predicted) {
  1 - sum((actual - predicted)^2, na.rm = TRUE) /
    sum((actual - mean(actual, na.rm = TRUE))^2, na.rm = TRUE)
}

# All metrics in one tibble
eval_metrics <- function(actual, predicted, model_name = NA_character_) {
  tibble(
    model = model_name,
    RMSE  = rmse(actual, predicted),
    MAE   = mae(actual, predicted),
    R2    = r2(actual, predicted)
  )
}

# -----------------------------------------------------------------------------
# SECTION 2: FEATURE ENGINEERING
# -----------------------------------------------------------------------------

# Adds lagged columns for a numeric vector. Returns a tibble of lags.
make_lags <- function(x, lags = LAGS, prefix = "v_lag_") {
  out <- lapply(lags, function(l) dplyr::lag(x, l))
  names(out) <- paste0(prefix, lags)
  as_tibble(out)
}

# Trailing (past-only) rolling mean, so no future information is used
make_roll_mean <- function(x, windows = ROLL_WINDOWS, prefix = "v_rmean_") {
  out <- lapply(windows, function(w) {
    zoo::rollapplyr(x, width = w, FUN = mean, fill = NA, partial = FALSE)
  })
  names(out) <- paste0(prefix, windows)
  as_tibble(out)
}

# Trailing rolling standard deviation (captures recent voltage variability)
make_roll_sd <- function(x, windows = ROLL_WINDOWS, prefix = "v_rsd_") {
  out <- lapply(windows, function(w) {
    zoo::rollapplyr(x, width = w, FUN = sd, fill = NA, partial = FALSE)
  })
  names(out) <- paste0(prefix, windows)
  as_tibble(out)
}

# Builds all features for ONE experiment (data frame with time, input_voltage)
build_features_one <- function(df) {
  df <- df %>% arrange(time)
  v  <- df$input_voltage
  bind_cols(
    df,
    tibble(v_diff_1 = v - dplyr::lag(v, 1)),   # change in voltage
    make_lags(v),
    make_roll_mean(v),
    make_roll_sd(v)
  )
}

# Applies build_features_one() to every experiment separately
build_features <- function(data) {
  data %>%
    group_split(experiment) %>%
    lapply(build_features_one) %>%
    bind_rows()
}

# -----------------------------------------------------------------------------
# SECTION 3: CROSS-VALIDATION BY EXPERIMENT (leave-one-experiment-out)
# -----------------------------------------------------------------------------

# Returns a list of folds; each fold has train/validation row indices.
# Rows from the same experiment are never split between train and validation.
make_experiment_folds <- function(data) {
  exps <- unique(data$experiment)
  lapply(setNames(exps, paste0("Fold_exp_", exps)), function(e) {
    list(
      train      = which(data$experiment != e),
      validation = which(data$experiment == e)
    )
  })
}

# -----------------------------------------------------------------------------
# SECTION 4: PLOT THEME
# -----------------------------------------------------------------------------

theme_project <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title      = element_text(face = "bold"),
      plot.subtitle   = element_text(color = "grey40"),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

message("functions.R loaded: helper functions ready.")