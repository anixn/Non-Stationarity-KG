# =============================================================================
# 10_figures.R
# Publication figures for the revision.
#
# Style follows the project figure standard v2 (scientific_figure_standard.md,
# 2026-11-28): the element size table, not "10 pt everywhere".
#   - Roboto throughout (Arial fallback if Roboto is absent).
#   - Axis titles 10 pt; tick labels, legends, strip labels and colorbar
#     9 pt; panel labels "a.)", "b.)" 11 pt bold; in-plot annotations 9 pt;
#     inset text 8 pt. Three main sizes only (11 / 10 / 9), never below 7 pt.
#   - Panel labels are drawn for figures whose panels carry distinct content.
#     Homogeneous facet grids (all panels are the same plot type identified by
#     the strip text) keep strip labels only, so labels do not duplicate.
#   - Colourblind-safe palettes with fixed variable-to-colour mappings:
#     Okabe-Ito/Tol for categories, viridis for continuous variables, the
#     official Beck et al. (2023) palette for the KG maps, and a colourblind-
#     safe red-blue diverging pair for signed differences.
#   - Units in parentheses on every axis; "-" marks dimensionless quantities.
#   - Designed at final printed size: the manuscript is A4 with 2.5 cm
#     margins, so the text width is 160 mm and every figure is designed at
#     exactly 160 mm wide (heights vary with content). The LaTeX build scales
#     to \linewidth without shrinking, so the sizes above are the printed sizes.
#   - Export: vector PDF (cairo_pdf) + 300 dpi PNG, white background.
#
# Outputs (02-outputs/revision/figures/): PDF + PNG per figure.
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("ggplot2", "dplyr", "tidyr", "patchwork", "scales", "maps",
               "showtext", "sysfonts"))

# ---- Figure standard: font ---------------------------------------------------
# Register Roboto through sysfonts/showtext so every device (PNG and PDF)
# renders the same font; fall back to Arial if Roboto is not installed.
FIG_FONT <- "Roboto"
ensure_fig_font <- function() {
  find_font <- function(family, weight) {
    p <- tryCatch(
      systemfonts::match_fonts(family, weight = weight)$path[1],
      error = function(e) NA_character_)
    if (is.na(p) || !nzchar(p)) {
      p <- tryCatch(
        systemfonts::match_fonts(family, weight = "normal")$path[1],
        error = function(e) NA_character_)
    }
    if (!is.na(p) && file.exists(p)) p else NA_character_
  }
  reg <- find_font(FIG_FONT, "regular")
  if (is.na(reg)) {                       # Roboto absent: Arial fallback
    FIG_FONT <<- "Arial"
    reg  <- find_font(FIG_FONT, "regular")
    bold <- find_font(FIG_FONT, "bold")
  } else {
    bold <- find_font(FIG_FONT, "bold")
  }
  if (is.na(bold)) bold <- reg            # degrades gracefully, never fails
  if (!is.na(reg)) {
    sysfonts::font_add(FIG_FONT, regular = reg, bold = bold)
    showtext::showtext_opts(dpi = FIG_DPI)
    showtext::showtext_auto()
  }
}
ensure_fig_font()

