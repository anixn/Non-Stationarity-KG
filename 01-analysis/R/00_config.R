# =============================================================================
# 00_config.R
# Central configuration for the CZIPEF revision analysis.
#
# Everything that controls a run lives here: paths, parameter bounds, periods,
# acceptance thresholds, ensemble sizes, and seeds. Scripts source this file and
# never hard-code a path or a bound.
#
# Usage:
#   source("01-analysis/R/00_config.R")
#   # optional overrides before running a stage
#   N_LHS <- 5000
# =============================================================================

# ---- Project root -----------------------------------------------------------
# Override with the environment variable TSFT_PROJ if the project moves.
PROJ <- Sys.getenv("TSFT_PROJ",
                   unset = "D:/Research/202505_Non_Stationarity_KG")

DIR_ANALYSIS <- file.path(PROJ, "01-analysis")
DIR_DATA     <- file.path(DIR_ANALYSIS, "data")
DIR_R        <- file.path(DIR_ANALYSIS, "R")
DIR_OUT      <- file.path(PROJ, "02-outputs")

# All revision products go here. Nothing overwrites the original outputs.
# Override with TSFT_REV_DIR to run a smoke test without touching production.
DIR_REV      <- Sys.getenv("TSFT_REV_DIR", unset = file.path(DIR_OUT, "revision"))
DIR_CAL      <- file.path(DIR_REV, "calibration")
DIR_VALID    <- file.path(DIR_REV, "validation")
DIR_KG       <- file.path(DIR_REV, "kg")
DIR_ATTR     <- file.path(DIR_REV, "attribution")
DIR_POOL     <- file.path(DIR_REV, "pools")
DIR_SCEN     <- file.path(DIR_REV, "scenarios")
DIR_THR      <- file.path(DIR_REV, "thresholds")
DIR_SENS     <- file.path(DIR_REV, "sensitivity")
DIR_FIG      <- file.path(DIR_REV, "figures")
DIR_TAB      <- file.path(DIR_REV, "tables")

