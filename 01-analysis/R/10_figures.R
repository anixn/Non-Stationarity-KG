# =============================================================================
# 10_figures.R
# Publication figures for the revision. Every figure has explicit axis labels
# and units (Reviewer #2, minor 6).
#
# Outputs (02-outputs/revision/figures/): PDF + PNG at 300 dpi.
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("ggplot2", "dplyr", "tidyr", "patchwork", "scales", "maps"))

theme_pub <- function(base = 11) {
  ggplot2::theme_classic(base_size = base) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(linewidth = 0.2, colour = "grey90"),
      legend.position = "right",
      plot.title = ggplot2::element_text(face = "bold", hjust = 0),
      strip.background = ggplot2::element_rect(fill = "grey95", colour = NA)
    )
}

save_fig <- function(p, name, w = FIG_WIDTH, h = FIG_HEIGHT) {
  f1 <- file.path(DIR_FIG, paste0(name, ".pdf"))
  f2 <- file.path(DIR_FIG, paste0(name, ".png"))
  ggplot2::ggsave(f1, p, width = w, height = h, device = grDevices::cairo_pdf)
  ggplot2::ggsave(f2, p, width = w, height = h, dpi = FIG_DPI)
  msg("fig ", name)
}

map_base <- function() {
  st <- ggplot2::map_data("state")
  ggplot2::geom_polygon(data = st, ggplot2::aes(long, lat, group = group),
                        fill = "grey97", colour = "grey80", linewidth = 0.2,
                        inherit.aes = FALSE)
}

# ---- Selection maps (manuscript Figs. 1 and 2) -----------------------------
# Candidate catchments come from the 1-degree, 30-year selection list; the
# analysed sample is the subset that passed calibration with >= 50 behavioural
# parameter sets.
sel_f <- CATCHMENT_LIST
sum_f <- file.path(DIR_CAL, "summary.csv")
if (file.exists(sel_f)) {
  sel <- read_out(sel_f)
  analysed <- if (file.exists(sum_f)) read_out(sum_f)$gauge_id else character()
  sel$status <- ifelse(sel$gauge_id %in% analysed, "Analysed", "Candidate only")

  g <- ggplot2::ggplot(sel, ggplot2::aes(gauge_lon, gauge_lat)) +
    map_base() +
    ggplot2::geom_point(ggplot2::aes(size = area, colour = status), alpha = 0.75) +
    ggplot2::scale_size_continuous(range = c(0.4, 4), name = "Area (km2)") +
    ggplot2::scale_colour_manual(values = c("Analysed" = "#1b7837",
                                            "Candidate only" = "grey65"),
                                 name = NULL) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  title = "Analysed catchments",
                  subtitle = sprintf("%d of %d candidate catchments passed calibration",
                                     length(analysed), nrow(sel))) +
    theme_pub()
  save_fig(g, "FA_analysed_catchments", 8, 5)

  g2 <- ggplot2::ggplot(sel, ggplot2::aes(gauge_lon, gauge_lat, colour = status)) +
    map_base() +
    ggplot2::geom_point(ggplot2::aes(shape = status), size = 1.8, alpha = 0.8) +
    ggplot2::scale_shape_manual(values = c("Analysed" = 3, "Candidate only" = 16),
                                name = NULL) +
    ggplot2::scale_colour_manual(values = c("Analysed" = "#b2182b",
                                            "Candidate only" = "#2166ac"),
                                 name = NULL) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  title = "Candidate catchments and the analysed sample",
                  subtitle = sprintf("%d candidates from the 1-degree selection; %d analysed",
                                     nrow(sel), length(analysed))) +
    theme_pub()
  save_fig(g2, "FB_selection_map", 8, 5)
}