# ---- Figure standard: theme --------------------------------------------------
# Centralised publication theme implementing the v2 element size table:
# axis titles 10 pt, ticks/legends/strips/colorbar 9 pt, panel tags 11 pt bold,
# in-plot annotations 9 pt. White background, subtle horizontal major gridlines
# only, classic axis line.
theme_publication <- function(base_size = 10) {
  ggplot2::theme_classic(base_size = base_size, base_family = FIG_FONT) +
    ggplot2::theme(
      text              = ggplot2::element_text(family = FIG_FONT,
                                                size = 9, colour = "black"),
      plot.title        = ggplot2::element_text(size = 10, hjust = 0,
                                                margin = ggplot2::margin(b = 3)),
      plot.subtitle     = ggplot2::element_text(size = 9, hjust = 0,
                                                colour = "grey30",
                                                margin = ggplot2::margin(b = 2)),
      axis.title        = ggplot2::element_text(size = 10, colour = "black"),
      axis.text         = ggplot2::element_text(size = 9, colour = "black"),
      axis.ticks        = ggplot2::element_line(linewidth = 0.45,
                                                colour = "black"),
      axis.ticks.length = ggplot2::unit(1.6, "mm"),
      panel.grid.major.y = ggplot2::element_line(linewidth = 0.3,
                                                 colour = "grey88"),
      panel.grid.major.x = ggplot2::element_blank(),
      legend.title      = ggplot2::element_text(size = 9),
      legend.text       = ggplot2::element_text(size = 9),
      legend.key.size   = ggplot2::unit(3.5, "mm"),
      legend.background = ggplot2::element_blank(),
      strip.background  = ggplot2::element_blank(),
      strip.text        = ggplot2::element_text(size = 9),
      plot.tag          = ggplot2::element_text(size = 11, face = "bold"),
      plot.margin       = ggplot2::margin(4, 6, 4, 4)
    )
}

# ---- Figure standard: export -------------------------------------------------
# Design width = 160 mm = the manuscript text width (A4, 2.5 cm margins), so
# the LaTeX \linewidth include renders text at exactly 10 pt.
FIG_W_MM <- 160
save_fig <- function(p, name, h_mm = 100) {
  w <- FIG_W_MM / 25.4
  h <- h_mm / 25.4
  ggplot2::ggsave(file.path(DIR_FIG, paste0(name, ".pdf")), p,
                  width = w, height = h, device = grDevices::cairo_pdf,
                  bg = "white")
  ggplot2::ggsave(file.path(DIR_FIG, paste0(name, ".png")), p,
                  width = w, height = h, dpi = FIG_DPI, bg = "white")
  msg("fig ", name)
}

# ---- Figure standard: panel labels ------------------------------------------
# Bold "a.)", "b.)", ... at the upper-left corner of each panel. `facet` must
# be the single faceting variable; labels follow the factor level order (or
# first-appearance order) used by facet_wrap.
panel_labels <- function(p, data, facet, labels = NULL) {
  f <- data[[facet]]
  if (is.factor(f)) f <- droplevels(f)
  lv <- if (is.factor(f)) levels(f) else unique(f)
  n <- length(lv)
  if (is.null(labels)) labels <- sprintf("%s.)", letters[seq_len(n)])
  lab <- stats::setNames(data.frame(lv, labels, stringsAsFactors = FALSE),
                         c(facet, "label"))
  # Keep the facet column as a factor with the plot's own level order; a
  # character column here would silently re-sort the facet layout.
  if (is.factor(data[[facet]])) {
    lab[[facet]] <- factor(lab[[facet]], levels = levels(data[[facet]]))
  }
  lab$.x <- -Inf; lab$.y <- Inf
  p + ggplot2::geom_text(data = lab,
                         ggplot2::aes(x = .x, y = .y, label = label),
                         inherit.aes = FALSE, hjust = 0.05, vjust = 1.4,
                         size = 11 / ggplot2::.pt, fontface = "bold",
                         family = FIG_FONT)
}

# ---- Figure standard: fixed palettes ----------------------------------------
# One variable keeps one colour in every figure of the project.
PAL_METRIC    <- c(KGE = "#0072B2", NSE = "#E69F00")                 # Okabe-Ito
PAL_DIRECTION <- c(forward = "#0072B2", reverse = "#D55E00")         # Okabe-Ito
PAL_FRAMEWORK <- c(SPF = "#0072B2", CZIPEF = "#D55E00")             # Okabe-Ito
PAL_INDICATOR <- c(MAR = "#0072B2", LFI = "#E69F00", MAMF = "#009E73")
PAL_METHOD    <- c(PRCC = "#0072B2", "Sobol (first)" = "#E69F00",
                   "Sobol (total)" = "#009E73")
PAL_PART      <- c("Climate (unique)" = "#0072B2",
                   "Physiography (unique)" = "#E69F00",
                   "Shared" = "#009E73", "Unexplained" = "grey70")
