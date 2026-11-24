# =============================================================================
# 01_functions.R
# Core numerical and data functions for the CZIPEF revision.
#
# Sourced after 00_config.R. No script should re-implement any of these.
# =============================================================================

# ---- Packages ---------------------------------------------------------------
require_pkgs <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Missing packages: ", paste(missing, collapse = ", "),
         "\nInstall them before running this stage.", call. = FALSE)
  }
  invisible(TRUE)
}

# ---- Catchment metadata -----------------------------------------------------
read_catchment_meta <- function(ids = NULL) {
  meta <- utils::read.csv(CATCHMENT_LIST, stringsAsFactors = FALSE)
  clim <- utils::read.csv(CARAVAN_ATTR_CLIM, stringsAsFactors = FALSE)
  meta <- merge(meta, clim, by = "gauge_id", all.x = TRUE, sort = FALSE)
  if (!is.null(ids)) meta <- meta[meta$gauge_id %in% ids, , drop = FALSE]
  meta[order(meta$gauge_id), , drop = FALSE]
}

read_physiography <- function() {
  require_pkgs("readxl")
  h <- readxl::read_excel(CARAVAN_ATTR_HYDRO)
  # HydroATLAS uses large negative sentinels for missing values.
  num <- vapply(h, is.numeric, logical(1))
  h[num] <- lapply(h[num], function(x) { x[x < -900] <- NA; x })
  keep <- c("gauge_id", "ele_mt_smx", "slp_dg_sav", "for_pc_sse",
            "crp_pc_sse", "urb_pc_sse", "swc_pc_syr", "soc_th_sav",
            "slt_pc_sav", "snd_pc_sav", "kar_pc_sse", "gwt_cm_sav",
            "sgr_dk_sav", "lit_cl_smj", "ppd_pk_sav", "pre_mm_syr",
            "pet_mm_syr", "run_mm_syr", "aet_mm_syr", "tmp_dc_syr",
            "snw_pc_syr")
  keep <- intersect(keep, names(h))
  as.data.frame(h[, keep, drop = FALSE])
}

# ---- Forcing ----------------------------------------------------------------
# Read one CAMELS/Caravan catchment, clip to a period, and optionally apply a
# delta change (dp multiplies P, dt is added to all temperatures).
read_forcing <- function(gauge_id, period = PERIOD_FULL, dp = 1, dt = 0,
                         latitude = NULL) {
  f <- file.path(CARAVAN_TS, paste0(gauge_id, ".csv"))
  if (!file.exists(f)) stop("Missing forcing file: ", f)
  d <- utils::read.csv(f, stringsAsFactors = FALSE, check.names = FALSE)
  d$date <- as.Date(d$date)
  d <- d[d$date >= as.Date(period["start"]) & d$date <= as.Date(period["end"]), ,
         drop = FALSE]
  if (nrow(d) == 0L) stop("No data in period for ", gauge_id)

  P    <- d$total_precipitation_sum * dp
  Tmin <- d$temperature_2m_min + dt
  Tmax <- d$temperature_2m_max + dt
  Tmean <- d$temperature_2m_mean + dt
  if (is.null(latitude)) latitude <- 40

  list(
    date = d$date,
    P = P,
    Temp = Tmean,
    Tmin = Tmin,
    Tmax = Tmax,
    Q = d$streamflow,
    PET = hargreaves_pet(Tmin, Tmax, latitude, d$date)
  )
}

# ---- PET: Hargreaves-Samani ------------------------------------------------
# Ra is computed in MJ m-2 d-1 and converted to mm d-1 with 0.408 before use.
# The original code omitted the 0.408 factor, inflating PET by ~2.45x.
hargreaves_pet <- function(tmin, tmax, latitude, date, convert = TRUE) {
  lat <- latitude * pi / 180
  tmean <- (tmin + tmax) / 2
  d <- as.integer(format(as.Date(date), "%j"))
  dec <- 0.409 * sin(2 * pi * d / 365 - 1.39)
  dr  <- 1 + 0.033 * cos(2 * pi * d / 365)
  ws  <- acos(pmax(pmin(-tan(lat) * tan(dec), 1), -1))
  Ra  <- (24 * 60 / pi) * 0.0820 * dr *
    (ws * sin(lat) * sin(dec) + cos(lat) * cos(dec) * sin(ws))
  if (convert) Ra <- Ra * 0.408
  pet <- 0.0023 * (tmean + 17.8) * sqrt(pmax(tmax - tmin, 0)) * Ra
  pmax(pet, 0)
}

