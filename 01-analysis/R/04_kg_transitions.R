# =============================================================================
# 04_kg_transitions.R
# Köppen-Geiger classes for the baseline, observed decades, and the synthetic
# delta-change scenarios.
#
# This script answers Reviewer #2 (major 4 and 6): the KG criteria are explicit,
# and the question "did climate zones actually change?" is answered with
# observations, not only with synthetic scenarios.
#
# Outputs (02-outputs/revision/kg/):
#   kg_baseline.csv          baseline class 1981-2010 per catchment
#   kg_decadal.csv           3 observed decades per catchment
#   kg_annual.csv            annual class per catchment (supplementary)
#   kg_scenario_long.csv     class for each (catchment, dp, dt)
#   kg_transition_summary.csv per-catchment transition statistics
#   observed_transitions.csv  decadal transitions
#   kg_map_levels.csv        baseline/future class at each warming level
#   kg_map_summary.csv       transition counts per warming level
# Tables:
#   T5_kg_transition_summary.csv, T5b_kg_map_transitions.csv
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs("dplyr")

meta <- read_catchment_meta()
ids <- meta$gauge_id

# Classify the catchments that survived calibration, so the KG sample matches
# the scenario and threshold samples.
cal_ids <- sub("_behav\\.csv$", "",
               list.files(file.path(DIR_CAL, "psets"),
                          pattern = "_behav\\.csv$"))
if (length(cal_ids)) ids <- intersect(ids, cal_ids)
if (nzchar(Sys.getenv("TSFT_CATCHMENTS"))) {
  ids <- trimws(strsplit(Sys.getenv("TSFT_CATCHMENTS"), ",")[[1]])
}

# ---- Main loop --------------------------------------------------------------
base_f <- file.path(DIR_KG, "kg_baseline.csv")
if (file.exists(base_f)) ids <- setdiff(ids, read_out(base_f)$gauge_id)
msg("KG classification for ", length(ids), " catchments")

for (id in ids) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  f <- tryCatch(read_forcing(id, PERIOD_FULL, latitude = lat),
                error = function(e) NULL)
  if (is.null(f)) next

  # Baseline 1981-2010
  cl <- kg_class(f$date, f$P, f$Tmin, f$Tmax, f$Temp)
  utils::write.table(
    data.frame(gauge_id = id, lat = lat, lon = meta$gauge_lon[match(id, meta$gauge_id)],
               class = cl, class_n = kg_numeric(cl)),
    base_f, sep = ",", row.names = FALSE,
    col.names = !file.exists(base_f), append = file.exists(base_f))

  # Observed decades
  dec <- data.frame(gauge_id = id,
                    decade = c("1981-1990", "1991-2000", "2001-2010"),
                    class = NA_character_, stringsAsFactors = FALSE)
  for (k in seq_len(3)) {
    per <- c(start = paste0(1981 + (k - 1) * 10, "-01-01"),
             end   = paste0(1990 + (k - 1) * 10, "-12-31"))
    fd <- read_forcing(id, per, latitude = lat)
    dec$class[k] <- kg_class(fd$date, fd$P, fd$Tmin, fd$Tmax, fd$Temp)
  }
  utils::write.table(dec, file.path(DIR_KG, "kg_decadal.csv"), sep = ",",
                     row.names = FALSE,
                     col.names = !file.exists(file.path(DIR_KG, "kg_decadal.csv")),
                     append = file.exists(file.path(DIR_KG, "kg_decadal.csv")))

  # Annual classes (supplementary)
  yrs <- 1981:2010
  ann <- data.frame(
    gauge_id = id, year = yrs,
    class = vapply(yrs, function(y) {
      per <- c(start = paste0(y, "-01-01"), end = paste0(y, "-12-31"))
      fd <- read_forcing(id, per, latitude = lat)
      kg_class(fd$date, fd$P, fd$Tmin, fd$Tmax, fd$Temp)
    }, character(1))
  )
  utils::write.table(ann, file.path(DIR_KG, "kg_annual.csv"), sep = ",",
                     row.names = FALSE,
                     col.names = !file.exists(file.path(DIR_KG, "kg_annual.csv")),
                     append = file.exists(file.path(DIR_KG, "kg_annual.csv")))

  # Scenario matrix
  m <- kg_scenario_matrix(f$date, f$P, f$Tmin, f$Tmax, f$Temp)
  long <- expand.grid(dt = DT, dp = DP, KEEP.OUT.ATTRS = FALSE)
  long$gauge_id <- id
  long$class <- as.vector(m)  # column-major: dt varies fastest, matches expand.grid
  long <- long[, c("gauge_id", "dp", "dt", "class")]
  utils::write.table(long, file.path(DIR_KG, "kg_scenario_long.csv"), sep = ",",
                     row.names = FALSE,
                     col.names = !file.exists(file.path(DIR_KG, "kg_scenario_long.csv")),
                     append = file.exists(file.path(DIR_KG, "kg_scenario_long.csv")))

  msg(id, " baseline ", cl, " | decades ", paste(dec$class, collapse = " > "))
}

