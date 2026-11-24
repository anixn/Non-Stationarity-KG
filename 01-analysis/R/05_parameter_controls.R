# =============================================================================
# 05_parameter_controls.R
# Is the parameter signal climatic or physiographic?
#
# Reviewer #2 (major 1): model parameters also depend on watershed geophysical
# characteristics. This script quantifies the relative role of climate and
# physiography for each HBV parameter.
#
# Methods:
#   * variance partitioning (vegan::varpart) between a climate table and a
#     physiographic table, adjusted R2;
#   * nested linear models testing whether KG zone adds explanatory power after
#     climate + physiography;
#   * random-forest permutation importance.
#
# Outputs (02-outputs/revision/attribution/):
#   varpart.csv, rf_importance.csv, nested_models.csv
# Table:
#   T6_climate_vs_physiography.csv
# =============================================================================

if (!exists("PROJ") || !exists("require_pkgs", mode = "function")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .d <- if (length(.f)) dirname(normalizePath(.f)) else file.path(getwd(), "01-analysis/R")
  source(file.path(.d, "00_config.R")); source(file.path(.d, "01_functions.R"))
}
require_pkgs(c("vegan", "randomForest", "dplyr"))

summ_f <- file.path(DIR_CAL, "summary.csv")
kg_f   <- file.path(DIR_KG, "kg_baseline.csv")
if (!file.exists(summ_f)) stop("Run 02_calibrate.R first: ", summ_f, " missing")
if (!file.exists(kg_f))   stop("Run 04_kg_transitions.R first: ", kg_f, " missing")

summ <- read_out(summ_f)
kg   <- read_out(kg_f)
clim <- utils::read.csv(CARAVAN_ATTR_CLIM, stringsAsFactors = FALSE)
phy  <- read_physiography()
meta <- read_catchment_meta()

# ---- Assemble the analysis table -------------------------------------------
d <- merge(summ, kg[, c("gauge_id", "class")], by = "gauge_id")
d <- merge(d, clim, by = "gauge_id", all.x = TRUE)
d <- merge(d, phy,  by = "gauge_id", all.x = TRUE)
d <- merge(d, meta[, c("gauge_id", "area")], by = "gauge_id", all.x = TRUE)
d$log_area <- log10(d$area)
d$kg_zone <- factor(d$class)

clim_vars <- c("aridity", "p_mean", "pet_mean", "frac_snow",
               "seasonality", "moisture_index")
phy_vars  <- c("log_area", "ele_mt_smx", "slp_dg_sav", "for_pc_sse",
               "swc_pc_syr", "soc_th_sav", "slt_pc_sav", "snd_pc_sav",
               "kar_pc_sse", "gwt_cm_sav")

clim_vars <- intersect(clim_vars, names(d))
phy_vars  <- intersect(phy_vars, names(d))
resp_vars <- paste0("med_", PAR_NAMES)

# Drop near-zero-variance or mostly-missing predictors.
usable <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  mean(is.finite(x)) > 0.8 && stats::sd(x, na.rm = TRUE) > 0
}
clim_vars <- clim_vars[vapply(d[clim_vars], usable, logical(1))]
phy_vars  <- phy_vars[vapply(d[phy_vars], usable, logical(1))]

need <- c(resp_vars, clim_vars, phy_vars, "kg_zone")
dd <- d[stats::complete.cases(d[, need]), , drop = FALSE]
msg("complete cases for attribution: ", nrow(dd), " catchments")

if (nrow(dd) < 30) stop("Too few complete cases for variance partitioning")

