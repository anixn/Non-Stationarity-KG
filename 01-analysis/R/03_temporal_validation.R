# =============================================================================
# 03_temporal_validation.R
# Real temporal evidence for parameter non-stationarity.
#
# Three experiments per catchment:
#   (1) Differential split-sample: calibrate 1981-1995 -> validate 1996-2010.
#   (2) Reverse split:              calibrate 1996-2010 -> validate 1981-1995.
#   (3) Moving window:              10-year windows, 5-year stride, recalibrate
#                                   each window and track parameter medians.
#
# This is the analysis Reviewer #2 (major 2) and Reviewer #4 asked for.
#
# Outputs (02-outputs/revision/validation/):
#   split_sample.csv      per catchment x direction
#   parameter_windows.csv per catchment x window x parameter
#   drift_trends.csv      per catchment x parameter slope over time
# Tables:
#   T4_split_sample_summary.csv
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("future", "future.apply", "lhs"))
set_parallel(N_CORES)

meta <- read_catchment_meta()
ids <- meta$gauge_id

# Validate only the catchments that survived calibration, so the temporal
# evidence refers to the same sample as the rest of the paper.
cal_ids <- sub("_behav\\.csv$", "",
               list.files(file.path(DIR_CAL, "psets"),
                          pattern = "_behav\\.csv$"))
if (!length(cal_ids)) {
  stop("No calibrated catchments in ", file.path(DIR_CAL, "psets"),
       ". Run 02_calibrate.R first.", call. = FALSE)
}
ids <- intersect(ids, cal_ids)

if (nzchar(Sys.getenv("TSFT_CATCHMENTS"))) {
  ids <- trimws(strsplit(Sys.getenv("TSFT_CATCHMENTS"), ",")[[1]])
}
if (nzchar(Sys.getenv("TSFT_NCATCH"))) ids <- utils::head(ids, as.integer(Sys.getenv("TSFT_NCATCH")))
msg("temporal validation for ", length(ids), " catchments")

# ---- Helpers ----------------------------------------------------------------
# Median parameter values of the top-n sets by KGE (used for drift, where a
# strict behavioural filter would leave some windows empty).
top_medians <- function(cal, n = 20) {
  b <- cal[order(-cal$KGE), , drop = FALSE]
  b <- utils::head(b[is.finite(b$KGE), , drop = FALSE], n)
  if (!nrow(b)) return(NULL)
  out <- data.frame(gauge_id = cal$gauge_id[1], n = nrow(b),
                    KGE_best = max(b$KGE), KGE_med = stats::median(b$KGE))
  for (p in PAR_NAMES) out[[p]] <- stats::median(b[[p]])
  out
}

split_file <- file.path(DIR_VALID, "split_sample.csv")
win_file   <- file.path(DIR_VALID, "parameter_windows.csv")
done_split <- if (file.exists(split_file)) unique(read_out(split_file)$gauge_id) else character()
done_win   <- if (file.exists(win_file)) unique(read_out(win_file)$gauge_id) else character()

append_row <- function(x, f) {
  utils::write.table(x, f, sep = ",", row.names = FALSE,
                     col.names = !file.exists(f), append = file.exists(f))
}

