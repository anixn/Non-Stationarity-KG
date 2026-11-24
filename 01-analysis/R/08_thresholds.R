# =============================================================================
# 08_thresholds.R
# Vulnerability thresholds and the SPF vs CZIPEF comparison.
#
# Replaces the fragile CART text parsing in Step08 with two transparent
# estimators on the cell-level prevalence of the most vulnerable class:
#   * isotonic regression on the prevalence curve, crossing at 0.5;
#   * logistic prevalence model P(class 3) ~ dp * dt.
# Both learn the direction of the response instead of hard-coding split signs.
# Bootstrap intervals come from binomial resampling of the 121 cells.
#
# Outputs (02-outputs/revision/thresholds/):
#   thresholds.csv      per catchment x framework x indicator
#   comparison.csv      per catchment x indicator, SPF vs CZIPEF
#   decomposition.csv   counts / tests
# Tables:
#   T7_threshold_comparison.csv, T8_threshold_decomposition.csv
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs("data.table")

cells_f <- file.path(DIR_SCEN, "cells_all.csv")
if (!file.exists(cells_f)) stop("Run 07_scenarios.R first: ", cells_f, " missing")
cells <- data.table::fread(cells_f)
cells <- as.data.frame(cells)

indicators <- tolower(INDICATORS)

# ---- Per-catchment thresholds ----------------------------------------------
calc_one <- function(d, ind, B = 300) {
  col <- paste0("p3_", ind)
  pv <- data.frame(dp = d$dp, dt = d$dt, p3 = d[[col]], n = d$n)
  iso <- threshold_isotonic(pv)
  logi <- threshold_logistic(pv)
  bt <- threshold_boot_cells(pv, B = B)
  data.frame(
    p_thr_iso = unname(iso["p_thr"]),
    dt_thr_iso = unname(iso["dt_thr"]),
    p_thr_logit = unname(logi["p_thr"]),
    dt_thr_logit = unname(logi["dt_thr"]),
    p_lo = bt["5%", "p_thr"], p_hi = bt["95%", "p_thr"],
    dt_lo = bt["5%", "dt_thr"], dt_hi = bt["95%", "dt_thr"],
    n_cells = nrow(pv),
    identifiable = is.finite(iso["p_thr"])
  )
}

keys <- unique(cells$gauge_id)
thr <- list()
for (id in keys) {
  cz <- cells[cells$gauge_id == id & cells$framework == "CZIPEF", , drop = FALSE]
  # Compare the two frameworks on the scenarios where CZIPEF has pool support.
  # This mirrors the original exclusion of unsupported climate classes and
  # prevents fallback cells from diluting the CZIPEF signal.
  keep_key <- paste(cz$dp, cz$dt)[!cz$fallback]
  for (fw in c("SPF", "CZIPEF")) {
    d <- cells[cells$gauge_id == id & cells$framework == fw, , drop = FALSE]
    d <- d[paste(d$dp, d$dt) %in% keep_key, , drop = FALSE]
    if (nrow(d) < 20) next
    for (ind in indicators) {
      val <- tryCatch(calc_one(d, ind), error = function(e) NULL)
      if (is.null(val)) next
      thr[[length(thr) + 1]] <- cbind(
        data.frame(gauge_id = id, framework = fw, indicator = ind,
                   n_cells_used = nrow(d),
                   fallback_frac = 1 - length(keep_key) / nrow(cz)),
        val
      )
    }
  }
}
thr <- do.call(rbind, thr)
write_out(thr, file.path(DIR_THR, "thresholds.csv"))

# ---- Paired comparison ------------------------------------------------------
base <- merge(
  thr[thr$framework == "SPF", c("gauge_id", "indicator", "p_thr_iso", "dt_thr_iso",
                                "p_lo", "p_hi", "dt_lo", "dt_hi",
                                "n_cells_used", "fallback_frac")],
  thr[thr$framework == "CZIPEF", c("gauge_id", "indicator", "p_thr_iso", "dt_thr_iso",
                                   "p_lo", "p_hi", "dt_lo", "dt_hi")],
  by = c("gauge_id", "indicator"), suffixes = c("_spf", "_czip")
)
base$d_p  <- base$p_thr_iso_czip - base$p_thr_iso_spf
base$d_dt <- base$dt_thr_iso_czip - base$dt_thr_iso_spf
write_out(base, file.path(DIR_THR, "comparison.csv"))