# ---- Beck-style delta-change KG maps ----------------------------------------
# Beck et al. (2023) classes are used through the same delta-change logic that
# produced their maps: perturb the observed monthly climatology and reclassify
# with their class scheme. This is not a copy of their gridded product and
# needs no external raster; it makes the map reproducible from the catchment
# data alone. If catchment-specific CMIP6 deltas are available, put them in
# KG_MAP_LEVELS$dp and the result becomes directly comparable with Beck.
map_f <- file.path(DIR_KG, "kg_map_levels.csv")
if (file.exists(base_f)) {
have_map <- if (file.exists(map_f)) unique(read_out(map_f)$gauge_id) else character()
todo_map <- setdiff(read_out(base_f)$gauge_id, have_map)
if (length(todo_map)) msg("delta-change KG maps for ", length(todo_map), " catchments")

for (id in todo_map) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  lon <- meta$gauge_lon[match(id, meta$gauge_id)]
  f <- tryCatch(read_forcing(id, PERIOD_FULL, latitude = lat),
                error = function(e) NULL)
  if (is.null(f)) next
  base_cl <- kg_class(f$date, f$P, f$Tmin, f$Tmax, f$Temp)
  rows <- lapply(seq_len(nrow(KG_MAP_LEVELS)), function(k) {
    lv <- KG_MAP_LEVELS[k, ]
    cl <- kg_class(f$date, f$P, f$Tmin, f$Tmax, f$Temp,
                   dp = lv$dp, dt = lv$dt)
    data.frame(
      gauge_id = id, lat = lat, lon = lon,
      level = lv$level, dp = lv$dp, dt = lv$dt,
      class_baseline = base_cl, class_future = cl,
      changed = !is.na(cl) & !is.na(base_cl) & cl != base_cl
    )
  })
  utils::write.table(do.call(rbind, rows), map_f, sep = ",", row.names = FALSE,
                     col.names = !file.exists(map_f), append = file.exists(map_f))
  msg(id, " delta-change map done")
}
}

if (file.exists(map_f)) {
  map <- read_out(map_f)
  sm <- do.call(rbind, lapply(split(map, map$level), function(d) {
    data.frame(
      level = d$level[1], dt = d$dt[1], dp = d$dp[1],
      n = nrow(d),
      n_changed = sum(d$changed, na.rm = TRUE),
      pct_changed = round(100 * mean(d$changed, na.rm = TRUE), 1),
      n_future_classes = length(unique(stats::na.omit(d$class_future)))
    )
  }))
  sm <- sm[match(KG_MAP_LEVELS$level, sm$level), , drop = FALSE]
  write_out(sm, file.path(DIR_KG, "kg_map_summary.csv"))
  write_out(sm, file.path(DIR_TAB, "T5b_kg_map_transitions.csv"))
}

# ---- Transition summaries ---------------------------------------------------
if (file.exists(base_f)) {
  base <- read_out(base_f)
  dec <- read_out(file.path(DIR_KG, "kg_decadal.csv"))
  scen <- read_out(file.path(DIR_KG, "kg_scenario_long.csv"))

  # Observed transitions
  obs <- dec |>
    dplyr::group_by(gauge_id) |>
    dplyr::summarise(
      n_unique = dplyr::n_distinct(class),
      changed = dplyr::n_distinct(class) > 1,
      classes = paste(unique(class), collapse = " > "),
      .groups = "drop"
    )
  obs <- merge(base[, c("gauge_id", "class")], obs, by = "gauge_id", all.x = TRUE)
  write_out(obs, file.path(DIR_KG, "observed_transitions.csv"))

  # Scenario transitions
  tr <- scen |>
    dplyr::group_by(gauge_id) |>
    dplyr::summarise(
      n_scen = dplyr::n(),
      n_unique = dplyr::n_distinct(class),
      frac_changed = mean(class != class[dp == 1 & dt == 0]),
      classes = paste(sort(unique(class)), collapse = ","),
      .groups = "drop"
    )
  tr <- merge(base[, c("gauge_id", "class")], tr, by = "gauge_id", all.x = TRUE)
  write_out(tr, file.path(DIR_KG, "kg_transition_summary.csv"))

  # Manuscript table
  tab <- data.frame(
    item = c("catchments classified",
             "% with >=1 observed decadal transition",
             "% with any scenario transition",
             "median number of classes visited",
             "pooled classes with parameter support"),
    value = c(
      nrow(base),
      round(100 * mean(obs$changed, na.rm = TRUE), 1),
      round(100 * mean(tr$frac_changed > 0, na.rm = TRUE), 1),
      stats::median(tr$n_unique, na.rm = TRUE),
      paste(sort(unique(base$class)), collapse = ", ")
    )
  )
  write_out(tab, file.path(DIR_TAB, "T5_kg_transition_summary.csv"))
}