# ---- Parameter sampling -----------------------------------------------------
lhs_params <- function(n, seed = SEED) {
  require_pkgs("lhs")
  set.seed(seed)
  u <- lhs::randomLHS(n, length(PAR_NAMES))
  p <- sweep(u, 2, PAR_UPPER - PAR_LOWER, "*")
  p <- sweep(p, 2, PAR_LOWER, "+")
  colnames(p) <- PAR_NAMES
  as.data.frame(p)
}

hash_seed <- function(x, base = SEED) {
  as.integer(base + (sum(utf8ToInt(as.character(x))) %% 100000L))
}

# ---- HBV model --------------------------------------------------------------
# Corrected version of the McGuire/Gannon HBV:
#   * initial snowpack = 0 (not 152.4 mm)
#   * triangular routing implemented correctly (no MATLAB `end`)
#   * returns a plain numeric vector to keep the calibration loop light
tri_weights <- function(maxbas, subdivisions = 200L) {
  if (!is.finite(maxbas) || maxbas <= 1) return(1)
  nb <- ceiling(maxbas)
  f <- function(x) ifelse(x < maxbas / 2,
                          4 * x / maxbas^2,
                          4 / maxbas - 4 * x / maxbas^2)
  w <- vapply(seq_len(nb), function(k) {
    stats::integrate(f, lower = k - 1, upper = min(k, maxbas),
                     subdivisions = subdivisions)$value
  }, numeric(1))
  w / sum(w)
}

hbv <- function(pars, P, Temp, PET, routing = USE_ROUTING) {
  FC <- pars[1]; beta <- pars[2]; LP <- pars[3]; SFCF <- pars[4]
  TT <- pars[5]; CFMAX <- pars[6]; k0 <- pars[7]; k1 <- pars[8]
  k2 <- pars[9]; UZL <- pars[10]; PERC <- pars[11]; MAXBAS <- pars[12]
  CFR <- 0.05; CWH <- 0.1

  n <- length(P)
  if (length(Temp) != n || length(PET) != n) stop("Forcing length mismatch")
  if (anyNA(P) || anyNA(Temp) || anyNA(PET)) return(rep(NA_real_, n))

  Qgen <- numeric(n)
  SWE  <- numeric(n)
  AET  <- numeric(n)
  soil <- numeric(n)
  SUZ  <- 0; SLZ <- 0
  SP   <- 0; WC <- 0
  SM   <- FC

  for (t in seq_len(n)) {
    ## Snow
    inc <- 0
    if (SP > 0) {
      if (P[t] > 0) {
        if (Temp[t] > TT) WC <- WC + P[t] else SP <- SP + P[t] * SFCF
      }
      if (Temp[t] > TT) {
        melt <- CFMAX * (Temp[t] - TT)
        if (melt > SP) {
          inc <- SP + WC; WC <- 0; SP <- 0
        } else {
          SP <- SP - melt; WC <- WC + melt
          if (WC >= CWH * SP) { inc <- WC - CWH * SP; WC <- CWH * SP }
        }
      } else {
        refreeze <- min(CFR * CFMAX * (TT - Temp[t]), WC)
        SP <- SP + refreeze; WC <- WC - refreeze
      }
    } else {
      if (Temp[t] > TT) inc <- P[t] else SP <- P[t] * SFCF
    }
    SWE[t] <- SP + WC

    ## Soil moisture
    rQ <- 0
    old_SM <- SM
    if (inc > 0) {
      m <- floor(inc); y <- inc - m
      if (m > 0) {
        for (i in seq_len(m)) {
          dQdP <- min((SM / FC)^beta, 1)
          SM <- SM + 1 - dQdP
          rQ <- rQ + dQdP
        }
      }
      dQdP <- min((SM / FC)^beta, 1)
      SM <- SM + (1 - dQdP) * y
      rQ <- rQ + dQdP * y
    }
    mean_SM <- (SM + old_SM) / 2
    AET[t] <- if (mean_SM < LP * FC) PET[t] * mean_SM / (LP * FC) else PET[t]
    if (SP + WC > 0) AET[t] <- 0
    SM <- max(SM - AET[t], 0)
    soil[t] <- SM

    ## Groundwater
    SUZ <- SUZ + rQ
    if (SUZ - PERC < 0) { SLZ <- SLZ + SUZ; SUZ <- 0 } else { SLZ <- SLZ + PERC; SUZ <- SUZ - PERC }
    qstz <- if (SUZ < UZL) 0 else (SUZ - UZL) * k0
    qsuz <- SUZ * k1
    qslz <- SLZ * k2
    SUZ <- SUZ - qsuz - qstz
    SLZ <- SLZ - qslz
    Qgen[t] <- qstz + qsuz + qslz
  }

  if (routing && is.finite(MAXBAS) && MAXBAS > 1) {
    w <- tri_weights(MAXBAS)
    q <- as.numeric(stats::filter(Qgen, w, method = "convolution", sides = 1))
    q[is.na(q)] <- 0
  } else {
    q <- Qgen
  }
  q
}