# ---- F1 Calibration performance --------------------------------------------
pf <- file.path(DIR_CAL, "performance.csv")
if (file.exists(pf)) {
  p <- read_out(pf)
  d <- tidyr::pivot_longer(p[, c("KGE_med_behav", "NSE_med_behav")],
                           everything(), names_to = "metric", values_to = "value")
  d$metric <- sub("_med_behav", "", d$metric)
  g <- ggplot2::ggplot(d, ggplot2::aes(value, fill = metric)) +
    ggplot2::geom_histogram(bins = 30, position = "identity", alpha = 0.55,
                            colour = "white") +
    ggplot2::geom_vline(xintercept = 0.5, linetype = "dashed", linewidth = 0.4) +
    ggplot2::facet_wrap(~metric, ncol = 2, scales = "free_y") +
    ggplot2::labs(x = "Median value of the retained behavioural sets",
                  y = "Number of catchments", fill = "Metric",
                  title = "HBV calibration performance") +
    theme_pub()
  save_fig(g, "F1_calibration_performance", 7, 3.5)
}

# ---- F2 Split-sample validation --------------------------------------------
sf <- file.path(DIR_VALID, "split_sample.csv")
if (file.exists(sf)) {
  d <- read_out(sf)
  g <- ggplot2::ggplot(d, ggplot2::aes(KGE_cal, KGE_val, colour = direction)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                         linewidth = 0.4, colour = "grey40") +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted", linewidth = 0.3) +
    ggplot2::geom_point(alpha = 0.6, size = 1.6) +
    ggplot2::facet_wrap(~direction) +
    ggplot2::labs(x = "Median KGE in the calibration period",
                  y = "Median KGE in the validation period",
                  colour = "Direction",
                  title = "Differential split-sample test") +
    theme_pub()
  save_fig(g, "F2_split_sample", 8, 3.8)
}

# ---- F3 Moving-window parameter drift --------------------------------------
wf <- file.path(DIR_VALID, "parameter_windows.csv")
kgf <- file.path(DIR_KG, "kg_baseline.csv")
if (file.exists(wf) && file.exists(kgf)) {
  w <- read_out(wf); kg <- read_out(kgf)
  w <- merge(w, kg[, c("gauge_id", "class")], by = "gauge_id")
  pars <- c("FC", "beta", "CFMAX", "SFCF", "k1")
  d <- w |>
    dplyr::select(gauge_id, window_mid, class, dplyr::all_of(pars)) |>
    tidyr::pivot_longer(dplyr::all_of(pars), names_to = "parameter", values_to = "value") |>
    dplyr::group_by(class, parameter, window_mid) |>
    dplyr::summarise(mean = mean(value, na.rm = TRUE),
                     se = sd(value, na.rm = TRUE) / sqrt(dplyr::n()), .groups = "drop")
  g <- ggplot2::ggplot(d, ggplot2::aes(window_mid, mean, colour = class, fill = class)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = mean - se, ymax = mean + se),
                         alpha = 0.15, colour = NA) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::geom_point(size = 1.4) +
    ggplot2::facet_wrap(~parameter, scales = "free_y", ncol = 3) +
    ggplot2::labs(x = "Window midpoint (year)", y = "Parameter value (mean ± SE)",
                  colour = "KG class", fill = "KG class",
                  title = "Parameter drift from 10-year moving-window recalibration") +
    theme_pub()
  save_fig(g, "F3_parameter_drift", 9, 6)
}

# ---- F4 KG baseline map -----------------------------------------------------
# Colours follow the Beck et al. (2023) palette in KG Classes.csv.
if (file.exists(kgf)) {
  kg <- read_out(kgf)
  pal <- kg_palette(unique(kg$class))
  g <- ggplot2::ggplot(kg, ggplot2::aes(lon, lat, colour = class)) +
    map_base() +
    ggplot2::geom_point(size = 2.2, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = pal, name = "KG class") +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  title = "Baseline Köppen–Geiger classes (1981–2010)",
                  subtitle = "Class scheme and colours: Beck et al. (2023)") +
    theme_pub()
  save_fig(g, "F4_kg_baseline_map", 8, 5)
}

