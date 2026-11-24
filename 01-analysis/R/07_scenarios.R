# =============================================================================
# 07_scenarios.R
# Simulate every catchment under the 11 x 11 delta-change scenarios, under both
# the stationary parameter framework (SPF) and the climate-zone-informed
# parameter evolution framework (CZIPEF).
#
# SPF    : the historical behavioural sets are used for every scenario.
# CZIPEF : when the scenario moves the catchment into a different KG class, the
#          parameter set is resampled from that class's pool; otherwise the
#          historical sets are used. Novel classes are flagged as fallback.
#
# Vulnerability classes are computed per parameter set relative to the median
# historical indicator (the baseline ensemble), which keeps the definition
# identical across the two frameworks and avoids matching resampled rows to
# historical rows by position (a bug in Step07).
#
# Outputs (02-outputs/revision/scenarios/):
#   cells/<id>.csv   cell summary per catchment (both frameworks)
#   cells_all.csv    combined cell summary
#   fallback.csv     fraction of scenarios without pool support
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("future", "future.apply", "data.table"))
set_parallel(N_CORES)

pools <- readRDS(file.path(DIR_POOL, "pools.rds"))
kg_base <- read_out(file.path(DIR_KG, "kg_baseline.csv"))
kg_scen <- read_out(file.path(DIR_KG, "kg_scenario_long.csv"))
meta <- read_catchment_meta()

pset_dir <- file.path(DIR_CAL, "psets")
ids <- intersect(meta$gauge_id, unique(kg_base$gauge_id))
ids <- ids[file.exists(file.path(pset_dir, paste0(ids, "_behav.csv")))]

dir.create(file.path(DIR_SCEN, "cells"), recursive = TRUE, showWarnings = FALSE)
done <- sub("\\.csv$", "", list.files(file.path(DIR_SCEN, "cells")))
ids <- setdiff(ids, done)
msg("scenario simulation for ", length(ids), " catchments")