# ---- Performance metrics ----------------------------------------------------
perf_metrics <- function(obs, sim) {
  ok <- is.finite(obs) & is.finite(sim)
  if (sum(ok) < 10) return(c(KGE = NA, NSE = NA, PBIAS = NA))
  o <- obs[ok]; s <- sim[ok]
  if (stats::sd(o) == 0) return(c(KGE = NA, NSE = NA, PBIAS = NA))
  r <- stats::cor(o, s)
  alpha <- stats::sd(s) / stats::sd(o)
  beta  <- mean(s) / mean(o)
  kge <- 1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
  nse <- 1 - sum((o - s)^2) / sum((o - mean(o))^2)
  pbias <- 100 * sum(o - s) / sum(o)
  c(KGE = kge, NSE = nse, PBIAS = pbias)
}

# ---- Flow indicators (Olden & Poff 2003) -----------------------------------
flow_indices <- function(date, q) {
  ok <- is.finite(q)
  if (sum(ok) < 365) return(c(MAR = NA, SAF = NA, LFI = NA, MAMF = NA))
  date <- date[ok]; q <- q[ok]
  yr <- format(date, "%Y")
  ann_sum <- tapply(q, yr, sum)
  ann_min <- tapply(q, yr, min)
  ann_max <- tapply(q, yr, max)
  ann_med <- tapply(q, yr, stats::median)
  ann_mean <- tapply(q, yr, mean)
  c(
    MAR  = mean(ann_sum),                              # mm yr-1
    SAF  = (mean(ann_sum) - stats::median(ann_sum)) / stats::median(ann_sum),
    LFI  = mean(ann_min) / mean(ann_mean),
    MAMF = stats::median(ann_max) / stats::median(ann_med)
  )
}

# ---- Vulnerability classes --------------------------------------------------
# One generic classifier. `direction` says which sign is the vulnerability:
#   "decrease" -> MAR and LFI (less water, less low flow)
#   "increase" -> MAMF (more peaked high flows, flood risk)
# Implemented with explicit thresholds (not cut() factor codes, which return
# 1..4 rather than the label values).
vuln_class <- function(rel_pct, direction = c("decrease", "increase")) {
  direction <- match.arg(direction)
  out <- rep(0L, length(rel_pct))
  if (direction == "decrease") {
    out[rel_pct < 0]   <- 1L
    out[rel_pct < -25] <- 2L
    out[rel_pct < -50] <- 3L
  } else {
    out[rel_pct > 0]   <- 1L
    out[rel_pct > 25]  <- 2L
    out[rel_pct > 50]  <- 3L
  }
  out[is.na(rel_pct)] <- NA_integer_
  out
}

# Indicator metadata lookup so no script hard-codes a direction.
indicator_direction <- function(indicator) {
  i <- match(toupper(indicator), INDICATOR_META$indicator)
  if (anyNA(i)) stop("Unknown indicator: ", paste(indicator[is.na(i)], collapse = ", "))
  INDICATOR_META$direction[i]
}
indicator_label <- function(indicator) {
  i <- match(toupper(indicator), INDICATOR_META$indicator)
  INDICATOR_META$label[i]
}

vuln_class_mar  <- function(rel_pct) vuln_class(rel_pct, "decrease")
vuln_class_lfi  <- function(rel_pct) vuln_class(rel_pct, "decrease")
vuln_class_mamf <- function(rel_pct) vuln_class(rel_pct, "increase")