# ---- F4b Delta-change KG map (Beck-style) ----------------------------------
# Delta-change grid: precipitation multipliers 0.5/1.0/1.5 (delta P from
# -50% to +50%) crossed with four warming levels, reclassified with the
# Beck et al. (2023) scheme.
mapf <- file.path(DIR_KG, "kg_map_levels.csv")
if (file.exists(mapf)) {
  m <- read_out(mapf)
  m$dp_lab <- factor(m$dp, levels = c(0.5, 1.0, 1.5),
                     labels = c("dP = -50% (drier)", "dP = no change",
                                "dP = +50% (wetter)"))
  m$dt_lab <- factor(m$dt, levels = c(1.5, 2.0, 3.0, 4.0),
                     labels = paste0("dW = +", c(1.5, 2.0, 3.0, 4.0), " \u00b0C"))
  pal <- kg_palette(unique(c(m$class_future, m$class_baseline)))
  g <- ggplot2::ggplot(m, ggplot2::aes(lon, lat, colour = class_future)) +
    map_base() +
    ggplot2::geom_point(size = 1.4, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = pal, name = "KG class") +
    ggplot2::facet_grid(dp_lab ~ dt_lab) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  title = "Delta-change K\u00f6ppen\u2013Geiger classes",
                  subtitle = "Observed 1981\u20132010 climatology perturbed and reclassified with the Beck et al. (2023) scheme") +
    theme_pub()
  save_fig(g, "F4b_kg_delta_change_map", 14, 7)
}

# ---- F5 KG scenario transition map -----------------------------------------
trf <- file.path(DIR_KG, "kg_transition_summary.csv")
if (file.exists(trf) && file.exists(kgf)) {
  tr <- read_out(trf); kg <- read_out(kgf)
  d <- merge(tr, kg[, c("gauge_id", "lat", "lon")], by = "gauge_id")
  g <- ggplot2::ggplot(d, ggplot2::aes(lon, lat, colour = frac_changed)) +
    map_base() +
    ggplot2::geom_point(size = 2.3, alpha = 0.9) +
    ggplot2::scale_colour_viridis_c(labels = scales::percent) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  colour = "Fraction of the\n121 scenarios",
                  title = "Scenarios that leave the baseline KG class") +
    theme_pub()
  save_fig(g, "F5_kg_transition_map", 8, 5)
}

# ---- F14 Prevalence surface for one catchment (manuscript Fig. 9) ----------
# How the 121-cell scenario grid becomes a threshold: p3_mar is the fitted
# probability that MAR sits in the most vulnerable class (C3) in each cell.
scf <- file.path(DIR_SCEN, "cells_all.csv")
if (file.exists(scf)) {
  s <- read_out(scf)
  s <- s[s$gauge_id == "camels_06614800", ]
  if (nrow(s)) {
    s$framework <- factor(s$framework, levels = c("SPF", "CZIPEF"))
    g <- ggplot2::ggplot(s, ggplot2::aes(dp, dt, fill = p3_mar)) +
      ggplot2::geom_tile() +
      ggplot2::geom_contour(ggplot2::aes(z = p3_mar), breaks = 0.5,
                            colour = "white", linewidth = 0.5) +
      ggplot2::facet_wrap(~framework) +
      ggplot2::scale_fill_viridis_c(name = "P(class C3)", limits = c(0, 1)) +
      ggplot2::scale_x_continuous(expand = c(0, 0), breaks = seq(0.5, 1.5, 0.2)) +
      ggplot2::scale_y_continuous(expand = c(0, 0), breaks = seq(-2, 8, 2)) +
      ggplot2::labs(x = "Precipitation multiplier (-)",
                    y = "Temperature change (degrees C)",
                    title = "Probability of the most vulnerable MAR class",
                    subtitle = "White contour: probability = 0.5 (the threshold surface); catchment 06614800") +
      theme_pub()
    save_fig(g, "F14_prevalence_surface", 9, 3.8)
  }
}