# ---- Decomposition and tests ------------------------------------------------
decomp <- list()
for (ind in indicators) {
  for (sub in c("all", "fallback_le_10pct")) {
    d <- base[base$indicator == ind, , drop = FALSE]
    d <- d[is.finite(d$d_p), , drop = FALSE]
    if (sub == "fallback_le_10pct") d <- d[d$fallback_frac <= MAX_FALLBACK, , drop = FALSE]
    if (!nrow(d)) {
      # Keep the row so the manuscript can state that the paired threshold is
      # not identifiable for this indicator, instead of hiding it.
      decomp[[paste(ind, sub)]] <- data.frame(
        indicator = ind, subset = sub, n = 0L,
        n_higher = 0L, n_lower = 0L, n_equal = 0L,
        pct_higher = NA_real_, pct_lower = NA_real_, pct_equal = NA_real_,
        median_dp = NA_real_, mean_dp = NA_real_, binom_p = NA_real_,
        wilcox_p = NA_real_, slope = NA_real_, intercept = NA_real_,
        r2 = NA_real_
      )
      next
    }
    n_up <- sum(d$d_p > 1e-6); n_dn <- sum(d$d_p < -1e-6)
    n_eq <- sum(abs(d$d_p) <= 1e-6)
    bt <- if (n_up + n_dn > 0) stats::binom.test(n_up, n_up + n_dn, 0.5) else NULL
    wt <- suppressWarnings(stats::wilcox.test(d$d_p, mu = 0))
    fit <- stats::lm(p_thr_iso_czip ~ p_thr_iso_spf, data = d)
    decomp[[paste(ind, sub)]] <- data.frame(
      indicator = ind, subset = sub, n = nrow(d),
      n_higher = n_up, n_lower = n_dn, n_equal = n_eq,
      pct_higher = round(100 * n_up / nrow(d), 1),
      pct_lower = round(100 * n_dn / nrow(d), 1),
      pct_equal = round(100 * n_eq / nrow(d), 1),
      median_dp = round(stats::median(d$d_p, na.rm = TRUE), 4),
      mean_dp = round(mean(d$d_p, na.rm = TRUE), 4),
      binom_p = if (!is.null(bt)) round(bt$p.value, 4) else NA,
      wilcox_p = round(wt$p.value, 4),
      slope = round(stats::coef(fit)[2], 3),
      intercept = round(stats::coef(fit)[1], 3),
      r2 = round(summary(fit)$r.squared, 3)
    )
  }
}
decomp <- do.call(rbind, decomp)
if (is.null(decomp)) {
  decomp <- data.frame(indicator = character(), n = integer(),
                       n_higher = integer(), n_lower = integer(), n_equal = integer())
}
write_out(decomp, file.path(DIR_TAB, "T8_threshold_decomposition.csv"))
write_out(decomp, file.path(DIR_THR, "decomposition.csv"))

# Summary table with 95% intervals. MAR is the primary indicator; LFI and
# MAMF are reported alongside it so the reader can judge whether the SPF-CZIPEF
# conclusion is indicator-specific.
summ_rows <- list()
for (ind in indicators) {
  # Use every catchment for which this framework produced a threshold, not
  # only the paired subset. LFI/MAMF thresholds are often non-identifiable;
  # the table must show that explicitly (n and pct_identifiable) rather than
  # silently dropping the indicator.
  d_all <- thr[thr$indicator == ind, , drop = FALSE]
  if (!nrow(d_all)) next
  meta_i <- INDICATOR_META[match(toupper(ind), INDICATOR_META$indicator), ]
  for (fw in c("SPF", "CZIPEF")) {
    d <- d_all[d_all$framework == fw, , drop = FALSE]
    x <- d$p_thr_iso
    q <- if (any(is.finite(x)))
      stats::quantile(x, c(.25, .75), na.rm = TRUE, names = FALSE) else c(NA, NA)
    summ_rows[[paste(ind, fw)]] <- data.frame(
      indicator = ind,
      label = meta_i$label,
      role = meta_i$role,
      framework = fw,
      n_catchments = nrow(d),
      n = sum(is.finite(x)),
      pct_identifiable = round(100 * mean(is.finite(x)), 1),
      median_p_threshold = round(stats::median(x, na.rm = TRUE), 3),
      q25_p_threshold = round(q[1], 3),
      q75_p_threshold = round(q[2], 3),
      iqr = if (any(is.finite(x))) paste(round(q, 3), collapse = "-") else NA_character_,
      median_dt_threshold = round(stats::median(d$dt_thr_iso, na.rm = TRUE), 2)
    )
  }
}
tab <- do.call(rbind, summ_rows)
write_out(tab, file.path(DIR_TAB, "T7_threshold_comparison.csv"))

# How often is a threshold identifiable at all, by indicator and framework?
ident <- stats::aggregate(
  cbind(p_thr = is.finite(thr$p_thr_iso), dt_thr = is.finite(thr$dt_thr_iso)) ~
    indicator + framework,
  data = thr, FUN = mean
)
ident$p_thr_pct  <- round(100 * ident$p_thr, 1)
ident$dt_thr_pct <- round(100 * ident$dt_thr, 1)
ident <- ident[, c("indicator", "framework", "p_thr_pct", "dt_thr_pct")]
write_out(ident, file.path(DIR_TAB, "T7_threshold_identifiability.csv"))

# ---- Cross-check against the old CART estimator -----------------------------
# Only the primary indicator has a legacy CART counterpart.
main <- base[base$indicator == tolower(PRIMARY_INDICATOR) & is.finite(base$d_p), ,
             drop = FALSE]
# The legacy CART outputs live in 02-outputs/reference/ (see README).
old_o <- file.path(DIR_OUT, "reference", "CART", "ORIG", "MAR_DP_DT.csv")
rdata  <- file.path(DIR_OUT, "reference", "Step05_BhvPsets_205.RData")
if (file.exists(old_o) && file.exists(rdata)) {
  e <- new.env(); load(rdata, envir = e)
  old_ids <- dimnames(e$Mapped_class_f)[[3]]
  oo <- read_out(old_o)
  if (nrow(oo) == length(old_ids)) {
    oo$gauge_id <- old_ids
    chk <- merge(oo[, c("gauge_id", "dp")],
                 main[, c("gauge_id", "p_thr_iso_spf")], by = "gauge_id")
    chk <- chk[stats::complete.cases(chk), ]
    write_out(data.frame(
      comparison = c("cor_old_vs_new", "rmse_old_vs_new",
                     "mean_old_minus_new"),
      value = c(round(stats::cor(chk$dp, chk$p_thr_iso_spf), 3),
                round(sqrt(mean((chk$dp - chk$p_thr_iso_spf)^2)), 4),
                round(mean(chk$dp - chk$p_thr_iso_spf, na.rm = TRUE), 4))
    ), file.path(DIR_THR, "cart_crosscheck.csv"))
  }
}
msg("thresholds done")
