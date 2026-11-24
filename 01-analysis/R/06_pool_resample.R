# =============================================================================
# 06_pool_resample.R
# Climate-zone parameter pools and a bounded, correlation-preserving resampler.
#
# Replaces the univariate KDE in Step05, which (i) reset the RNG for every
# parameter, (ii) produced ~1% out-of-bounds values, and (iii) destroyed
# parameter correlations. The default is now a Gaussian copula with empirical
# marginals (bounded by construction); KDE is kept only as a sensitivity check.
#
# Outputs (02-outputs/revision/pools/):
#   <class>_pool.csv          pooled behavioural sets per KG class
#   pool_summary.csv          pool sizes and parameter medians
#   resample_diagnostics.csv  bounds / correlation / KS diagnostics
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("mvtnorm", "dplyr"))

kg_f <- file.path(DIR_KG, "kg_baseline.csv")
if (!file.exists(kg_f)) stop("Run 04_kg_transitions.R first")
kg <- read_out(kg_f)

pset_dir <- file.path(DIR_CAL, "psets")
files <- list.files(pset_dir, pattern = "_behav\\.csv$", full.names = TRUE)
if (!length(files)) stop("No behavioural sets found in ", pset_dir)

# ---- Build pools ------------------------------------------------------------
pools <- list()
for (f in files) {
  b <- read_out(f)
  id <- b$gauge_id[1]
  cl <- kg$class[match(id, kg$gauge_id)]
  if (is.na(cl)) next
  b <- b[, PAR_NAMES]
  pools[[cl]] <- rbind(pools[[cl]], b)
}
pools <- lapply(pools, function(x) x[stats::complete.cases(x), , drop = FALSE])
pools <- pools[vapply(pools, nrow, integer(1)) >= 20]
msg("pools: ", paste(names(pools), vapply(pools, nrow, integer(1)), sep = "=",
                     collapse = ", "))

for (cl in names(pools)) {
  write_out(pools[[cl]], file.path(DIR_POOL, paste0(cl, "_pool.csv")))
}

pool_summary <- do.call(rbind, lapply(names(pools), function(cl) {
  x <- pools[[cl]]
  out <- data.frame(kg_class = cl, n_sets = nrow(x))
  for (p in PAR_NAMES) out[[paste0("med_", p)]] <- stats::median(x[[p]])
  out
}))
write_out(pool_summary, file.path(DIR_POOL, "pool_summary.csv"))

# ---- Diagnostics: old KDE vs new copula ------------------------------------
diag_rows <- list()
for (cl in names(pools)) {
  pool <- as.matrix(pools[[cl]])
  if (nrow(pool) < 50) next
  for (method in if (DIAG_KDE) c("copula", "kde") else "copula") {
    set.seed(SEED)
    rs <- tryCatch(resample_params(as.data.frame(pool), 1000, method = method),
                   error = function(e) NULL)
    if (is.null(rs)) next
    ob <- sum(vapply(PAR_NAMES, function(p)
      sum(rs[[p]] < PAR_LOWER[p] | rs[[p]] > PAR_UPPER[p]), integer(1)))
    vc <- which(apply(pool, 2, stats::sd) > 0)
    cd <- if (length(vc) > 1) {
      max(abs(stats::cor(pool[, vc], method = "spearman") -
                stats::cor(as.matrix(rs)[, vc], method = "spearman")))
    } else NA
    ks <- vapply(PAR_NAMES, function(p)
      suppressWarnings(stats::ks.test(pool[, p], rs[[p]])$p.value), numeric(1))
    diag_rows[[paste(cl, method)]] <- data.frame(
      kg_class = cl, method = method, n = nrow(rs),
      out_of_bounds = ob,
      max_cor_diff = cd,
      ks_reject_5pct = sum(ks < 0.05, na.rm = TRUE)
    )
  }
}
if (length(diag_rows)) write_out(do.call(rbind, diag_rows),
                                 file.path(DIR_POOL, "resample_diagnostics.csv"))

# Persist pools for downstream scripts.
saveRDS(pools, file.path(DIR_POOL, "pools.rds"))
msg("pooling done")