# ---- F6 Variance partitioning ----------------------------------------------
vf <- file.path(DIR_ATTR, "varpart.csv")
if (file.exists(vf)) {
  v <- read_out(vf)
  d <- v |>
    dplyr::select(parameter, climate_unique, physio_unique, shared, unexplained) |>
    tidyr::pivot_longer(-parameter, names_to = "fraction", values_to = "value")
  d$fraction <- factor(d$fraction,
    levels = c("climate_unique", "physio_unique", "shared", "unexplained"),
    labels = c("Climate (unique)", "Physiography (unique)", "Shared", "Unexplained"))
  g <- ggplot2::ggplot(d, ggplot2::aes(parameter, value, fill = fraction)) +
    ggplot2::geom_col(width = 0.75) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::labs(x = "HBV parameter", y = "Adjusted R²", fill = NULL,
                  title = "Climate vs physiographic control of model parameters") +
    theme_pub()
  save_fig(g, "F6_variance_partition", 7, 5.5)
}

# ---- F7 RF importance -------------------------------------------------------
rf <- file.path(DIR_ATTR, "rf_importance.csv")
if (file.exists(rf)) {
  d <- read_out(rf)
  d$parameter <- factor(d$parameter, levels = PAR_NAMES)
  g <- ggplot2::ggplot(d, ggplot2::aes(variable, parameter, fill = inc_mse)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::scale_fill_viridis_c(name = "%IncMSE") +
    ggplot2::labs(x = "Predictor", y = "HBV parameter",
                  title = "Random-forest importance of climate and physiography") +
    theme_pub() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  save_fig(g, "F7_rf_importance", 8, 5.5)
}

# ---- F8 Threshold scatter (all three indicators) ---------------------------
ind_panel <- function(x) {
  x <- toupper(x)
  role <- INDICATOR_META$role[match(x, INDICATOR_META$indicator)]
  factor(sprintf("%s (%s)", x, role),
         levels = sprintf("%s (%s)", INDICATORS,
                          INDICATOR_META$role[match(INDICATORS, INDICATOR_META$indicator)]))
}
cf <- file.path(DIR_THR, "comparison.csv")
if (file.exists(cf)) {
  d <- read_out(cf); d <- d[is.finite(d$d_p), ]
  d$panel <- ind_panel(d$indicator)
  g <- ggplot2::ggplot(d, ggplot2::aes(p_thr_iso_spf, p_thr_iso_czip)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                         linewidth = 0.4, colour = "red") +
    ggplot2::geom_point(size = 1.6, alpha = 0.6, colour = "grey25") +
    ggplot2::geom_smooth(method = "lm", se = FALSE, linewidth = 0.7, colour = "#2166AC") +
    ggplot2::facet_wrap(~panel, ncol = 3, scales = "free", drop = FALSE) +
    ggplot2::labs(x = "SPF ΔP threshold (fraction of historical P)",
                  y = "CZIPEF ΔP threshold (fraction of historical P)",
                  title = "Precipitation vulnerability thresholds by indicator") +
    theme_pub()
  save_fig(g, "F8_threshold_scatter", 11, 4.2)
}

# ---- F9 Threshold difference map (all three indicators) --------------------
if (file.exists(cf) && file.exists(kgf)) {
  d <- read_out(cf); d <- d[is.finite(d$d_p), ]
  d <- merge(d, read_out(kgf)[, c("gauge_id", "lat", "lon")], by = "gauge_id")
  d$panel <- ind_panel(d$indicator)
  d$direction <- ifelse(d$d_p > 0.005, "CZIPEF higher",
                        ifelse(d$d_p < -0.005, "CZIPEF lower", "No change"))
  g <- ggplot2::ggplot(d, ggplot2::aes(lon, lat, colour = direction)) +
    map_base() +
    ggplot2::geom_point(size = 1.7, alpha = 0.9) +
    ggplot2::facet_wrap(~panel, ncol = 3, drop = FALSE) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                  colour = NULL,
                  title = "Direction of the SPF–CZIPEF threshold difference") +
    theme_pub()
  save_fig(g, "F9_threshold_difference_map", 11, 4.2)
}