# ---- (1,2) Differential split-sample ---------------------------------------
for (id in setdiff(ids, done_split)) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  for (dir in c("forward", "reverse")) {
    per_cal <- if (dir == "forward") PERIOD_CAL else PERIOD_VAL
    per_val <- if (dir == "forward") PERIOD_VAL else PERIOD_CAL
    cal <- tryCatch(calibrate_catchment(id, period = per_cal, latitude = lat,
                                        n_lhs = N_LHS_VALID), error = function(e) NULL)
    if (is.null(cal)) next
    b <- select_behavioural(cal)
    if (nrow(b) < 5) b <- utils::head(cal[order(-cal$KGE), , drop = FALSE], 20)
    val <- evaluate_sets(id, per_val, b, latitude = lat)
    append_row(data.frame(
      gauge_id = id, direction = dir,
      n_cal_sets = nrow(b),
      KGE_cal = stats::median(b$KGE), NSE_cal = stats::median(b$NSE),
      KGE_val = stats::median(val$KGE), NSE_val = stats::median(val$NSE),
      PBIAS_val = stats::median(val$PBIAS),
      dKGE = stats::median(val$KGE) - stats::median(b$KGE),
      dNSE = stats::median(val$NSE) - stats::median(b$NSE),
      frac_val_behav = mean(val$KGE >= BEHAV_KGE & val$NSE >= BEHAV_NSE &
                              abs(val$PBIAS) <= BEHAV_PBIAS, na.rm = TRUE)
    ), split_file)
  }
  msg(id, " split-sample done")
}

# ---- (3) Moving windows -----------------------------------------------------
yrs <- seq(1981, 2010 - WINDOW_YEARS + 1, by = WINDOW_STRIDE)
windows <- lapply(yrs, function(y) {
  c(start = paste0(y, "-01-01"), end = paste0(y + WINDOW_YEARS - 1, "-12-31"),
    mid = y + (WINDOW_YEARS - 1) / 2)
})

for (id in setdiff(ids, done_win)) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  for (w in windows) {
    cal <- tryCatch(calibrate_catchment(id, period = c(start = unname(w["start"]),
                                                       end = unname(w["end"])),
                                        latitude = lat, n_lhs = N_LHS_VALID),
                    error = function(e) NULL)
    if (is.null(cal)) next
    s <- top_medians(cal)
    if (is.null(s)) next
    s$window_start <- as.integer(substr(w["start"], 1, 4))
    s$window_mid <- as.numeric(w["mid"])
    append_row(s, win_file)
  }
  msg(id, " moving windows done")
}

future::plan(future::sequential)

# ---- Drift trends -----------------------------------------------------------
if (file.exists(win_file)) {
  w <- read_out(win_file)
  tr <- do.call(rbind, lapply(split(w, w$gauge_id), function(d) {
    do.call(rbind, lapply(PAR_NAMES, function(p) {
      if (length(unique(d$window_mid)) < 3 || stats::sd(d[[p]], na.rm = TRUE) == 0)
        return(data.frame(gauge_id = d$gauge_id[1], parameter = p,
                          slope = NA, r2 = NA, p = NA, drift_pct = NA))
      fit <- stats::lm(d[[p]] ~ d$window_mid)
      rng <- diff(range(d$window_mid))
      data.frame(gauge_id = d$gauge_id[1], parameter = p,
                 slope = stats::coef(fit)[2],
                 r2 = summary(fit)$r.squared,
                 p = summary(fit)$coefficients[2, 4],
                 # drift over the window span as a % of the physical range
                 drift_pct = 100 * (stats::coef(fit)[2] * rng) /
                   (PAR_UPPER[p] - PAR_LOWER[p]))
    }))
  }))
  write_out(tr, file.path(DIR_VALID, "drift_trends.csv"))
}

# ---- Summary tables ---------------------------------------------------------
if (file.exists(split_file)) {
  s <- read_out(split_file)
  sm <- s |>
    dplyr::group_by(direction) |>
    dplyr::summarise(
      n = dplyr::n(),
      KGE_cal = round(median(KGE_cal, na.rm = TRUE), 3),
      KGE_val = round(median(KGE_val, na.rm = TRUE), 3),
      dKGE = round(median(dKGE, na.rm = TRUE), 3),
      dNSE = round(median(dNSE, na.rm = TRUE), 3),
      pct_with_KGE_drop = round(100 * mean(dKGE < 0, na.rm = TRUE), 1),
      pct_val_still_behav = round(100 * mean(frac_val_behav >= 0.5, na.rm = TRUE), 1),
      .groups = "drop"
    )
  write_out(sm, file.path(DIR_TAB, "T4_split_sample_summary.csv"))
}