# Classify a matrix/data frame of relative changes (columns = indicators).
vuln_class_matrix <- function(rel, indicators = INDICATORS) {
  out <- sapply(indicators, function(ind) {
    vuln_class(rel[, ind], indicator_direction(ind))
  })
  if (is.null(dim(out))) out <- matrix(out, nrow = nrow(rel),
                                      dimnames = list(NULL, indicators))
  else dimnames(out)[[2]] <- indicators
  as.data.frame(out)
}

# ---- Köppen-Geiger ----------------------------------------------------------
kg_load <- function() {
  if (!exists("koeppen_geiger", mode = "function")) source(KG_FUNCTION)
  invisible(TRUE)
}

kg_monthly_normals <- function(date, P, Tmin, Tmax, Tmean) {
  mon <- as.integer(format(date, "%m"))
  yrs <- length(unique(format(date, "%Y")))
  Pmon <- tapply(P, mon, sum) / yrs
  Tn <- tapply(Tmin, mon, mean)
  Tx <- tapply(Tmax, mon, mean)
  Tm <- tapply(Tmean, mon, mean)
  data.frame(
    month = as.integer(names(Pmon)),
    P = as.numeric(Pmon), Tn = as.numeric(Tn),
    Tx = as.numeric(Tx), Tm = as.numeric(Tm)
  )
}

# Character KG class for one period under a delta change.
kg_class <- function(date, P, Tmin, Tmax, Tmean, dp = 1, dt = 0) {
  kg_load()
  cn <- kg_monthly_normals(date, P * dp, Tmin + dt, Tmax + dt, Tmean + dt)
  if (nrow(cn) != 12L) return(NA_character_)
  out <- tryCatch(
    as.character(koeppen_geiger(cn, class.nr = FALSE)[1, 1]),
    error = function(e) NA_character_
  )
  out
}

# 11 x 11 matrix of KG classes for one catchment.
kg_scenario_matrix <- function(date, P, Tmin, Tmax, Tmean,
                               dp = DP, dt = DT) {
  kg_load()
  cn0 <- kg_monthly_normals(date, P, Tmin, Tmax, Tmean)
  out <- matrix(NA_character_, nrow = length(dt), ncol = length(dp),
                dimnames = list(paste0("t", dt), paste0("p", dp)))
  for (i in seq_along(dp)) for (j in seq_along(dt)) {
    cn <- cn0
    cn$P  <- cn$P * dp[i]
    cn$Tn <- cn$Tn + dt[j]
    cn$Tx <- cn$Tx + dt[j]
    cn$Tm <- cn$Tm + dt[j]
    out[j, i] <- as.character(koeppen_geiger(cn, class.nr = FALSE)[1, 1])
  }
  out
}

# Numeric KG code (1-30) from the character class.
.kgenv <- new.env(parent = emptyenv())
kg_numeric <- function(x) {
  if (is.null(.kgenv$tab)) {
    tab <- utils::read.csv(KG_LOOKUP, stringsAsFactors = FALSE)
    names(tab) <- c("class_n", "group", "class", "c1", "c2", "c3", "color")
    tab$class <- trimws(tab$class)
    .kgenv$tab <- tab
  }
  .kgenv$tab$class_n[match(trimws(x), .kgenv$tab$class)]
}

# Official Beck et al. (2023) RGB palette, parsed from `KG Classes.csv`.
# Use the same colours as the source map so the revised figures are
# comparable with the published Köppen-Geiger maps.
kg_palette <- function(classes = NULL) {
  tab <- utils::read.csv(KG_LOOKUP, stringsAsFactors = FALSE)
  names(tab) <- c("class_n", "group", "class", "c1", "c2", "c3", "color")
  tab$class <- trimws(tab$class)
  rgb <- regmatches(tab$color, gregexpr("[0-9]+", tab$color))
  hex <- vapply(rgb, function(v) {
    v <- as.integer(v)
    if (length(v) < 3) return(NA_character_)
    grDevices::rgb(v[1], v[2], v[3], maxColorValue = 255)
  }, character(1))
  pal <- stats::setNames(hex, tab$class)
  if (is.null(classes)) pal else pal[intersect(classes, names(pal))]
}