# Signed threshold differences: colourblind-safe diverging red-blue.
PAL_DIFF      <- c("CZIPEF higher" = "#D7191C", "CZIPEF lower" = "#2C7BB6",
                   "No change" = "grey65")
# Selection maps (manuscript Figs. 1-2; colours are named in the captions).
PAL_STATUS    <- c("Analysed" = "#009E73", "Candidate only" = "grey65")
PAL_SELECT    <- c("Analysed" = "#b2182b", "Candidate only" = "#2166ac")
# Categorical palette for KG classes outside the maps (Figs. S3/S10/S11/S13):
# Okabe-Ito + Tol bright, assigned deterministically in sorted class order.
KG_CLASS_COLOURS <- c("#0072B2", "#E69F00", "#009E73", "#D55E00", "#56B4E9",
                      "#CC79A7", "#66C2A5", "#FC8D62", "#8DA0CB", "#A6D854",
                      "#FFD92F", "#B3B3B3")
kg_class_pal <- function(classes) {
  classes <- sort(unique(classes))
  stats::setNames(rep_len(KG_CLASS_COLOURS, length(classes)), classes)
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

  # Fig. 1: analysed catchments (green) with candidate-only catchments grey.
  g <- ggplot2::ggplot(sel, ggplot2::aes(gauge_lon, gauge_lat)) +
    map_base() +
    ggplot2::geom_point(ggplot2::aes(size = area, colour = status), alpha = 0.75) +
    ggplot2::scale_size_continuous(range = c(0.4, 3), name = "Area (km\u00b2)") +
    ggplot2::scale_colour_manual(values = PAL_STATUS, name = NULL) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = sprintf("Analysed catchments: %d of %d candidates passed calibration",
                                  length(analysed), nrow(sel))) +
    theme_publication()
  save_fig(g, "FA_analysed_catchments", 100)

  # Fig. 2: all candidates (blue circles) with the analysed sample (red crosses);
  # shape and colour carry the same information so the map is readable without
  # colour alone.
  g2 <- ggplot2::ggplot(sel, ggplot2::aes(gauge_lon, gauge_lat, colour = status)) +
    map_base() +
    ggplot2::geom_point(ggplot2::aes(shape = status), size = 1.6, alpha = 0.85) +
    ggplot2::scale_shape_manual(values = c("Analysed" = 4, "Candidate only" = 16),
                                name = NULL) +
    ggplot2::scale_colour_manual(values = PAL_SELECT, name = NULL) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = sprintf("Candidate catchments: %d selected, %d analysed",
                                  nrow(sel), length(analysed))) +
    theme_publication()
  save_fig(g2, "FB_selection_map", 100)
}

# ---- F1 Calibration performance (supplementary, two panels) ------------------
pf <- file.path(DIR_CAL, "performance.csv")
if (file.exists(pf)) {
  p <- read_out(pf)
  d <- tidyr::pivot_longer(p[, c("KGE_med_behav", "NSE_med_behav")],
                           everything(), names_to = "metric", values_to = "value")
  d$metric <- sub("_med_behav", "", d$metric)
  d$metric <- factor(d$metric, levels = c("KGE", "NSE"))
  g <- ggplot2::ggplot(d, ggplot2::aes(value, fill = metric)) +
    ggplot2::geom_histogram(bins = 30, position = "identity", alpha = 1,
                            colour = "white", linewidth = 0.2) +
    ggplot2::geom_vline(xintercept = 0.5, linetype = "dashed",
                        linewidth = 0.5, colour = "grey30") +
    ggplot2::facet_wrap(~metric, ncol = 2, scales = "free_y") +
    ggplot2::scale_fill_manual(values = PAL_METRIC) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::labs(x = "Median of the retained behavioural sets (dimensionless)",
                  y = "Number of catchments") +
    theme_publication() +
    ggplot2::theme(legend.position = "none")
  g <- panel_labels(g, d, "metric")
  save_fig(g, "F1_calibration_performance", 70)
}

