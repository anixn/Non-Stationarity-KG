# =============================================================================
# run_all.R
# Orchestrate the CZIPEF revision pipeline.
#
# Examples
#   Rscript 01-analysis/R/run_all.R
#   TSFT_STAGES=02,04 Rscript 01-analysis/R/run_all.R
#   TSFT_NCATCH=10 Rscript 01-analysis/R/run_all.R        # smoke test
#
# Stage order matters: calibration -> KG -> attribution -> pools -> scenarios
# -> thresholds -> sensitivity -> figures.
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R"))
}

stages <- Sys.getenv("TSFT_STAGES", unset = "02,03,04,05,06,07,08,09,10")
stages <- trimws(strsplit(stages, ",")[[1]])

scripts <- c(
  "02" = "02_calibrate.R",
  "03" = "03_temporal_validation.R",
  "04" = "04_kg_transitions.R",
  "05" = "05_parameter_controls.R",
  "06" = "06_pool_resample.R",
  "07" = "07_scenarios.R",
  "08" = "08_thresholds.R",
  "09" = "09_sensitivity.R",
  "10" = "10_figures.R"
)

for (s in stages) {
  if (!s %in% names(scripts)) {
    warning("Unknown stage: ", s, call. = FALSE); next
  }
  f <- file.path(DIR_R, scripts[[s]])
  if (!file.exists(f)) { warning("Missing script: ", f, call. = FALSE); next }
  msg("=== stage ", s, ": ", scripts[[s]], " ===")
  t0 <- Sys.time()
  ok <- tryCatch({
    sys.source(f, envir = new.env(parent = globalenv()))
    TRUE
  }, error = function(e) {
    msg("STAGE ", s, " FAILED: ", conditionMessage(e))
    FALSE
  })
  msg("=== stage ", s, if (ok) "done" else "failed", " in ",
      round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), " min ===")
  if (!ok && Sys.getenv("TSFT_STOP_ON_ERROR", "1") == "1") break
}