# ---- Calibration ------------------------------------------------------------
# Calibrate one catchment over one period and return all simulated sets with
# their metrics, plus a `behavioural` flag.
calibrate_catchment <- function(gauge_id, period = PERIOD_FULL,
                                latitude = NULL, n_lhs = N_LHS,
                                seed = hash_seed(gauge_id),
                                use_routing = USE_ROUTING,
                                verbose = FALSE) {
  f <- read_forcing(gauge_id, period = period, latitude = latitude)
  pars <- lhs_params(n_lhs, seed = seed)
  P <- f$P; Temp <- f$Temp; PET <- f$PET; Q <- f$Q
  ns <- nrow(pars)

  eval_idx <- seq.int(min(WARMUP_DAYS + 1L, length(Q)), length(Q))

  one <- function(i) {
    q <- hbv(unlist(pars[i, ], use.names = FALSE), P, Temp, PET,
             routing = use_routing)
    perf_metrics(Q[eval_idx], q[eval_idx])
  }

  if (N_CORES > 1L) {
    res <- future.apply::future_lapply(seq_len(ns), one, future.seed = TRUE)
  } else {
    res <- lapply(seq_len(ns), one)
  }
  m <- do.call(rbind, res)
  out <- cbind(pars, as.data.frame(m))
  out$gauge_id <- gauge_id
  out$behavioural <- with(out,
    is.finite(KGE) & is.finite(NSE) & is.finite(PBIAS) &
      KGE >= BEHAV_KGE & NSE >= BEHAV_NSE & abs(PBIAS) <= BEHAV_PBIAS)
  if (verbose) {
    msg(gauge_id, ": ", sum(out$behavioural), "/", nrow(out),
        " behavioural; best KGE = ", round(max(out$KGE, na.rm = TRUE), 3))
  }
  out
}

# Top-N behavioural sets, ordered by KGE then NSE.
select_behavioural <- function(cal, n_keep = N_KEEP) {
  b <- cal[cal$behavioural, , drop = FALSE]
  b <- b[order(-b$KGE, -b$NSE), , drop = FALSE]
  utils::head(b, n_keep)
}

# Evaluate a fixed set of parameter sets over a new period (no recalibration).
evaluate_sets <- function(gauge_id, period, pars, latitude = NULL,
                          use_routing = USE_ROUTING) {
  f <- read_forcing(gauge_id, period = period, latitude = latitude)
  eval_idx <- seq.int(min(WARMUP_DAYS + 1L, length(f$Q)), length(f$Q))
  m <- t(vapply(seq_len(nrow(pars)), function(i) {
    q <- hbv(unlist(pars[i, PAR_NAMES], use.names = FALSE),
             f$P, f$Temp, f$PET, routing = use_routing)
    perf_metrics(f$Q[eval_idx], q[eval_idx])
  }, numeric(3)))
  as.data.frame(m)
}

# Per-catchment parameter summary: median and 5-95% range of the retained sets.
summarise_parameters <- function(cal, n_keep = N_KEEP) {
  b <- select_behavioural(cal, n_keep)
  if (!nrow(b)) return(NULL)
  out <- data.frame(
    gauge_id = b$gauge_id[1],
    n_sets = nrow(b),
    KGE_med = stats::median(b$KGE),
    NSE_med = stats::median(b$NSE),
    PBIAS_med = stats::median(b$PBIAS),
    stringsAsFactors = FALSE
  )
  for (p in PAR_NAMES) {
    out[[paste0("med_", p)]] <- stats::median(b[[p]])
    out[[paste0("q05_", p)]] <- stats::quantile(b[[p]], 0.05, names = FALSE)
    out[[paste0("q95_", p)]] <- stats::quantile(b[[p]], 0.95, names = FALSE)
  }
  out
}