for (d in c(DIR_REV, DIR_CAL, DIR_VALID, DIR_KG, DIR_ATTR, DIR_POOL,
            DIR_SCEN, DIR_THR, DIR_SENS, DIR_FIG, DIR_TAB)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ---- Environment overrides --------------------------------------------------
# Small helpers so a smoke test can be run without editing this file.
env_int <- function(name, default) {
  v <- Sys.getenv(name); if (nzchar(v)) as.integer(v) else default
}
env_num <- function(name, default) {
  v <- Sys.getenv(name); if (nzchar(v)) as.numeric(v) else default
}

# ---- External data ----------------------------------------------------------
# CAMELS-US daily forcing and streamflow (Caravan formatting, mm/day).
CARAVAN_TS       <- "D:/OneDrive/Research/Datasets/Caravan_B/timeseries/camels"
# Caravan climatic attributes (p_mean, pet_mean, aridity, frac_snow, ...).
CARAVAN_ATTR_CLIM <- "D:/OneDrive/Research/Datasets/Caravan_B/attributes/camels/attributes_caravan_camels.csv"
# HydroATLAS physiographic attributes (slope, elevation, land cover, soil, ...).
CARAVAN_ATTR_HYDRO <- "D:/OneDrive/Research/Datasets/Caravan_B/attributes/camels/attributes_hydroatlas_camels.xlsx"

# Catchment list produced by the 1-degree grid selection (Step01).
CATCHMENT_LIST <- file.path(DIR_DATA, "US_Cat_30_1Deg.csv")
# KG lookup table (numeric <-> character).
KG_LOOKUP <- file.path(DIR_DATA, "KG Classes.csv")
# KG classification function.
KG_FUNCTION <- file.path(DIR_DATA, "kg_class_all.R")

# ---- Reproducibility --------------------------------------------------------
SEED <- 20251119
set.seed(SEED)

# ---- HBV parameter space ----------------------------------------------------
# These are the numbers that appear in the manuscript. Keep code and table in
# sync. TT is -2.5 .. 2.5 (the old parRange used -1.5 by mistake).
PAR_BOUNDS <- data.frame(
  parameter = c("FC", "beta", "LP", "SFCF", "TT", "CFMAX",
                "k0", "k1", "k2", "UZL", "PERC", "MAXBAS"),
  lower = c(40,   1,   0.3, 0.4, -2.5, 1,    0.05, 0.01,  0.001, 0,  0, 1),
  upper = c(400,  6,   1.0, 1.2,  2.5, 8,    0.50, 0.30,  0.150, 70, 4, 3),
  stringsAsFactors = FALSE
)
PAR_NAMES <- PAR_BOUNDS$parameter
PAR_LOWER <- stats::setNames(PAR_BOUNDS$lower, PAR_BOUNDS$parameter)
PAR_UPPER <- stats::setNames(PAR_BOUNDS$upper, PAR_BOUNDS$parameter)

# TRUE uses the corrected triangular routing and makes MAXBAS identifiable.
# Set FALSE only to reproduce the old (routing-free) runs.
USE_ROUTING <- TRUE

# ---- Periods ----------------------------------------------------------------
# The manuscript text says 1980-2010; the data record used in the code starts in
# 1981. Use one definition everywhere.
PERIOD_FULL <- c(start = "1981-01-01", end = "2010-12-31")
PERIOD_CAL  <- c(start = "1981-01-01", end = "1995-12-31")
PERIOD_VAL  <- c(start = "1996-01-01", end = "2010-12-31")

# Moving windows: 10 years, 5-year stride, 1981-2010.
WINDOW_YEARS  <- 10
WINDOW_STRIDE <- 5

# Warm-up removed before computing any metric. 2 years is enough for HBV.
WARMUP_DAYS <- 730

# ---- Calibration ------------------------------------------------------------
N_LHS   <- 10000   # Latin hypercube size per catchment
N_LHS_VALID <- 2000  # smaller design for split-sample / moving-window stages
N_KEEP  <- 200     # behavioural sets retained per catchment (was 50)
MIN_SETS <- 50     # catchments with fewer sets are dropped

# Acceptance criteria. KGE is the screening metric (it combines correlation,
# bias and variability) and PBIAS guards systematic bias. NSE is reported but
# not used to screen, because requiring NSE >= 0.5 as well would discard many
# catchments where HBV is structurally limited (e.g. karst/regulated basins).
BEHAV_KGE   <- 0.50
BEHAV_NSE   <- -Inf
BEHAV_PBIAS <- 25    # absolute percent
BEHAV_KGE   <- env_num("TSFT_KGE", BEHAV_KGE)
BEHAV_NSE   <- env_num("TSFT_NSE", BEHAV_NSE)
BEHAV_PBIAS <- env_num("TSFT_PBIAS", BEHAV_PBIAS)
MIN_SETS    <- env_int("TSFT_MIN_SETS", MIN_SETS)

# ---- Climate scenarios ------------------------------------------------------
DP <- seq(0.5, 1.5, by = 0.1)   # precipitation multiplier
DT <- seq(-2, 8, by = 1)        # temperature offset, deg C

# Catchments with more than this fraction of scenarios in an unsupported KG
# class are reported separately (the main comparison uses all supported cells).
MAX_FALLBACK <- 0.10

# Number of parameter sets used for each scenario ensemble.
N_ENSEMBLE <- 50

# Keep the full per-set scenario output? FALSE stores only the cell summary
# (enough for thresholds and figures) and keeps the output folder small.
SAVE_SCENARIO_SETS <- FALSE

# Also diagnose the old KDE resampler? Slow in 12 dimensions; only needed for
# the one-off methodological comparison.
DIAG_KDE <- FALSE

# ---- Flow indicators and vulnerability classes ------------------------------
# Three indicators are analysed together. MAR is the primary indicator and
# carries the headline claims; LFI and MAMF are reported alongside it with the
# same four-class vulnerability scale so the reader can see whether a
# conclusion is indicator-specific.
INDICATORS         <- c("MAR", "LFI", "MAMF")
PRIMARY_INDICATOR  <- "MAR"
SENS_METRICS       <- INDICATORS

INDICATOR_META <- data.frame(
  indicator = INDICATORS,
  label = c("Mean annual runoff", "Low-flow index", "High-flow ratio"),
  unit  = c("mm yr-1", "dimensionless", "dimensionless"),
  direction = c("decrease", "decrease", "increase"),
  role = c("primary", "supplementary", "supplementary"),
  stringsAsFactors = FALSE
)

# Relative change (%) -> class 0 (no vulnerability), 1 (-25..0), 2 (-50..-25),
# 3 (<-50) when a DECREASE is the vulnerability. When an INCREASE is the
# vulnerability (MAMF, high-flow intensification) the sign is reversed.
VULN_BREAKS <- c(-Inf, -50, -25, 0, Inf)
VULN_LABELS <- c(3, 2, 1, 0)

# ---- KG map: Beck et al. (2023) class scheme, delta-change logic ------------
# The baseline and future KG maps are NOT copied from Beck et al.'s gridded
# product. They use the same logic: take the observed 1981-2010 monthly
# climatology, apply a delta change (P x dp, T + dt), and reclassify with the
# Beck et al. (2023) class scheme (01-analysis/data/kg_class_all.R).
#
# The delta-change grid uses the SAME precipitation perturbations as the
# vulnerability analysis: dp = 0.5 ... 1.5, i.e. delta P from -50% to +50%.
# Combined with the four warming levels this gives 12 panels. If
# catchment-specific CMIP6/Beck deltas become available, replace the dp column
# with those values and the maps become directly comparable with Beck et al.
# (2023); here they are a controlled delta-change experiment.
KG_MAP_LEVELS <- data.frame(
  expand.grid(dt = c(1.5, 2.0, 3.0, 4.0),
              dp = c(0.5, 1.0, 1.5)),
  stringsAsFactors = FALSE
)
KG_MAP_LEVELS$level <- sprintf("+%.1f C, P x %.1f",
                               KG_MAP_LEVELS$dt, KG_MAP_LEVELS$dp)
KG_MAP_LEVELS <- KG_MAP_LEVELS[, c("level", "dt", "dp")]
KG_BASELINE_LABEL <- "1981-2010"

# ---- Computation ------------------------------------------------------------
N_CORES <- max(1L, min(8L, parallel::detectCores() - 1L))

# Runtime overrides (useful for smoke tests without editing the file).
N_LHS       <- env_int("TSFT_N_LHS", N_LHS)
N_LHS_VALID <- env_int("TSFT_N_LHS_VALID", N_LHS_VALID)
N_KEEP      <- env_int("TSFT_N_KEEP", N_KEEP)
N_ENSEMBLE  <- env_int("TSFT_N_ENSEMBLE", N_ENSEMBLE)
N_CORES     <- env_int("TSFT_CORES", N_CORES)

# ---- Sensitivity ------------------------------------------------------------
N_PRCC   <- 2000
SOBOL_N  <- 512
N_PRCC   <- env_int("TSFT_N_PRCC", N_PRCC)
SOBOL_N  <- env_int("TSFT_SOBOL_N", SOBOL_N)
SENS_CLASSES <- c("BSk", "Cfa", "Cfb", "Dfa", "Dfb", "Dfc")

# ---- Plotting ---------------------------------------------------------------
FIG_DPI <- 300
FIG_WIDTH <- 7
FIG_HEIGHT <- 5

# ---- Small helpers ----------------------------------------------------------
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L || is.na(a[1])) b else a

msg <- function(...) cat(sprintf("[%s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n", sep = "")