# ---- F2 Split-sample validation (supplementary, two panels) ------------------
sf <- file.path(DIR_VALID, "split_sample.csv")
if (file.exists(sf)) {
  d <- read_out(sf)
  d$direction <- factor(d$direction, levels = c("forward", "reverse"))
  g <- ggplot2::ggplot(d, ggplot2::aes(KGE_cal, KGE_val, colour = direction)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                         linewidth = 0.5, colour = "grey40") +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted",
                        linewidth = 0.4, colour = "grey60") +
    ggplot2::geom_point(alpha = 0.6, size = 1.4) +
    ggplot2::facet_wrap(~direction) +
    ggplot2::scale_colour_manual(values = PAL_DIRECTION, name = "Direction") +
    ggplot2::labs(x = "Median KGE in the calibration period (dimensionless)",
                  y = "Median KGE in the\nvalidation period (dimensionless)") +
    theme_publication() +
    ggplot2::theme(legend.position = "bottom")
  g <- panel_labels(g, d, "direction")
  save_fig(g, "F2_split_sample", 70)
}

# ---- F3 Moving-window parameter drift (supplementary, five panels) -----------
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
  d$class <- factor(d$class, levels = sort(unique(d$class)))
  g <- ggplot2::ggplot(d, ggplot2::aes(window_mid, mean, colour = class, fill = class)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = mean - se, ymax = mean + se),
                         alpha = 0.15, colour = NA) +
    ggplot2::geom_line(linewidth = 0.6) +
    ggplot2::geom_point(size = 1.2) +
    ggplot2::facet_wrap(~parameter, scales = "free_y", ncol = 3) +
    ggplot2::scale_colour_manual(values = kg_class_pal(d$class), name = "KG class",
                                 drop = FALSE) +
    ggplot2::scale_fill_manual(values = kg_class_pal(d$class), name = "KG class",
                               drop = FALSE, guide = "none") +
    ggplot2::scale_x_continuous(breaks = c(1985, 1995, 2005)) +
    ggplot2::labs(x = "Window midpoint (year)",
                  y = "Parameter value (mean \u00b1 SE, model units)") +
    theme_publication() +
    ggplot2::theme(legend.position = "right")
  save_fig(g, "F3_parameter_drift", 120)
}

# ---- F4 KG baseline map (supplementary) --------------------------------------
# Colours follow the Beck et al. (2023) palette in KG Classes.csv.
if (file.exists(kgf)) {
  kg <- read_out(kgf)
  pal <- kg_palette(unique(kg$class))
  g <- ggplot2::ggplot(kg, ggplot2::aes(lon, lat, colour = class)) +
    map_base() +
    ggplot2::geom_point(size = 1.8, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = pal, name = "KG class") +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = "Baseline K\u00f6ppen\u2013Geiger classes (1981\u20132010)") +
    theme_publication()
  save_fig(g, "F4_kg_baseline_map", 100)
}

# ---- F4b Delta-change KG map (manuscript Fig. 8, 12 panels) ------------------
# Delta-change grid: precipitation multipliers 0.5/1.0/1.5 (delta P from
# -50% to +50%) crossed with four warming levels, reclassified with the
# Beck et al. (2023) scheme.
mapf <- file.path(DIR_KG, "kg_map_levels.csv")
if (file.exists(mapf)) {
  m <- read_out(mapf)
  m$dp_lab <- factor(m$dp, levels = c(0.5, 1.0, 1.5),
                     labels = c("\u0394P = \u221250%", "\u0394P = 0",
                                "\u0394P = +50%"))
  m$dt_lab <- factor(m$dt, levels = c(1.5, 2.0, 3.0, 4.0),
                     labels = paste0("\u0394W = +", c(1.5, 2.0, 3.0, 4.0), " \u00b0C"))
  pal <- kg_palette(unique(c(m$class_future, m$class_baseline)))
  g <- ggplot2::ggplot(m, ggplot2::aes(lon, lat, colour = class_future)) +
    map_base() +
    ggplot2::geom_point(size = 1.1, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = pal, name = "KG class") +
    ggplot2::facet_grid(dp_lab ~ dt_lab) +
    ggplot2::scale_x_continuous(breaks = c(-120, -100, -80)) +
    ggplot2::scale_y_continuous(breaks = c(30, 40, 50)) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = "Delta-change K\u00f6ppen\u2013Geiger classes (baseline 1981\u20132010)") +
    theme_publication() +
    ggplot2::theme(legend.position = "right",
                   strip.text.y = ggplot2::element_text(angle = 0))
  save_fig(g, "F4b_kg_delta_change_map", 95)
}