# ---- F8b Threshold map, SPF vs CZIPEF (manuscript Fig. 10) ------------------
if (file.exists(cf) && file.exists(kgf)) {
  d <- read_out(cf)
  d <- d[tolower(d$indicator) == tolower(PRIMARY_INDICATOR), ]
  d <- merge(d, read_out(kgf)[, c("gauge_id", "lat", "lon")], by = "gauge_id")
  long <- rbind(
    data.frame(d[, c("gauge_id", "lat", "lon")], framework = "SPF",
               p_threshold = d$p_thr_iso_spf),
    data.frame(d[, c("gauge_id", "lat", "lon")], framework = "CZIPEF",
               p_threshold = d$p_thr_iso_czip)
  )
  long <- long[is.finite(long$p_threshold), ]
  long$framework <- factor(long$framework, levels = c("SPF", "CZIPEF"))
  if (nrow(long)) {
    g <- ggplot2::ggplot(long, ggplot2::aes(lon, lat, colour = p_threshold)) +
      map_base() +
      ggplot2::geom_point(size = 1.8, alpha = 0.9) +
      ggplot2::scale_colour_viridis_c(
        name = "Precipitation\nthreshold (-)", limits = c(0.4, 1)) +
      ggplot2::facet_wrap(~framework, ncol = 2) +
      ggplot2::coord_quickmap() +
      ggplot2::labs(x = "Longitude (degrees)", y = "Latitude (degrees)",
                    title = "Precipitation vulnerability thresholds for MAR",
                    subtitle = "Fraction of historical precipitation at which the catchment enters the most vulnerable class") +
      theme_pub()
    save_fig(g, "F8b_threshold_map", 10, 4.2)
  }
}

# ---- F10 Sensitivity --------------------------------------------------------
prcc_files <- list.files(DIR_SENS, pattern = "^prcc_.*csv$", full.names = TRUE)
sob_files  <- list.files(DIR_SENS, pattern = "^sobol_.*csv$", full.names = TRUE)
if (length(prcc_files)) {
  pr <- do.call(rbind, lapply(prcc_files, read_out))
  pr$method <- "PRCC"; names(pr)[names(pr) == "estimate"] <- "value"
  pr <- pr[, c("gauge_id", "kg_class", "metric", "parameter", "method", "value")]
  sb <- if (length(sob_files)) do.call(rbind, lapply(sob_files, read_out)) else NULL
  if (!is.null(sb)) {
    s1 <- sb[, c("gauge_id", "kg_class", "metric", "parameter")]
    s1$method <- "Sobol (first)"; s1$value <- sb$S_first
    s2 <- s1; s2$method <- "Sobol (total)"; s2$value <- sb$S_total
    d <- rbind(pr, s1, s2)
  } else d <- pr
  d$metric <- toupper(d$metric)

  # Main figure: MAR, the primary indicator.
  dm <- d[d$metric == PRIMARY_INDICATOR, , drop = FALSE]
  if (nrow(dm)) {
    g <- ggplot2::ggplot(dm, ggplot2::aes(value, parameter, colour = method)) +
      ggplot2::geom_vline(xintercept = 0, linewidth = 0.3, colour = "grey60") +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5), size = 2) +
      ggplot2::facet_wrap(~kg_class, ncol = 3) +
      ggplot2::labs(x = "Sensitivity index", y = "Parameter", colour = "Method",
                    title = "Parameter sensitivity of MAR by climate zone") +
      theme_pub()
    save_fig(g, "F10_sensitivity", 9, 6)
  }

  # Supplementary figure: LFI and MAMF.
  ds <- d[d$metric != PRIMARY_INDICATOR, , drop = FALSE]
  if (nrow(ds)) {
    ds$metric <- factor(ds$metric, levels = setdiff(INDICATORS, PRIMARY_INDICATOR))
    g <- ggplot2::ggplot(ds, ggplot2::aes(value, parameter, colour = method)) +
      ggplot2::geom_vline(xintercept = 0, linewidth = 0.3, colour = "grey60") +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5), size = 1.8) +
      ggplot2::facet_grid(metric ~ kg_class) +
      ggplot2::labs(x = "Sensitivity index", y = "Parameter", colour = "Method",
                    title = "Parameter sensitivity of LFI and MAMF by climate zone") +
      theme_pub()
    save_fig(g, "F10b_sensitivity_LFI_MAMF", 12, 7)
  }
}