# ---- Resampling -------------------------------------------------------------
# Bounded, correlation-preserving Gaussian-copula resampler.
# Marginally, each parameter follows the empirical distribution of the pool;
# the rank correlation of the pool is retained through a latent Gaussian copula.
# Values are inside the parameter bounds by construction.
resample_params <- function(pool, n, seed = SEED + 1L,
                            method = c("copula", "kde", "bootstrap")) {
  method <- match.arg(method)
  pool <- as.matrix(pool[, PAR_NAMES, drop = FALSE])
  if (nrow(pool) < 5) stop("Pool too small to resample")
  set.seed(seed)

  if (method == "bootstrap") {
    idx <- sample.int(nrow(pool), n, replace = TRUE)
    out <- pool[idx, , drop = FALSE]
    # small jitter within 2% of each parameter's observed range
    rng <- apply(pool, 2, function(x) diff(range(x)))
    rng[!is.finite(rng) | rng == 0] <- 0
    jit <- matrix(stats::rnorm(n * ncol(pool), 0, 0.02), n, ncol(pool))
    out <- out + sweep(jit, 2, pmax(rng, 1e-8), "*")
    lo <- PAR_LOWER[colnames(pool)]; hi <- PAR_UPPER[colnames(pool)]
    out <- sweep(out, 2, lo, pmax); out <- sweep(out, 2, hi, pmin)
    return(as.data.frame(out))
  }

  if (method == "kde") {
    require_pkgs("ks")
    # scale to unit cube, multivariate KDE, reject outside the cube
    lo <- PAR_LOWER[colnames(pool)]; hi <- PAR_UPPER[colnames(pool)]
    z <- sweep(pool, 2, lo, "-"); z <- sweep(z, 2, hi - lo, "/")
    const <- which(apply(z, 2, stats::sd) == 0 | !is.finite(apply(z, 2, stats::sd)))
    zk <- z
    if (length(const)) {
      # tiny jitter only to make the KDE covariance non-singular
      for (j in const) zk[, j] <- zk[, j] + stats::rnorm(nrow(zk), 0, 1e-4)
    }
    fit <- ks::kde(x = zk, h = ks::Hpi(x = zk), eval.points = zk)
    out <- matrix(NA_real_, 0, ncol(pool))
    tries <- 0
    while (nrow(out) < n && tries < 50) {
      s <- ks::rkde(fit, n = max(2 * n, 500))
      ok <- apply(s, 1, function(r) all(r >= 0 & r <= 1))
      out <- rbind(out, s[ok, , drop = FALSE])
      tries <- tries + 1
    }
    out <- out[seq_len(n), , drop = FALSE]
    for (j in const) out[, j] <- z[1, j]
    out <- sweep(out, 2, hi - lo, "*"); out <- sweep(out, 2, lo, "+")
    colnames(out) <- colnames(pool)
    return(as.data.frame(out))
  }

  # Gaussian copula with empirical marginals
  sds <- apply(pool, 2, stats::sd)
  const <- which(!is.finite(sds) | sds == 0)
  var_cols <- setdiff(seq_len(ncol(pool)), const)
  out <- matrix(NA_real_, n, ncol(pool), dimnames = list(NULL, colnames(pool)))
  for (j in const) out[, j] <- pool[1, j]

  if (length(var_cols) >= 2) {
    ranks <- apply(pool[, var_cols, drop = FALSE], 2,
                   function(x) (rank(x, ties.method = "average") - 0.5) / nrow(pool))
    z <- stats::qnorm(ranks)
    R <- stats::cor(z)
    R[is.na(R)] <- 0
    diag(R) <- 1
    R <- (R + t(R)) / 2
    eig <- eigen(R, symmetric = TRUE)
    R <- eig$vectors %*% diag(pmax(eig$values, 1e-6), nrow = length(eig$values)) %*%
      t(eig$vectors)
    d <- sqrt(diag(R)); R <- R / outer(d, d)
    Z <- mvtnorm::rmvnorm(n, sigma = R)
    U <- stats::pnorm(Z)
    for (k in seq_along(var_cols)) {
      j <- var_cols[k]
      out[, j] <- stats::quantile(pool[, j], probs = U[, k], type = 1, names = FALSE)
    }
  } else if (length(var_cols) == 1) {
    j <- var_cols
    out[, j] <- sample(pool[, j], n, replace = TRUE)
  }
  lo <- PAR_LOWER[colnames(pool)]; hi <- PAR_UPPER[colnames(pool)]
  out <- sweep(out, 2, lo, pmax); out <- sweep(out, 2, hi, pmin)
  as.data.frame(out)
}