# ---- F5 KG scenario transition map (supplementary) ---------------------------
trf <- file.path(DIR_KG, "kg_transition_summary.csv")
if (file.exists(trf) && file.exists(kgf)) {
  tr <- read_out(trf); kg <- read_out(kgf)
  d <- merge(tr, kg[, c("gauge_id", "lat", "lon")], by = "gauge_id")
  g <- ggplot2::ggplot(d, ggplot2::aes(lon, lat, colour = frac_changed)) +
    map_base() +
    ggplot2::geom_point(size = 1.8, alpha = 0.9) +
    ggplot2::scale_colour_viridis_c(labels = scales::percent,
                                    name = "Fraction of\n121 scenarios",
                                    option = "viridis") +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = "Scenarios that leave the baseline KG class") +
    theme_publication()
  save_fig(g, "F5_kg_transition_map", 100)
}

# ---- F14 Prevalence surface (manuscript Fig. 9, two panels) ------------------
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
      ggplot2::scale_fill_viridis_c(name = "P(class C3)", limits = c(0, 1),
                                    option = "viridis") +
      ggplot2::scale_x_continuous(expand = c(0, 0), breaks = seq(0.5, 1.5, 0.2)) +
      ggplot2::scale_y_continuous(expand = c(0, 0), breaks = seq(-2, 8, 2)) +
      ggplot2::labs(x = "Precipitation multiplier (\u2212)",
                    y = "Temperature change (\u00b0C)",
                    title = "Probability of the most vulnerable MAR class (catchment 06614800)") +
      theme_publication() +
      ggplot2::theme(legend.position = "right")
    g <- panel_labels(g, s, "framework")
    save_fig(g, "F14_prevalence_surface", 80)
  }
}

# ---- F6 Variance partitioning (supplementary) ---------------------------------
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
    ggplot2::geom_col(width = 0.75, colour = "white", linewidth = 0.2) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::percent,
                                expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::scale_fill_manual(values = PAL_PART, name = "Fraction of variance") +
    ggplot2::labs(x = "HBV parameter", y = "Adjusted R\u00b2 (fraction)") +
    theme_publication()
  save_fig(g, "F6_variance_partition", 90)
}

# ---- F7 RF importance (supplementary) -----------------------------------------
rf <- file.path(DIR_ATTR, "rf_importance.csv")
if (file.exists(rf)) {
  d <- read_out(rf)
  d$parameter <- factor(d$parameter, levels = PAR_NAMES)
  g <- ggplot2::ggplot(d, ggplot2::aes(variable, parameter, fill = inc_mse)) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.3) +
    ggplot2::scale_fill_viridis_c(name = "%IncMSE", option = "viridis") +
    ggplot2::labs(x = "Predictor", y = "HBV parameter",
                  title = "Random-forest importance of climate and physiography") +
    theme_publication() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  save_fig(g, "F7_rf_importance", 100)
}

# ---- F8 Threshold scatter (manuscript Fig. 11, three panels) -------------------
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
                         linewidth = 0.5, colour = "#D7191C") +
    ggplot2::geom_point(size = 1.2, alpha = 0.6, colour = "grey25") +
    ggplot2::geom_smooth(method = "lm", se = FALSE, linewidth = 0.7,
                         colour = "#2C7BB6") +
    ggplot2::facet_wrap(~panel, ncol = 3, scales = "free", drop = FALSE) +
    ggplot2::labs(x = "SPF \u0394P threshold (fraction of historical P)",
                  y = "CZIPEF \u0394P threshold\n(fraction of historical P)",
                  title = "Precipitation vulnerability thresholds by indicator") +
    theme_publication()
  g <- panel_labels(g, d, "panel")
  save_fig(g, "F8_threshold_scatter", 65)
}