# ---- (1) Variance partitioning ---------------------------------------------
vp_rows <- list()
for (p in resp_vars) {
  y <- as.matrix(dd[[p]])
  X1 <- as.matrix(dd[, clim_vars, drop = FALSE])
  X2 <- as.matrix(dd[, phy_vars, drop = FALSE])
  vp <- tryCatch(vegan::varpart(y, X1, X2), error = function(e) NULL)
  if (is.null(vp)) next
  fr <- vp$part$fract
  ind <- vp$part$indfract
  clim_r2 <- fr[1, "Adj.R.squared"]
  phy_r2  <- fr[2, "Adj.R.squared"]
  joint   <- fr[3, "Adj.R.squared"]
  shared  <- ind[3, "Adj.R.squared"]
  vp_rows[[p]] <- data.frame(
    parameter = sub("^med_", "", p),
    climate_total = clim_r2,
    physio_total = phy_r2,
    shared = max(0, shared),
    climate_unique = max(0, ind[1, "Adj.R.squared"]),
    physio_unique = max(0, ind[2, "Adj.R.squared"]),
    unexplained = 1 - max(0, joint),
    n = nrow(dd)
  )
}
vp_tab <- do.call(rbind, vp_rows)
if (is.null(vp_tab)) stop("Variance partitioning failed for all parameters")
write_out(vp_tab, file.path(DIR_ATTR, "varpart.csv"))

# ---- (2) Does KG zone add information beyond attributes? -------------------
nested <- list()
for (p in resp_vars) {
  f0 <- stats::as.formula(paste(p, "~", paste(c(clim_vars, phy_vars), collapse = " + ")))
  f1 <- stats::update(f0, . ~ . + kg_zone)
  m0 <- tryCatch(stats::lm(f0, data = dd), error = function(e) NULL)
  m1 <- tryCatch(stats::lm(f1, data = dd), error = function(e) NULL)
  if (is.null(m0) || is.null(m1)) next
  a <- stats::anova(m0, m1)
  nested[[p]] <- data.frame(
    parameter = sub("^med_", "", p),
    r2_attr = summary(m0)$r.squared,
    r2_attr_zone = summary(m1)$r.squared,
    delta_r2_zone = summary(m1)$r.squared - summary(m0)$r.squared,
    p_zone = a$`Pr(>F)`[2]
  )
}
nested_tab <- do.call(rbind, nested)
if (is.null(nested_tab)) {
  nested_tab <- data.frame(parameter = sub("^med_", "", resp_vars),
                           r2_attr = NA, r2_attr_zone = NA,
                           delta_r2_zone = NA, p_zone = NA)
}
write_out(nested_tab, file.path(DIR_ATTR, "nested_models.csv"))

# ---- (3) Random-forest importance ------------------------------------------
X <- dd[, c(clim_vars, phy_vars), drop = FALSE]
X[] <- lapply(X, function(x) as.numeric(x))
imp_rows <- list()
for (p in resp_vars) {
  set.seed(SEED)
  rf <- tryCatch(randomForest::randomForest(x = X, y = dd[[p]],
                                            ntree = 500, importance = TRUE),
                 error = function(e) NULL)
  if (is.null(rf)) next
  im <- randomForest::importance(rf)
  imp_rows[[p]] <- data.frame(
    parameter = sub("^med_", "", p),
    variable = rownames(im),
    inc_mse = im[, "%IncMSE"],
    inc_node_purity = im[, "IncNodePurity"]
  )
}
imp_tab <- do.call(rbind, imp_rows)
if (is.null(imp_tab)) {
  imp_tab <- data.frame(parameter = character(), variable = character(),
                        inc_mse = numeric(), inc_node_purity = numeric())
}
write_out(imp_tab, file.path(DIR_ATTR, "rf_importance.csv"))

# ---- Manuscript table -------------------------------------------------------
tab <- vp_tab
tab$climate_pct <- round(100 * tab$climate_total, 1)
tab$physio_pct  <- round(100 * tab$physio_total, 1)
tab$shared_pct  <- round(100 * tab$shared, 1)
tab$unexplained_pct <- round(100 * tab$unexplained, 1)
tab <- merge(tab[, c("parameter", "climate_pct", "physio_pct", "shared_pct",
                     "unexplained_pct")],
             nested_tab[, c("parameter", "delta_r2_zone", "p_zone")],
             by = "parameter", all.x = TRUE)
write_out(tab, file.path(DIR_TAB, "T6_climate_vs_physiography.csv"))
msg("attribution done")