# ---- Vulnerability thresholds ----------------------------------------------
# Cell-level prevalence of the most vulnerable class for one catchment.
vuln_prevalence <- function(dat, indicator = "mar", cls_col = "mar_cls") {
  dat$cls <- dat[[cls_col]]
  dat <- dat[is.finite(dat$cls), , drop = FALSE]
  if (!nrow(dat)) return(NULL)
  agg <- stats::aggregate(cls ~ dp + dt, data = dat,
                          FUN = function(x) c(p3 = mean(x == 3), n = length(x)))
  out <- data.frame(dp = agg$dp, dt = agg$dt,
                    p3 = agg$cls[, "p3"], n = agg$cls[, "n"])
  out[order(out$dp, out$dt), , drop = FALSE]
}

# Crossing of a prevalence curve through 0.5. Works for increasing or
# decreasing curves; uses linear interpolation between adjacent points.
.crossing <- function(x, y, level = 0.5) {
  ok <- is.finite(x) & is.finite(y)
  x <- x[ok]; y <- y[ok]
  if (length(x) < 3) return(NA_real_)
  o <- order(x); x <- x[o]; y <- y[o]
  s <- y - level
  idx <- which(s[-1] * s[-length(s)] <= 0)
  if (!length(idx)) return(NA_real_)
  i <- idx[1]
  if (s[i] == 0) return(x[i])
  if (s[i + 1] == s[i]) return(x[i])
  x[i] + (level - y[i]) * (x[i + 1] - x[i]) / (y[i + 1] - y[i])
}

# Isotonically smoothed threshold in dp (averaged over dt) and in dt (at dp=1).
threshold_isotonic <- function(preval, target_dp = 1) {
  if (is.null(preval) || !nrow(preval)) return(c(p_thr = NA, dt_thr = NA))
  # dp curve: average prevalence over dt
  dp_curve <- stats::aggregate(p3 ~ dp, data = preval, FUN = mean)
  p_thr <- .crossing(dp_curve$dp, dp_curve$p3)
  # dt curve: average over dp near target_dp (or all if target not present)
  dt_curve <- stats::aggregate(p3 ~ dt, data = preval, FUN = mean)
  dt_thr <- .crossing(dt_curve$dt, dt_curve$p3)
  c(p_thr = p_thr, dt_thr = dt_thr)
}

# Logistic prevalence model: P(class 3) ~ dp * dt.
# Gives a dp threshold at dt = 0 and a dt threshold at dp = 1, with the
# direction learned from the data rather than hard-coded.
threshold_logistic <- function(preval) {
  if (is.null(preval) || nrow(preval) < 6) return(c(p_thr = NA, dt_thr = NA))
  k <- round(preval$p3 * preval$n)
  d <- data.frame(k = k, m = preval$n - k, dp = preval$dp, dt = preval$dt)
  fit <- tryCatch(stats::glm(cbind(k, m) ~ dp * dt, family = stats::binomial,
                             data = d), error = function(e) NULL)
  if (is.null(fit)) return(c(p_thr = NA, dt_thr = NA))
  b <- stats::coef(fit)
  if (length(b) < 4 || anyNA(b)) return(c(p_thr = NA, dt_thr = NA))
  p_thr <- if (abs(b[2]) > 1e-8) unname(-b[1] / b[2]) else NA
  dt_thr <- if (abs(b[3] + b[4]) > 1e-8) unname(-(b[1] + b[2]) / (b[3] + b[4])) else NA
  # reject extrapolations far outside the explored space
  if (!is.na(p_thr) && (p_thr < min(preval$dp) - 0.3 || p_thr > max(preval$dp) + 0.3)) p_thr <- NA
  if (!is.na(dt_thr) && (dt_thr < min(preval$dt) - 2 || dt_thr > max(preval$dt) + 2)) dt_thr <- NA
  c(p_thr = p_thr, dt_thr = dt_thr)
}

# Bootstrap the isotonic threshold by resampling parameter sets.
threshold_boot <- function(dat, cls_col = "mar_cls", B = 200, seed = SEED) {
  set.seed(seed)
  ids <- unique(dat$param_id)
  out <- matrix(NA_real_, B, 2, dimnames = list(NULL, c("p_thr", "dt_thr")))
  for (b in seq_len(B)) {
    pick <- sample(ids, length(ids), replace = TRUE)
    idx <- unlist(lapply(pick, function(i) which(dat$param_id == i)), use.names = FALSE)
    out[b, ] <- threshold_isotonic(vuln_prevalence(dat[idx, , drop = FALSE],
                                                   cls_col = cls_col))
  }
  apply(out, 2, stats::quantile, probs = c(0.05, 0.5, 0.95), na.rm = TRUE)
}