# ---- F9 Threshold difference map (manuscript Fig. 12, three panels) ------------
if (file.exists(cf) && file.exists(kgf)) {
  d <- read_out(cf); d <- d[is.finite(d$d_p), ]
  d <- merge(d, read_out(kgf)[, c("gauge_id", "lat", "lon")], by = "gauge_id")
  d$panel <- ind_panel(d$indicator)
  d$direction <- ifelse(d$d_p > 0.005, "CZIPEF higher",
                        ifelse(d$d_p < -0.005, "CZIPEF lower", "No change"))
  d$direction <- factor(d$direction,
                        levels = c("CZIPEF higher", "CZIPEF lower", "No change"))
  g <- ggplot2::ggplot(d, ggplot2::aes(lon, lat, colour = direction)) +
    map_base() +
    ggplot2::geom_point(size = 1.3, alpha = 0.9) +
    ggplot2::facet_wrap(~panel, ncol = 3, drop = FALSE) +
    ggplot2::scale_colour_manual(values = PAL_DIFF, name = NULL) +
    ggplot2::coord_quickmap() +
    ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                  title = "Direction of the SPF\u2013CZIPEF threshold difference") +
    theme_publication() +
    ggplot2::theme(legend.position = "bottom")
  g <- panel_labels(g, d, "panel")
  save_fig(g, "F9_threshold_difference_map", 65)
}

# ---- F8b Threshold map, SPF vs CZIPEF (manuscript Fig. 10, two panels) ---------
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
      ggplot2::geom_point(size = 1.4, alpha = 0.9) +
      ggplot2::scale_colour_viridis_c(
        name = "Precipitation\nthreshold (\u2212)", limits = c(0.4, 1),
        option = "viridis") +
      ggplot2::facet_wrap(~framework, ncol = 2) +
      ggplot2::coord_quickmap() +
      ggplot2::labs(x = "Longitude (\u00b0)", y = "Latitude (\u00b0)",
                    title = "Precipitation vulnerability thresholds for MAR") +
      theme_publication()
    g <- panel_labels(g, long, "framework")
    save_fig(g, "F8b_threshold_map", 70)
  }
}

# ---- F10 Sensitivity (manuscript Fig. 14, six panels) ---------------------------
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
    dm$kg_class <- factor(dm$kg_class, levels = sort(unique(dm$kg_class)))
    g <- ggplot2::ggplot(dm, ggplot2::aes(value, parameter, colour = method)) +
      ggplot2::geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey60") +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5),
                          size = 1.6) +
      ggplot2::facet_wrap(~kg_class, ncol = 3) +
      ggplot2::scale_colour_manual(values = PAL_METHOD, name = "Method") +
      ggplot2::scale_x_continuous(breaks = c(-0.5, 0, 0.5)) +
      ggplot2::labs(x = "Sensitivity index (dimensionless)", y = "HBV parameter",
                    title = "Parameter sensitivity of MAR by climate zone") +
      theme_publication() +
      ggplot2::theme(legend.position = "bottom")
    save_fig(g, "F10_sensitivity", 110)
  }

  # Supplementary figure: LFI and MAMF.
  ds <- d[d$metric != PRIMARY_INDICATOR, , drop = FALSE]
  if (nrow(ds)) {
    ds$metric <- factor(ds$metric, levels = setdiff(INDICATORS, PRIMARY_INDICATOR))
    ds$kg_class <- factor(ds$kg_class, levels = sort(unique(ds$kg_class)))
    g <- ggplot2::ggplot(ds, ggplot2::aes(value, parameter, colour = method)) +
      ggplot2::geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey60") +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5),
                          size = 1.4) +
      ggplot2::facet_grid(metric ~ kg_class) +
      ggplot2::scale_colour_manual(values = PAL_METHOD, name = "Method") +
      ggplot2::scale_x_continuous(breaks = c(-0.5, 0, 0.5)) +
      ggplot2::labs(x = "Sensitivity index (dimensionless)", y = "HBV parameter",
                    title = "Parameter sensitivity of LFI and MAMF by climate zone") +
      theme_publication() +
      ggplot2::theme(legend.position = "bottom")
    save_fig(g, "F10b_sensitivity_LFI_MAMF", 130)
  }
}

