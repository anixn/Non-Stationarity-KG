# =============================================================================
# 02_calibrate.R
# Monte-Carlo (LHS) calibration of HBV for every selected catchment.
#
# Fixes relative to Step02/Step04:
#   * Hargreaves PET now in mm/day (0.408 conversion)
#   * corrected routing (MAXBAS is identifiable) and zero initial snowpack
#   * explicit warm-up and acceptance thresholds
#   * correct KGE/NSE/PBIAS column labels
#   * resumable, one file per catchment
#
# Outputs (02-outputs/revision/calibration/):
#   psets/<id>_behav.csv    all behavioural sets (params + metrics)
#   summary.csv             median/q05/q95 of retained sets per catchment
#   performance.csv         calibration diagnostics per catchment
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("future", "future.apply", "lhs"))
set_parallel(N_CORES)

# ---- Catchments -------------------------------------------------------------
meta <- read_catchment_meta()
ids <- meta$gauge_id
if (nzchar(Sys.getenv("TSFT_CATCHMENTS"))) {
  ids <- strsplit(Sys.getenv("TSFT_CATCHMENTS"), ",")[[1]]
  ids <- trimws(ids)
}
if (nzchar(Sys.getenv("TSFT_NCATCH"))) {
  ids <- utils::head(ids, as.integer(Sys.getenv("TSFT_NCATCH")))
}
msg("calibrating ", length(ids), " catchments with N_LHS = ", N_LHS,
    " on ", N_CORES, " workers")

dir.create(file.path(DIR_CAL, "psets"), recursive = TRUE, showWarnings = FALSE)

# ---- Resume ----------------------------------------------------------------
perf_file <- file.path(DIR_CAL, "performance.csv")
done <- if (file.exists(perf_file)) read_out(perf_file)$gauge_id else character()
ids <- setdiff(ids, done)
msg(length(ids), " catchments left to run")

# ---- Main loop --------------------------------------------------------------
for (id in ids) {
  t0 <- Sys.time()
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  cal <- tryCatch(
    calibrate_catchment(id, period = PERIOD_FULL, latitude = lat,
                        n_lhs = N_LHS, verbose = TRUE),
    error = function(e) { msg("FAILED ", id, ": ", conditionMessage(e)); NULL }
  )
  if (is.null(cal)) next

  b <- select_behavioural(cal)
  # Only catchments with enough behavioural sets enter the downstream analysis
  # (pools, scenarios, thresholds, attribution). Keeping summary.csv and the
  # psets folder on the same inclusion rule prevents an attribution sample
  # that differs from the scenario sample.
  if (nrow(b) >= MIN_SETS) {
    utils::write.csv(b, file.path(DIR_CAL, "psets", paste0(id, "_behav.csv")),
                     row.names = FALSE)
    s <- summarise_parameters(cal)
    if (!is.null(s)) {
      f <- file.path(DIR_CAL, "summary.csv")
      utils::write.table(s, f, sep = ",", row.names = FALSE,
                         col.names = !file.exists(f), append = file.exists(f))
    }
  }

  perf <- data.frame(
    gauge_id = id,
    n_sim = nrow(cal),
    n_behav = sum(cal$behavioural, na.rm = TRUE),
    n_kept = nrow(b),
    KGE_best = max(cal$KGE, na.rm = TRUE),
    KGE_med_behav = if (nrow(b)) stats::median(b$KGE) else NA,
    NSE_best = max(cal$NSE, na.rm = TRUE),
    NSE_med_behav = if (nrow(b)) stats::median(b$NSE) else NA,
    PBIAS_med_behav = if (nrow(b)) stats::median(b$PBIAS) else NA,
    seconds = as.numeric(difftime(Sys.time(), t0, units = "secs"))
  )
  utils::write.table(perf, perf_file, sep = ",", row.names = FALSE,
                     col.names = !file.exists(perf_file), append = file.exists(perf_file))
  msg(id, " done: ", perf$n_behav, " behavioural, best KGE ",
      round(perf$KGE_best, 3), " (", round(perf$seconds), " s)")
}

future::plan(future::sequential)

# ---- Calibration report -----------------------------------------------------
if (file.exists(perf_file)) {
  p <- read_out(perf_file)
  nse_label <- if (is.finite(BEHAV_NSE))
    paste0("% catchments NSE >= ", BEHAV_NSE) else
    "% catchments NSE >= 0.5 (reported, not used to screen)"
  report <- data.frame(
    metric = c("catchments", "median KGE (behavioural)", "median NSE (behavioural)",
               "median |PBIAS| (behavioural)",
               paste0("% catchments KGE >= ", BEHAV_KGE),
               nse_label,
               paste0("% catchments with >= ", MIN_SETS, " sets")),
    value = c(
      nrow(p),
      round(stats::median(p$KGE_med_behav, na.rm = TRUE), 3),
      round(stats::median(p$NSE_med_behav, na.rm = TRUE), 3),
      round(stats::median(abs(p$PBIAS_med_behav), na.rm = TRUE), 3),
      round(100 * mean(p$KGE_med_behav >= BEHAV_KGE, na.rm = TRUE), 1),
      round(100 * mean(p$NSE_med_behav >= 0.5, na.rm = TRUE), 1),
      round(100 * mean(p$n_kept >= MIN_SETS, na.rm = TRUE), 1)
    )
  )
  write_out(report, file.path(DIR_TAB, "T3_calibration_summary.csv"))
}