# ---- One catchment ----------------------------------------------------------
run_one <- function(id) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  f <- read_forcing(id, PERIOD_FULL, latitude = lat)
  base_all <- read_out(file.path(pset_dir, paste0(id, "_behav.csv")))
  if (nrow(base_all) < 5) return(NULL)
  # A random sample of the behavioural sets (not the top-K), so the scenario
  # ensemble represents the behavioural space rather than only the best fits.
  set.seed(hash_seed(paste0(id, "ensemble")))
  base <- base_all[sample.int(nrow(base_all), min(N_ENSEMBLE, nrow(base_all))), ,
                   drop = FALSE]
  base_ps <- as.matrix(base[, PAR_NAMES])

  base_class <- kg_base$class[match(id, kg_base$gauge_id)]
  scen <- kg_scen[kg_scen$gauge_id == id, , drop = FALSE]
  eval_idx <- seq.int(min(WARMUP_DAYS + 1L, length(f$Q)), length(f$Q))

  run_ensemble <- function(ps, P, Temp, PET) {
    t(vapply(seq_len(nrow(ps)), function(j) {
      q <- hbv(unlist(ps[j, ], use.names = FALSE), P, Temp, PET,
               routing = USE_ROUTING)
      c(perf_metrics(f$Q[eval_idx], q[eval_idx]),
        flow_indices(f$date[eval_idx], q[eval_idx]))
    }, numeric(7)))
  }

  # Baseline at dp = 1, dt = 0. The reference median is computed from the
  # FULL retained behavioural pool (not the N_ENSEMBLE subsample used for the
  # scenarios), so the vulnerability classes are not sensitive to which 50
  # sets happened to be drawn. All three indicators are classified; MAR is the
  # primary one and must have a positive baseline for a relative change to be
  # defined. LFI can be zero in ephemeral catchments, in which case that
  # indicator is left NA rather than discarding the catchment.
  ind_all <- run_ensemble(as.matrix(base_all[, PAR_NAMES]), f$P, f$Temp, f$PET)
  base_med <- apply(ind_all[, INDICATORS, drop = FALSE], 2, stats::median,
                    na.rm = TRUE)
  ind0 <- run_ensemble(base_ps, f$P, f$Temp, f$PET)
  valid_ind <- is.finite(base_med) & base_med > 0
  names(valid_ind) <- INDICATORS
  if (!isTRUE(valid_ind[[PRIMARY_INDICATOR]])) return(NULL)

  # Resample cache per target class (one ensemble per class, seeded).
  resample_cache <- list()
  for (cl in unique(scen$class)) {
    if (is.na(cl) || is.na(base_class) || cl == base_class || is.null(pools[[cl]])) next
    resample_cache[[cl]] <- as.matrix(
      resample_params(pools[[cl]], N_ENSEMBLE,
                      seed = hash_seed(paste0(id, cl)))
    )
  }

  rows <- list()
  for (i in seq_len(nrow(scen))) {
    dp <- scen$dp[i]; dt <- scen$dt[i]; target <- scen$class[i]
    P    <- f$P * dp
    Temp <- f$Temp + dt
    Tmin <- f$Tmin + dt; Tmax <- f$Tmax + dt
    PET  <- hargreaves_pet(Tmin, Tmax, lat, f$date)

    # SPF
    ind_spf <- if (dp == 1 && dt == 0) ind0 else run_ensemble(base_ps, P, Temp, PET)

    # CZIPEF
    fallback <- FALSE
    if (!is.na(target) && !is.na(base_class) && target != base_class &&
        !is.null(resample_cache[[target]])) {
      ind_cz <- run_ensemble(resample_cache[[target]], P, Temp, PET)
      source_lab <- paste0("pool:", target)
    } else {
      ind_cz <- ind_spf
      source_lab <- "baseline"
      if (is.na(target) || is.na(base_class) || target != base_class) fallback <- TRUE
    }

    one <- function(ind, framework) {
      rel <- matrix(NA_real_, nrow(ind), length(INDICATORS),
                    dimnames = list(NULL, INDICATORS))
      for (k in INDICATORS) {
        if (valid_ind[[k]]) rel[, k] <- ind[, k] / base_med[[k]] - 1
      }
      cls <- vuln_class_matrix(100 * rel, INDICATORS)
      out <- data.frame(
        gauge_id = id, framework = framework, dp = dp, dt = dt,
        class_from = base_class, class_to = target, fallback = fallback,
        param_source = source_lab,
        n = nrow(ind),
        KGE_med = stats::median(ind[, "KGE"], na.rm = TRUE),
        NSE_med = stats::median(ind[, "NSE"], na.rm = TRUE),
        PBIAS_med = stats::median(ind[, "PBIAS"], na.rm = TRUE)
      )
      for (k in INDICATORS) {
        key <- tolower(k)
        out[[paste0(key, "_med")]] <- stats::median(ind[, k], na.rm = TRUE)
        out[[paste0(key, "_p05")]] <- stats::quantile(ind[, k], 0.05,
                                                      na.rm = TRUE, names = FALSE)
        out[[paste0(key, "_p95")]] <- stats::quantile(ind[, k], 0.95,
                                                      na.rm = TRUE, names = FALSE)
        out[[paste0("p3_", key)]] <- mean(cls[[k]] == 3, na.rm = TRUE)
      }
      out
    }
    rows[[length(rows) + 1]] <- one(ind_spf, "SPF")
    rows[[length(rows) + 1]] <- one(ind_cz, "CZIPEF")
  }

  out <- data.table::rbindlist(rows)
  data.table::fwrite(out, file.path(DIR_SCEN, "cells", paste0(id, ".csv")))
  msg(id, " done (fallback scenarios: ", sum(out$fallback & out$framework == "CZIPEF"), ")")
  out
}

# ---- Run --------------------------------------------------------------------
if (length(ids)) {
  res <- future.apply::future_lapply(ids, function(id) {
    tryCatch(run_one(id), error = function(e) {
      message("FAILED ", id, ": ", conditionMessage(e)); NULL
    })
  }, future.seed = TRUE)
} else {
  res <- list()
}
future::plan(future::sequential)

# ---- Combine ----------------------------------------------------------------
cell_files <- list.files(file.path(DIR_SCEN, "cells"), full.names = TRUE)
if (length(cell_files)) {
  all <- data.table::rbindlist(lapply(cell_files, data.table::fread), fill = TRUE)
  data.table::fwrite(all, file.path(DIR_SCEN, "cells_all.csv"))
  fb <- all[all$framework == "CZIPEF", .(fallback_frac = mean(fallback)),
            by = gauge_id]
  data.table::fwrite(fb, file.path(DIR_SCEN, "fallback.csv"))
  msg("combined ", length(cell_files), " catchments into cells_all.csv")
}