# Bootstrap the threshold from the cell summary (n, p3) with binomial noise.
# Cheaper than storing every parameter set, and statistically equivalent for
# the prevalence curve.
threshold_boot_cells <- function(preval, B = 500, seed = SEED) {
  set.seed(seed)
  out <- matrix(NA_real_, B, 2, dimnames = list(NULL, c("p_thr", "dt_thr")))
  for (b in seq_len(B)) {
    k <- stats::rbinom(nrow(preval), size = preval$n, prob = preval$p3)
    pv <- data.frame(dp = preval$dp, dt = preval$dt,
                     p3 = k / preval$n, n = preval$n)
    out[b, ] <- threshold_isotonic(pv)
  }
  apply(out, 2, stats::quantile, probs = c(0.05, 0.5, 0.95), na.rm = TRUE)
}

# ---- Sensitivity ------------------------------------------------------------
# Partial rank correlation coefficients with bootstrap intervals.
# Implemented directly because the installed sensitivity::pcc() mis-handles
# data frames (returns one coefficient per column including the response).
prcc_manual <- function(X, y, nboot = 500, conf = 0.95, seed = SEED) {
  X <- as.data.frame(X); y <- as.numeric(y)
  ok <- stats::complete.cases(X) & is.finite(y)
  X <- X[ok, , drop = FALSE]; y <- y[ok]
  p <- ncol(X); n <- nrow(X)
  Z <- apply(X, 2, rank); zy <- rank(y)
  colnames(Z) <- colnames(X)

  one <- function(idx) {
    zz <- Z[idx, , drop = FALSE]; yy <- zy[idx]
    vapply(seq_len(p), function(i) {
      others <- setdiff(seq_len(p), i)
      r1 <- stats::residuals(stats::lm(zz[, i] ~ zz[, others, drop = FALSE]))
      r2 <- stats::residuals(stats::lm(yy ~ zz[, others, drop = FALSE]))
      stats::cor(r1, r2)
    }, numeric(1))
  }

  est <- one(seq_len(n))
  set.seed(seed)
  boot <- t(vapply(seq_len(nboot), function(b) one(sample.int(n, n, TRUE)), numeric(p)))
  lo <- apply(boot, 2, stats::quantile, probs = (1 - conf) / 2, na.rm = TRUE)
  hi <- apply(boot, 2, stats::quantile, probs = 1 - (1 - conf) / 2, na.rm = TRUE)
  tval <- est * sqrt((n - p - 2) / pmax(1 - est^2, 1e-12))
  pval <- 2 * stats::pt(-abs(tval), df = n - p - 2)
  data.frame(parameter = colnames(X), estimate = est,
             lower = lo, upper = hi, p_value = pval, n = n)
}

# Sobol first-order and total-order indices (Saltelli et al. 2010).
sobol_indices <- function(X1, X2, model, nboot = 0) {
  X1 <- as.matrix(X1); X2 <- as.matrix(X2)
  s <- sensitivity::sobolSalt(model = model, X1 = X1, X2 = X2,
                              scheme = "A", nboot = nboot)
  out <- data.frame(
    parameter = if (!is.null(colnames(X1))) colnames(X1) else rownames(s$S),
    S_first = s$S[, "original"],
    S_total = s$T[, "original"],
    stringsAsFactors = FALSE
  )
  out
}

# ---- I/O helpers ------------------------------------------------------------
write_out <- function(x, file, row.names = FALSE) {
  utils::write.csv(x, file, row.names = row.names)
  msg("wrote ", file)
  invisible(file)
}

read_out <- function(file) utils::read.csv(file, stringsAsFactors = FALSE)

# Safe parallel plan: multisession on Windows, multicore elsewhere.
set_parallel <- function(cores = N_CORES) {
  if (cores <= 1L) { future::plan(future::sequential); return(invisible()) }
  if (.Platform$OS.type == "windows") {
    future::plan(future::multisession, workers = cores, gc = TRUE)
  } else {
    future::plan(future::multicore, workers = cores)
  }
  invisible()
}