# ---- F11 Parametric uncertainty --------------------------------------------
uf <- file.path(DIR_SENS, "uncertainty.csv")
if (file.exists(uf)) {
  d <- read_out(uf)
  d <- d[d$metric %in% c("MAR", "LFI", "MAMF"), ]
  d$cv <- pmin(d$cv, 2)
  g <- ggplot2::ggplot(d, ggplot2::aes(kg_class, cv, fill = metric)) +
    ggplot2::geom_boxplot(outlier.size = 0.5, linewidth = 0.3) +
    ggplot2::labs(x = "KG class", y = "Coefficient of variation (ensemble)",
                  fill = "Indicator",
                  title = "Parametric uncertainty of the flow indicators") +
    theme_pub()
  save_fig(g, "F11_uncertainty", 7, 4)
}

# ---- F13 Behavioural parameter CDFs by climate zone ------------------------
# Replaces the old Fig. 13 (reviewer minor 6): explicit axes, units and legend.
poolf <- file.path(DIR_POOL, "pools.rds")
if (file.exists(poolf)) {
  pools <- readRDS(poolf)
  d <- do.call(rbind, lapply(names(pools), function(cl) {
    x <- as.data.frame(pools[[cl]])
    x$kg_class <- cl
    x
  }))
  dl <- tidyr::pivot_longer(d, dplyr::all_of(PAR_NAMES),
                            names_to = "parameter", values_to = "value")
  dl$parameter <- factor(dl$parameter, levels = PAR_NAMES)
  g <- ggplot2::ggplot(dl, ggplot2::aes(value, colour = kg_class)) +
    ggplot2::stat_ecdf(linewidth = 0.5) +
    ggplot2::facet_wrap(~parameter, scales = "free_x", ncol = 4) +
    ggplot2::labs(x = "Parameter value (model units)",
                  y = "Cumulative probability",
                  colour = "KG class",
                  title = "Behavioural parameter sets pooled by climate zone") +
    theme_pub()
  save_fig(g, "F13_parameter_cdf", 10, 7)
}

# ---- F12 Threshold identifiability -----------------------------------------
# Supports the decision to report LFI and MAMF alongside MAR: it shows where a
# threshold exists at all, instead of hiding non-identifiable cases.
idf <- file.path(DIR_TAB, "T7_threshold_identifiability.csv")
if (file.exists(idf)) {
  d <- read_out(idf)
  d$indicator <- factor(toupper(d$indicator), levels = INDICATORS)
  dl <- tidyr::pivot_longer(d, c("p_thr_pct", "dt_thr_pct"),
                            names_to = "threshold", values_to = "pct")
  dl$threshold <- ifelse(dl$threshold == "p_thr_pct", "ΔP threshold", "ΔT threshold")
  g <- ggplot2::ggplot(dl, ggplot2::aes(indicator, pct, fill = framework)) +
    ggplot2::geom_col(position = "dodge", width = 0.7) +
    ggplot2::facet_wrap(~threshold) +
    ggplot2::scale_y_continuous(limits = c(0, 100)) +
    ggplot2::labs(x = "Indicator", y = "% of catchments with an identifiable threshold",
                  fill = "Framework",
                  title = "Threshold identifiability by indicator") +
    theme_pub()
  save_fig(g, "F12_threshold_identifiability", 7, 4)
}

msg("all figures done")