# ---- F11 Parametric uncertainty (supplementary) --------------------------------
# Stage 09 uses one representative catchment per KG class, so each class x
# indicator cell holds a single ensemble CV; the plot therefore shows the
# values as points (a boxplot of one observation is meaningless).
uf <- file.path(DIR_SENS, "uncertainty.csv")
if (file.exists(uf)) {
  d <- read_out(uf)
  d <- d[d$metric %in% c("MAR", "LFI", "MAMF"), ]
  d$metric <- factor(d$metric, levels = c("MAR", "LFI", "MAMF"))
  d$cv <- pmin(d$cv, 2)
  g <- ggplot2::ggplot(d, ggplot2::aes(kg_class, cv, colour = metric)) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey70") +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.4),
                        size = 2.2, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = PAL_INDICATOR, name = "Indicator") +
    ggplot2::labs(x = "KG class",
                  y = "Ensemble coefficient of variation (\u2212)",
                  title = "Parametric uncertainty of the flow indicators") +
    theme_publication()
  save_fig(g, "F11_uncertainty", 75)
}

# ---- F13 Behavioural parameter CDFs by climate zone (manuscript Fig. 13) -------
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
  dl$kg_class <- factor(dl$kg_class, levels = sort(unique(dl$kg_class)))
  g <- ggplot2::ggplot(dl, ggplot2::aes(value, colour = kg_class)) +
    ggplot2::stat_ecdf(linewidth = 0.45) +
    ggplot2::facet_wrap(~parameter, scales = "free_x", ncol = 4) +
    ggplot2::scale_colour_manual(values = kg_class_pal(dl$kg_class),
                                 name = "KG class", drop = FALSE) +
    ggplot2::labs(x = "Parameter value (model units)",
                  y = "Cumulative probability (dimensionless)",
                  title = "Behavioural parameter sets pooled by climate zone") +
    theme_publication()
  save_fig(g, "F13_parameter_cdf", 150)
}

# ---- F12 Threshold identifiability (supplementary, two panels) ------------------
# Supports the decision to report LFI and MAMF alongside MAR: it shows where a
# threshold exists at all, instead of hiding non-identifiable cases.
idf <- file.path(DIR_TAB, "T7_threshold_identifiability.csv")
if (file.exists(idf)) {
  d <- read_out(idf)
  d$indicator <- factor(toupper(d$indicator), levels = INDICATORS)
  dl <- tidyr::pivot_longer(d, c("p_thr_pct", "dt_thr_pct"),
                            names_to = "threshold", values_to = "pct")
  dl$threshold <- ifelse(dl$threshold == "p_thr_pct",
                         "\u0394P threshold", "\u0394T threshold")
  g <- ggplot2::ggplot(dl, ggplot2::aes(indicator, pct, fill = framework)) +
    ggplot2::geom_col(position = "dodge", width = 0.7,
                      colour = "white", linewidth = 0.2) +
    ggplot2::facet_wrap(~threshold) +
    ggplot2::scale_y_continuous(limits = c(0, 100),
                                expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::scale_fill_manual(values = PAL_FRAMEWORK, name = "Framework") +
    ggplot2::labs(x = "Indicator",
                  y = "Catchments with an\nidentifiable threshold (%)",
                  title = "Threshold identifiability by indicator") +
    theme_publication() +
    ggplot2::theme(legend.position = "right")
  g <- panel_labels(g, dl, "threshold")
  save_fig(g, "F12_threshold_identifiability", 70)
}

msg("all figures done")
