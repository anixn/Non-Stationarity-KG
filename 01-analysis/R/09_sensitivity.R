# =============================================================================
# 09_sensitivity.R
# Sensitivity (PRCC, Sobol) and parametric uncertainty, kept separate.
#
# Reviewer #2 (major 7): "uncertainty" and "sensitivity" are different.
#   Sensitivity  = how much an output responds to a parameter (PRCC, Sobol).
#   Uncertainty  = how much the output varies across the behavioural ensemble
#                  because the parameters are not identifiable (5-95% range, CV).
#
# Fixes relative to Sensitivity_HBV_V2.Rmd:
#   * uses the same corrected Hargreaves PET as the main analysis
#   * removes the warm-up before computing metrics
#   * PRCC implemented directly (the installed sensitivity::pcc is broken)
#   * Sobol uses matrices and the correct argument order
#   * confidence intervals are read from named columns, not fixed positions
#
# Outputs (02-outputs/revision/sensitivity/):
#   prcc_<id>.csv, sobol_<id>.csv, uncertainty.csv
# Table:
#   T9_sensitivity_summary.csv
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("future", "future.apply", "sensitivity", "lhs", "data.table"))
set_parallel(N_CORES)

kg <- read_out(file.path(DIR_KG, "kg_baseline.csv"))
clim <- utils::read.csv(CARAVAN_ATTR_CLIM, stringsAsFactors = FALSE)
meta <- read_catchment_meta()
dd <- merge(kg, clim, by = "gauge_id", all.x = TRUE)

# One representative catchment per class: median aridity within the class.
reps <- do.call(rbind, lapply(SENS_CLASSES, function(cl) {
  d <- dd[dd$class == cl & is.finite(dd$aridity), , drop = FALSE]
  if (!nrow(d)) return(NULL)
  d[which.min(abs(d$aridity - stats::median(d$aridity))), c("gauge_id", "class", "aridity")]
}))
msg("representative catchments: ", paste(reps$gauge_id, collapse = ", "))

# ---- One catchment ----------------------------------------------------------
run_one <- function(id, cl) {
  lat <- meta$gauge_lat[match(id, meta$gauge_id)]
  f <- read_forcing(id, PERIOD_FULL, latitude = lat)
  ev <- seq.int(min(WARMUP_DAYS + 1L, length(f$Q)), length(f$Q))

  metrics_of <- function(pars) {
    q <- hbv(unlist(pars, use.names = FALSE), f$P, f$Temp, f$PET,
             routing = USE_ROUTING)
    qe <- q[ev]
    fi <- flow_indices(f$date[ev], qe)
    c(mean_flow = mean(qe, na.rm = TRUE),
      peak_flow = stats::quantile(qe, 0.95, na.rm = TRUE, names = FALSE),
      MAR = unname(fi["MAR"]), LFI = unname(fi["LFI"]), MAMF = unname(fi["MAMF"]))
  }

  # (1) PRCC
  X <- lhs_params(N_PRCC, seed = hash_seed(paste0(id, "prcc")))
  Y <- t(vapply(seq_len(nrow(X)), function(i) metrics_of(X[i, ]), numeric(5)))
  # Sensitivity is computed for the three vulnerability indicators, not only
  # for mean/peak flow, so it matches the threshold analysis.
  prcc <- do.call(rbind, lapply(SENS_METRICS, function(m) {
    p <- prcc_manual(X, Y[, m], nboot = 300)
    p$metric <- m
    p
  }))
  prcc$gauge_id <- id; prcc$kg_class <- cl
  data.table::fwrite(prcc, file.path(DIR_SENS, paste0("prcc_", id, ".csv")))

  # (2) Sobol (Saltelli)
  X1 <- lhs::randomLHS(SOBOL_N, length(PAR_NAMES))
  X2 <- lhs::randomLHS(SOBOL_N, length(PAR_NAMES))
  colnames(X1) <- colnames(X2) <- PAR_NAMES
  to_par <- function(u) {
    p <- PAR_LOWER + sweep(u, 2, PAR_UPPER - PAR_LOWER, "*")
    p
  }
  sob <- list()
  for (m in SENS_METRICS) {
    fn <- function(U) {
      U <- as.matrix(U)
      apply(U, 1, function(r) {
        p <- to_par(matrix(r, nrow = 1))
        colnames(p) <- PAR_NAMES
        metrics_of(p)[m]
      })
    }
    s <- tryCatch(sobol_indices(X1, X2, fn), error = function(e) NULL)
    if (!is.null(s)) { s$metric <- m; sob[[m]] <- s }
  }
  if (length(sob)) {
    sob <- data.table::rbindlist(sob)
    sob$gauge_id <- id; sob$kg_class <- cl
    data.table::fwrite(sob, file.path(DIR_SENS, paste0("sobol_", id, ".csv")))
  }

  # (3) Parametric uncertainty from the behavioural ensemble
  pf <- file.path(DIR_CAL, "psets", paste0(id, "_behav.csv"))
  if (!file.exists(pf)) return(NULL)
  ps <- utils::head(read_out(pf), N_KEEP)
  U <- t(vapply(seq_len(nrow(ps)), function(i) metrics_of(ps[i, PAR_NAMES]), numeric(5)))
  unc <- data.frame(
    gauge_id = id, kg_class = cl, n_sets = nrow(U),
    metric = colnames(U),
    median = apply(U, 2, stats::median, na.rm = TRUE),
    q05 = apply(U, 2, stats::quantile, 0.05, na.rm = TRUE),
    q95 = apply(U, 2, stats::quantile, 0.95, na.rm = TRUE),
    cv = apply(U, 2, function(x) stats::sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)),
    row.names = NULL
  )
  data.table::fwrite(unc, file.path(DIR_SENS, paste0("uncertainty_", id, ".csv")))
  unc
}

# ---- Run --------------------------------------------------------------------
res <- future.apply::future_lapply(seq_len(nrow(reps)), function(i) {
  tryCatch(run_one(reps$gauge_id[i], reps$class[i]),
           error = function(e) { message("FAILED ", reps$gauge_id[i], ": ",
                                         conditionMessage(e)); NULL })
}, future.seed = TRUE)
future::plan(future::sequential)

# ---- Combine ----------------------------------------------------------------
unc_files <- list.files(DIR_SENS, pattern = "^uncertainty_.*csv$", full.names = TRUE)
if (length(unc_files)) {
  unc <- data.table::rbindlist(lapply(unc_files, data.table::fread), fill = TRUE)
  data.table::fwrite(unc, file.path(DIR_SENS, "uncertainty.csv"))
}

prcc_files <- list.files(DIR_SENS, pattern = "^prcc_.*csv$", full.names = TRUE)
if (length(prcc_files)) {
  prcc <- data.table::rbindlist(lapply(prcc_files, data.table::fread), fill = TRUE)
  # Significant parameters (|estimate| >= 0.2 and CI excludes 0), by metric.
  sig <- prcc[abs(estimate) >= 0.2 & (lower > 0 | upper < 0),
              .(n_significant = .N,
                parameters = paste(sort(unique(parameter)), collapse = ", ")),
              by = .(kg_class, metric)]
  data.table::fwrite(sig, file.path(DIR_TAB, "T9_sensitivity_summary.csv"))
}
msg("sensitivity done")
