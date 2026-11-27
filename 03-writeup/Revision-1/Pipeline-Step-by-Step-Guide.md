# Step-by-step guide to the Revision-1 code

> Read this before editing the docx or any figure. It explains, stage by stage
> and function by function, what the code does, **why it does it**, which
> outputs feed which manuscript number, and how to modify each figure.
>
> Everything lives in `01-analysis/R/` (stages 00–10 + `run_all.R`). Nothing
> else in the project is executable. Production outputs go to
> `02-outputs/revision/`; the manuscript numbers in this guide come from the
> full production run of 19–20 Nov 2026 (log: `02-outputs/revision_run.log`).

---

## 0. The big picture

The paper tests one idea: **catchment model parameters are not stationary** —
they depend on the climate zone the catchment is in, and when climate change
moves a catchment into a different Köppen–Geiger (KG) zone, the "best"
parameters should change too. The framework has two sides:

- **SPF** (Stationary Parameter Framework): the historically calibrated
  parameters are reused unchanged for every future scenario.
- **CZIPEF** (Climate-Zone-Informed Parameter Evolution Framework): when a
  scenario moves the catchment into a different KG class, the parameters are
  resampled from the pool of behavioural sets of *that target class*.

The comparison quantity is the **vulnerability threshold**: how much
precipitation decrease (ΔP) or warming (ΔT) is needed before the indicator
(MAR/LFI/MAMF) enters the most vulnerable class (class 3, > 50 % change) in at
least half of the ensemble. If CZIPEF systematically shifts that threshold,
parameter non-stationarity matters for vulnerability assessment.

Data flow (each stage reads only what earlier stages wrote):

```
Caravan/CAMELS forcing + attributes          (external, D:/OneDrive/...)
        │
02  LHS calibration per catchment  ──► calibration/psets/*_behav.csv, summary.csv
        │
03  split-sample + moving windows   ──► validation/split_sample.csv, parameter_windows.csv
        │
04  Köppen–Geiger classes           ──► kg/kg_baseline.csv, kg_scenario_long.csv, kg_map_levels.csv
        │
05  climate vs physiography         ──► attribution/varpart.csv, rf_importance.csv
        │
06  KG-class parameter pools        ──► pools/pools.rds, <class>_pool.csv
        │
07  121-scenario simulations SPF+CZIPEF ─► scenarios/cells_all.csv
        │
08  thresholds + SPF–CZIPEF compare ──► thresholds/thresholds.csv, comparison.csv; tables T7, T8
        │
09  PRCC/Sobol + uncertainty        ──► sensitivity/prcc_*.csv, uncertainty.csv
        │
10  figures                         ──► figures/FA…F14 (PDF+PNG); tables T3–T9 feed the docx
```

Key sample numbers (production run): **332 candidate catchments** from the
1°-grid selection, **222 analysed** (≥ 50 behavioural sets, KGE ≥ 0.5,
|PBIAS| ≤ 25 %).

---

## 1. `run_all.R` — orchestration

- Reads the stage list from `TSFT_STAGES` (default `02,03,04,05,06,07,08,09,10`),
  runs each stage script in a fresh environment via `sys.source`, times it, and
  stops on the first failure unless `TSFT_STOP_ON_ERROR=0`.
- **Why**: each stage is resumable (it checks which outputs already exist and
  skips finished work), so you can re-run stage 10 alone after editing a figure:
  `TSFT_STAGES=10 Rscript 01-analysis/R/run_all.R`.

Other environment overrides (see `00_config.R`): `TSFT_NCATCH` (smoke-test
subset), `TSFT_CATCHMENTS` (explicit list), `TSFT_REV_DIR` (output root).

---

## 2. `00_config.R` — the single source of truth

Everything a reviewer could ask "where does this number come from?" about is a
named constant here. Scripts never hard-code a path, bound or threshold.

| Block | Contents | Why |
|-------|----------|-----|
| Paths | `PROJ`, `DIR_REV` … `DIR_TAB` | All products isolated in `02-outputs/revision/`; smoke tests redirect with `TSFT_REV_DIR` |
| External data | `CARAVAN_TS`, attribute CSVs, `CATCHMENT_LIST` (`US_Cat_30_1Deg.csv`), `KG_LOOKUP` (`KG Classes.csv`), `KG_FUNCTION` (`kg_class_all.R`) | Forcing is CAMELS-US via Caravan (mm/day); the KG classifier and official colour palette come from data files, not code |
| Reproducibility | `SEED <- 20251119`, `set.seed(SEED)` | One seed for the whole project |
| `PAR_BOUNDS` | 12 HBV parameters: FC, beta, LP, SFCF, TT, CFMAX, k0, k1, k2, UZL, PERC, MAXBAS | These are exactly Table 2 of the paper. Comment documents that TT is −2.5…2.5 (the old code used −1.5 by mistake) |
| `USE_ROUTING <- TRUE` | Triangular routing enabled | The old code had a MATLAB `end` inside the R routing branch, so routing silently failed and MAXBAS was inert. Fixed → MAXBAS is now identifiable and stays in Table 2 |
| Periods | `PERIOD_FULL 1981–2010`, `PERIOD_CAL 1981–1995`, `PERIOD_VAL 1996–2010`, `WARMUP_DAYS 730` | The manuscript must say 1981 (data record starts 1981, not 1980). 2-year warm-up is standard for HBV |
| Calibration budget | `N_LHS 10000`, `N_LHS_VALID 2000`, `N_KEEP 200`, `MIN_SETS 50` | 10 000-sample Latin hypercube per catchment; keep the 200 best behavioural sets; a catchment needs ≥ 50 to enter the analysis |
| Acceptance | `BEHAV_KGE 0.5`, `BEHAV_NSE -Inf`, `BEHAV_PBIAS 25` | KGE + PBIAS screen; NSE is reported but **not** used to screen (requiring NSE ≥ 0.5 would drop basins where HBV is structurally limited, e.g. karst/regulated) |
| Scenario grid | `DP = seq(0.5, 1.5, 0.1)` (11), `DT = seq(-2, 8, 1)` (11) | The 121 delta-change cells. ΔP −50 %…+50 %, ΔT −2…+8 °C |
| `MAX_FALLBACK 0.10` | CZIPEF cells with > 10 % fallback scenarios are reported separately | Keeps the CZIPEF comparison clean of unsupported climate classes |
| `N_ENSEMBLE 50` | Parameter sets per scenario | Computational cost control; baseline median uses the full pool, so classes don't depend on this draw |
| Indicators | `INDICATORS <- c("MAR","LFI","MAMF")`, `PRIMARY_INDICATOR <- "MAR"`, `INDICATOR_META` | MAR primary; LFI/MAMF supplementary; vulnerability direction stored once ("decrease","decrease","increase") |
| `VULN_BREAKS/LABELS` | class 0/1/2/3 at 0/25/50 % change | The four-class scale used everywhere |
| `KG_MAP_LEVELS` | ΔP × {0.5, 1.0, 1.5} × ΔT × {+1.5,+2,+3,+4} | The 12-panel Beck-style delta-change map (manuscript Fig. 8) |
| Sensitivity | `N_PRCC 2000`, `SOBOL_N 512`, `SENS_CLASSES` (6 KG classes) | One representative catchment per class (median aridity) keeps stage 09 tractable |
| Figures | `FIG_DPI 300`, `FIG_WIDTH 7`, `FIG_HEIGHT 5` | Defaults for `save_fig()` |

---

## 3. `01_functions.R` — core numerics (read once, used everywhere)

### 3.1 Data input
- `read_catchment_meta()` — merges the selection list with Caravan climatic
  attributes (aridity, p_mean, pet_mean, frac_snow, …).
- `read_physiography()` — HydroATLAS attributes; **values < −900 are set to
  NA** because HydroATLAS uses large negative sentinels for missing data.
  Keeps slope, elevation, forest/crop/urban %, soil texture, karst, groundwater
  depth, snow cover, etc. Used by stage 05.

### 3.2 `read_forcing(gauge_id, period, dp, dt, latitude)`
Reads one catchment time series, clips to a period, and **optionally applies a
delta change on the way in**: `P × dp`, `T + dt` on Tmin/Tmax/Tmean.
Returns date, P, Temp, Tmin, Tmax, Q and PET.
**Why**: one function feeds both the historical runs (dp=1, dt=0) and the
scenario runs (dp, dt from the grid), so a scenario is *defined identically*
wherever it is used — HBV forcing in stage 07 and KG classification in stage 04.

### 3.3 `hargreaves_pet()` — the PET bug fix
Hargreaves–Samani with extraterrestrial radiation Ra computed in MJ m⁻² d⁻¹ and
**converted to mm d⁻¹ with the 0.408 factor**.
**Why**: the original code omitted 0.408, inflating PET ≈ 2.45×. That was a
result-changing bug; every stage now uses this one function. The manuscript
states the 0.408 MJ m⁻² d⁻¹ conversion explicitly (Methods).

### 3.4 `lhs_params()`, `hash_seed()`
- Latin hypercube over `PAR_BOUNDS`.
- `hash_seed(x) = SEED + sum(utf8ToInt(x)) %% 100000` — a **deterministic
  per-catchment/per-class seed** derived from the name.
  **Why**: resumability. Re-running a stage reproduces the same random draws
  per catchment without storing RNG state.

### 3.5 `hbv()` — the corrected model
HBV with snow (SFCF, TT, CFMAX, CFR refreeze, CWH meltwater retention), soil
(FC, beta, LP; AET limited when snow-covered), groundwater (k0/UZL, k1, k2,
PERC), and **triangular routing** (`tri_weights` integrates the triangular
MAXBAS kernel over daily bins; `stats::filter(..., "convolution")` applies it).
Initial snowpack **SP = 0** (was 152.4 mm).
Returns only generated flow (a plain numeric vector) to keep the 10 000-run
calibration loop fast.

### 3.6 `perf_metrics()` — KGE/NSE/PBIAS
Standard Gupta KGE decomposition (r, α, β); PBIAS in %.
**Why one implementation**: the old Step04 saved KGE under an `NSE` header —
label bugs are impossible when the metric vector is built once.

### 3.7 `flow_indices()` — the three indicators (Olden & Poff 2003)
Computed **per water year** then aggregated:
- `MAR` = mean of annual totals (mm yr⁻¹)
- `SAF` = (mean − median)/median of annual totals (kept for completeness)
- `LFI` = mean of annual minima / mean of annual means (low-flow index)
- `MAMF` = median of annual maxima / median of annual medians (high-flow ratio)

**Why the SAF formula lives here**: the old Step06_a and Step06_b used two
different SAF formulas; there is now exactly one.

### 3.8 `vuln_class()` — one direction-aware classifier
```r
vuln_class(rel_pct, direction)   # direction: "decrease" | "increase"
# "decrease": rel < 0 → 1, < -25 → 2, < -50 → 3
# "increase": rel > 0 → 1, > 25 → 2, > 50 → 3
```
`INDICATOR_META` supplies the direction; wrappers `vuln_class_mar/lfi/mamf` and
`vuln_class_matrix()` apply it per indicator.
**Why**: the old Step08 hard-coded split signs and wrote LFI/MAMF results into
`mar_thr`. With the direction stored once, the same classifier serves all three
indicators and no script can flip a sign by accident.

### 3.9 Köppen–Geiger utilities
- `kg_monthly_normals()` — 12-month climatology of P, Tmin, Tmax, Tmean.
- `kg_class()` — classifies one period, optionally under a delta change, using
  `kg_class_all.R` (the Beck et al. 2023 scheme).
- `kg_scenario_matrix()` — the 11 × 11 (dt × dp) class matrix per catchment.
- `kg_numeric()` — character → numeric code 1–30 via `KG Classes.csv`.
- `kg_palette()` — parses the **official Beck et al. (2023) RGB colours** from
  `KG Classes.csv` into hex strings.
  **Why**: the revised figures must be visually comparable with the published
  KG maps; the old figures used ad-hoc colours.

### 3.10 Calibration helpers
- `calibrate_catchment()` — LHS sample, run HBV for every set (parallel via
  `future.apply`), compute metrics after `WARMUP_DAYS`, flag behavioural sets.
- `select_behavioural()` — behavioural sets ordered by KGE then NSE, top-N.
- `evaluate_sets()` — re-run fixed parameter sets over a new period without
  recalibration (used for split-sample validation).
- `summarise_parameters()` — per-catchment median + q05/q95 of every retained
  parameter (this is the input to stage 05 and to manuscript Table 3).

### 3.11 `resample_params()` — the copula resampler (replaces KDE)
Three methods, default `"copula"`:
1. **copula (default)** — Gaussian copula with empirical marginals: rank
   parameters to uniforms, fit the rank-correlation matrix (eigen-regularised,
   made positive-definite), draw Z ~ N(0, R), map back through the empirical
   quantile function, clamp to `PAR_BOUNDS`.
   **Why**: bounded by construction, preserves parameter correlations, and the
   margins follow the pool's empirical distributions. The old univariate KDE
   (i) reset the RNG per parameter, (ii) produced ~1 % out-of-bounds values,
   (iii) destroyed correlations, and (iv) held MAXBAS fixed.
2. **kde** — multivariate KDE in the unit cube, rejection-sampled; kept only as
   a sensitivity check (`DIAG_KDE`, off by default — it is slow in 12-D).
3. **bootstrap** — resample pool rows with a 2 % range jitter.

### 3.12 Threshold estimators — see §9 (the "no CART tree" answer)

### 3.13 Sensitivity helpers
- `prcc_manual()` — PRCC implemented directly (rank everything, residualise
  each predictor and the response against the others, correlate the residuals),
  with bootstrap CIs and t-test p-values.
  **Why hand-rolled**: the installed `sensitivity::pcc()` mis-handles data
  frames (returns one coefficient per column including the response).
- `sobol_indices()` — Saltelli `sobolSalt` with the correct matrix/argument
  order (the old script passed them wrongly).

### 3.14 I/O and parallelism
`write_out()`/`read_out()` (CSV with a log line), `set_parallel()`
(multisession on Windows, multicore elsewhere, `N_CORES` capped at 8).

---

## 4. `02_calibrate.R` — Monte-Carlo calibration (stage 02)

For every catchment in `US_Cat_30_1Deg.csv`:

1. `calibrate_catchment()` with `N_LHS = 10 000` on 1981–2010 (2 y warm-up).
2. `select_behavioural()` keeps up to 200 sets (KGE ≥ 0.5, |PBIAS| ≤ 25 %).
3. **If < `MIN_SETS` (50) behavioural sets → the catchment is dropped from all
   downstream analysis** (no `*_behav.csv`, no entry in `summary.csv`).
   **Why the file-inclusion rule matters**: keeping `psets/` and `summary.csv`
   on the same rule guarantees the scenario/threshold/attribution samples are
   identical — the old code had an attribution sample that differed from the
   scenario sample.
4. Everything is **resumable**: `performance.csv` records which gauge_ids are
   done; the loop skips them.
5. A calibration report `T3_calibration_summary.csv` is written (catchments,
   median KGE/NSE/|PBIAS| of behavioural sets, % above thresholds).

Production result: **222 of 332 catchments pass**; median behavioural KGE is
the number quoted in Abstract/P34. `psets/<id>_behav.csv` (per catchment) and
`calibration/performance.csv` feed manuscript Fig. 1/2 (status of each
catchment) and Table 3.

---

## 5. `03_temporal_validation.R` — real evidence of non-stationarity (stage 03)

Three experiments per catchment (only the 222 that passed calibration):

1. **Forward split-sample**: calibrate 1981–1995 → evaluate the retained sets
   on 1996–2010 (no recalibration, `evaluate_sets()`).
2. **Reverse split**: calibrate 1996–2010 → evaluate on 1981–1995.
   **Why both directions**: a differential split-sample in both directions is
   the strongest test for temporal transferability; recording `dKGE` and
   `frac_val_behav` (share of sets still behavioural in validation) quantifies
   degradation. Result: median KGE 0.574 forward / 0.550 reverse; 69.8/65.3 %
   of catchments still have ≥ half their sets behavioural.
3. **Moving windows**: 10-year windows with 5-year stride (1981–1990, …,
   2001–2010) → 5 recalibrations per catchment. For each window the medians of
   the top-20 sets by KGE are stored (`top_medians()`; a strict behavioural
   filter would leave short windows empty).
4. `drift_trends.csv` — OLS slope of each parameter vs window midpoint,
   expressed as **drift over the record as a % of the parameter's physical
   range** (so drift is comparable across parameters with different units).

Outputs: `split_sample.csv`, `parameter_windows.csv`, `drift_trends.csv`,
table `T4_split_sample_summary.csv`; figures `F2` (split-sample scatter) and
`F3` (drift ribbons by KG class).

---

## 6. `04_kg_transitions.R` — Köppen–Geiger classes (stage 04)

Per catchment:

1. **Baseline class** from the 1981–2010 climatology (`kg_class()`,
   Beck et al. 2023 scheme) → `kg_baseline.csv` (with lat/lon — every KG map
   figure merges against this file).
2. **Observed decadal classes** for 1981–1990, 1991–2000, 2001–2010, each
   classified independently from its own 10-year climatology.
   **Why**: this is *observed* evidence of zone change (20.7 % of catchments
   changed class at least once), separate from the synthetic scenarios.
3. **Annual classes** (supplementary).
4. **Scenario matrix**: the 11 × 11 grid (`kg_scenario_matrix()`) →
   `kg_scenario_long.csv`, one row per (catchment, dp, dt). This is what stage
   07 reads to decide "which class does this scenario move the catchment into?"
5. **Delta-change map block**: for each of the 12 `KG_MAP_LEVELS` combinations
   (ΔP × {0.5,1,1.5} × ΔT × {+1.5,+2,+3,+4}) classify the perturbed climatology
   → `kg_map_levels.csv`; per-level counts → `kg_map_summary.csv` /
   `T5b_kg_map_transitions.csv` (16–58 % class change across panels).
6. **Transition summaries**: observed transitions
   (`observed_transitions.csv`), scenario transitions
   (`kg_transition_summary.csv` — `frac_changed` = share of the 121 scenarios
   that leave the baseline class; 91.9 % of catchments have ≥ 1), and the
   manuscript table `T5_kg_transition_summary.csv`.

**Important framing** (matches the manuscript): the future classes are a
**controlled delta-change experiment using the Beck class scheme**, not CMIP6
projections and not a comparison with Beck's gridded maps. The text and figure
captions must not call them "projected".

---

## 7. `05_parameter_controls.R` — climate vs physiography (stage 05)

Question (Reviewer #2 major 1): is the parameter signal climatic or
physiographic?

Analysis table: behavioural parameter medians (`med_*` from `summary.csv`)
merged with the baseline KG class, Caravan climate attributes
(aridity, p_mean, pet_mean, frac_snow, seasonality, moisture_index) and
HydroATLAS physiography (log area, elevation, slope, forest, soil water
capacity, soil carbon/texture, karst, groundwater depth). Predictors with
> 20 % missing or zero variance are dropped; complete cases only.

1. **Variance partitioning** (`vegan::varpart`, adjusted R²) between the
   climate block and the physiography block, per parameter: climate-unique,
   physio-unique, shared, unexplained. Negative unique fractions are clamped
   at 0 (a `varpart` artefact) and the unexplained share is reported, so
   Table 6 shares are honest about not summing to 100 %.
2. **Nested models**: does adding KG zone as a factor improve a model that
   already contains climate + physiography? (`anova(m0, m1)`; ΔR² and F-test
   p-value per parameter.) This justifies the class-based pooling in stage 06.
3. **Random forest** (500 trees, `%IncMSE`) for a non-linear, interaction-aware
   importance ranking per parameter.

Outputs: `varpart.csv`, `nested_models.csv`, `rf_importance.csv`,
table `T6_climate_vs_physiography.csv`; figures `F6`, `F7`.

---

## 8. `06_pool_resample.R` — climate-zone parameter pools (stage 06)

1. All behavioural sets from stage 02 are grouped by the catchment's **baseline
   KG class** → `<class>_pool.csv`. Pools with < 20 sets are dropped (only
   classes with support are used: BSk, Cfa, Cfb, Dfa, Dfb, Dfc).
2. `pool_summary.csv` — pool sizes and parameter medians per class (input to
   figure `F13` and to the Methods text on pool sizes).
3. **Diagnostics** (`resample_diagnostics.csv`): draw 1000 copula samples per
   pool and check (i) zero out-of-bounds values, (ii) max |ΔSpearman
   correlation| vs the pool, (iii) how many parameters fail a KS test at 5 %.
   **Why**: this is the audit trail that the resampler preserves the pool's
   distribution — the evidence that replaced the broken KDE.
4. `pools.rds` — the object stage 07 and figure F13 read.

---

## 9. `07_scenarios.R` — SPF vs CZIPEF over 121 scenarios (stage 07)

The heart of the paper. Per catchment:

1. **Ensemble draw**: a *random* 50 (`N_ENSEMBLE`) of the ≤ 200 behavioural
   sets (seeded by `hash_seed(id+"ensemble")`).
   **Why random, not top-50**: the ensemble should represent the behavioural
   space, not just the best fits.
2. **Baseline reference**: run the **full retained pool** (`base_all`) on the
   historical forcing and take per-indicator medians (`base_med`).
   **Why not the 50-set subsample**: the vulnerability class of each scenario
   is defined relative to this median; using the full pool makes the class
   definition insensitive to which 50 sets were drawn. MAR must have a
   positive baseline (a relative change needs a denominator); LFI = 0 in
   ephemeral catchments → that indicator is NA there, not the whole catchment.
3. **Resample cache**: for every *target* KG class that appears in this
   catchment's scenario matrix (and differs from the baseline class, with pool
   support), draw one 50-member ensemble from that class's pool, seeded by
   `hash_seed(id+class)`. **Why cached**: one ensemble per class per catchment,
   reused across the scenarios that share the target class.
4. **Scenario loop** (11 dp × 11 dt = 121 cells): perturb forcing
   (`P × dp`; `T + dt` applied to Tmin/Tmax because PET is recomputed with
   Hargreaves from Tmin/Tmax), then:
   - **SPF**: run the historical 50 sets under the perturbed forcing.
   - **CZIPEF**: if the scenario's target class differs from the baseline and
     has pool support, run the *class-pool* ensemble instead; otherwise reuse
     the SPF result and flag the cell as **fallback** (`param_source` records
     `pool:<class>` vs `baseline`).
5. **Per cell** (`one()`): for each indicator, relative change of every
   ensemble member vs `base_med`, classified with `vuln_class_matrix()`; then
   store the ensemble median/quantiles of each indicator and
   **`p3_<ind>` = fraction of the ensemble in class 3** (the most vulnerable
   class).
   **Why per-set classification**: the old Step07 matched historical and
   resampled rows by position, which is meaningless after resampling; the
   relative change per set against a fixed baseline median is well-defined.
6. Write `cells/<id>.csv`; combine into `cells_all.csv`;
   `fallback.csv` = fallback fraction per catchment (CZIPEF rows).

**Cost note**: 121 cells × 2 frameworks × 222 catchments × 50 sets ≈ 2.7 M
HBV runs — stage 07 took 786 min in production.

`cells_all.csv` is **the** input for the prevalence surfaces (Fig. 9) and the
thresholds (stage 08).

---

## 10. `08_thresholds.R` — the thresholds (stage 08) — **how ΔP/ΔT thresholds are computed without a CART tree**

This is the answer to your question. The old pipeline grew a **CART tree per
catchment** (classification tree of vulnerability class vs dp/dt) and then
*parsed the printed tree text* to extract the split values. That was fragile
and wrong in three ways: parsing by column position, hard-coded split signs,
and misaligned node weights. It was **demoted to a cross-check** and replaced
by two transparent estimators. There is no CART tree in the figures because
none is produced any more — only the cross-check statistics.

### 10.1 The prevalence curve
For one catchment, framework and indicator, `vuln_prevalence()` (in
`01_functions.R`) turns `cells_all.csv` into the 121-cell summary:

- rows = scenario cells (dp, dt)
- `p3` = fraction of the 50-member ensemble in **class 3** (the stored
  `p3_<ind>` column), `n` = ensemble size.

So the "data" for thresholding is P(class 3 | dp, dt) — the **probability that
the indicator exceeds the 50 % change (extreme vulnerability) under that
climate change**.

### 10.2 Estimator 1 — isotonic crossing (`threshold_isotonic`)
- **ΔP threshold**: average `p3` over all dt at each dp (11 points), find where
  this prevalence curve crosses **0.5** by linear interpolation
  (`.crossing()`). The crossing level 0.5 is the definition: *the ΔP at which
  the catchment is more likely than not in the extreme vulnerability class.*
  The curve may be increasing **or** decreasing — `.crossing()` finds the first
  sign change either way, so the direction of the response is learned, not
  hard-coded.
- **ΔT threshold**: same thing averaged over dp (the manuscript quotes the
  ΔT threshold at the reference warming levels; the isotonic version uses the
  dp-averaged curve).
- **Why isotonic**: it is a monotone, non-parametric smoother of the
  prevalence curve — it smooths Monte-Carlo noise in `p3` without imposing a
  functional form, and the crossing point is then read off directly.

### 10.3 Estimator 2 — logistic prevalence model (`threshold_logistic`)
A binomial GLM on the cell counts: `cbind(k, n−k) ~ dp * dt` where
`k = round(p3 * n)` is the class-3 count per cell. From the coefficients:

- `p_thr = −b0/b1` (dp at which P(class 3) = 0.5 when dt = 0)
- `dt_thr = −(b0 + b1)/(b3 + b4)` (dt at the crossing when dp = 1)
- extrapolation guard: thresholds more than 0.3 beyond the dp range or 2 °C
  beyond the dt range are set NA.
- **Why logistic**: a parametric complement to the isotonic estimate; if both
  agree the threshold is robust, if they diverge the catchment's prevalence
  surface is non-monotone. (`thresholds.csv` stores both; tables and figures
  use the isotonic values `p_thr_iso`, with the logistic kept for comparison.)

### 10.4 Uncertainty — binomial bootstrap (`threshold_boot_cells`)
B = 300 replicates: for each cell draw `k ~ Binomial(n, p3)`, rebuild the
prevalence curve, re-estimate the isotonic crossing; report the 5 %/95 %
percentiles (`p_lo, p_hi, dt_lo, dt_hi`).
**Why binomial resampling of the cell summary**: statistically equivalent for
the prevalence curve to resampling whole parameter sets, but 300× cheaper and
it does not require storing every per-set scenario result
(`SAVE_SCENARIO_SETS = FALSE`).

### 10.5 Per-catchment table (`thresholds.csv`)
For every catchment × framework (SPF, CZIPEF) × indicator (mar, lfi, mamf):
`p_thr_iso, dt_thr_iso, p_thr_logit, dt_thr_logit` + bootstrap intervals +
`n_cells_used` + `fallback_frac` + an `identifiable` flag
(`is.finite(p_thr)`).

Two details worth knowing when you edit the text:
- **Paired cells only**: the CZIPEF threshold is computed on the scenarios
  where CZIPEF had pool support (the same subset for SPF), so fallback cells
  don't dilute the CZIPEF signal; this mirrors the old exclusion of unsupported
  climate classes.
- **n_cells < 20 → skipped** (not enough supported scenarios to threshold).

### 10.6 The SPF–CZIPEF comparison (`comparison.csv`, `decomposition.csv`)
Paired per catchment × indicator: `d_p = p_thr_iso_czip − p_thr_iso_spf`
(negative = CZIPEF makes the catchment vulnerable with *less* drying).
`decomposition.csv` / **Table 8** counts higher/lower/equal, tests with a
binomial test (two-sided, p = 0.5) and a Wilcoxon signed-rank test, and fits
the regression `p_czip ~ p_spf` (slope, intercept, R²). Two subsets: `all` and
`fallback_le_10pct`. **Production numbers (MAR):** n = 217, 83 higher / 74
lower / 60 equal (38.2/34.1/27.6 %), median d_p = 0, binomial p = 0.52, slope
0.309, R² = 0.14. **This is the paper's headline result: on average the two
frameworks give nearly the same median ΔP threshold (medians 0.752 vs 0.741,
Table 7), but the per-catchment spread is large — which is exactly the
non-stationarity signal the paper discusses.**
If an indicator has no paired data, the row is kept with `n = 0` instead of
being hidden (so the manuscript can *state* the non-identifiability).

### 10.7 Identifiability (`T7_threshold_identifiability.csv`, figure F12)
How often a threshold exists at all, by indicator × framework:
- MAR: ΔP threshold in **100 % (SPF) / 97.7 % (CZIPEF)** of catchments; ΔT only
  6.8/2.3 % (the prevalence curve rarely crosses 0.5 in temperature alone
  within −2…+8 °C).
- LFI: ΔP 25.7/23.9 %; MAMF: 9.9/11.7 %.
**Why this table exists**: LFI/MAMF thresholds are often non-identifiable — a
property of the indicator and the scenario grid, not a bug. Table 7 reports
`n` and `pct_identifiable` explicitly and the median ΔP/ΔT thresholds with
IQRs (production medians: MAR SPF 0.752 [IQR 0.707–0.791], CZIPEF 0.741
[0.716–0.779]).

### 10.8 The CART cross-check (bottom of the script)
Only for the primary indicator: if the legacy files
`02-outputs/reference/CART/ORIG/MAR_DP_DT.csv` and
`Step05_BhvPsets_205.RData` exist, the old CART thresholds are compared with
the new isotonic ones (correlation, RMSE, mean bias) →
`thresholds/cart_crosscheck.csv`. **Why**: reviewers asked whether the new
estimator reproduces the old one; the agreement statistic is quoted in the
Methods ("CART is retained only as a cross-check", manuscript Fig. 6 is a
*static* illustration of that old tree, not a pipeline product). If the
reference folder is deleted, stage 08 skips the block automatically.

So, in one sentence: **the precipitation threshold is the ΔP at which the
catchment's probability of extreme vulnerability (> 50 % loss in MAR, class 3)
crosses 50 %, estimated from the monotone (isotonic) prevalence curve over the
121-cell scenario grid, with a binomial-bootstrap 90 % interval and a logistic
GLM as a parametric check.**

---

## 11. `09_sensitivity.R` — sensitivity vs uncertainty (stage 09)

Reviewer #2 major 7 asked to separate the two concepts, and the script does:

- **Sensitivity** (how the output responds to a parameter):
  - **PRCC** with `N_PRCC = 2000` LHS samples, 300 bootstrap replicates.
  - **Sobol** first- and total-order indices with the Saltelli design
    (`SOBOL_N = 512`, scheme A).
  - Responses = `mean_flow`, `peak_flow` (q95), **MAR, LFI, MAMF** — the same
    three indicators as the threshold analysis (the old script only used
    mean/peak flow).
  - Run on **one representative catchment per KG class** (median aridity
    within BSk, Cfa, Cfb, Dfa, Dfb, Dfc) — 6 catchments. The manuscript
    states this limitation (Table 9 is a class-level summary).
- **Uncertainty** (spread across the behavioural ensemble because parameters
  are non-identifiable): for the representative catchment, run all retained
  sets and record per-metric median, q05, q95 and **CV**.
  Production: MAR CV 5–11 % vs LFI 50–228 % — the reason LFI/MAMF thresholds
  are hard to identify.

Outputs: `prcc_<id>.csv`, `sobol_<id>.csv`, `uncertainty_<id>.csv` →
`uncertainty.csv`; table `T9_sensitivity_summary.csv` (parameters with
|estimate| ≥ 0.2 and CI excluding 0, per class × metric).

---

## 12. `10_figures.R` — every figure, what feeds it, and how to modify it

All figures are ggplot2 with a shared `theme_pub()` (theme_classic, light
grid, bold title) and are saved as **PDF + PNG (300 dpi)** by `save_fig(p,
name, w, h)` into `02-outputs/revision/figures/`. Every figure has explicit
axis labels with units (reviewer minor 6). US state outlines come from
`map_base()`.

To change any figure: edit its block in `10_figures.R`, then run
`TSFT_STAGES=10 Rscript 01-analysis/R/run_all.R` (fast, < 1 min) and copy the
new PNG into the docx (the LaTeX build pulls the files itself). Figure size
changes = the `w, h` arguments of `save_fig()`; colour changes = the
`scale_colour_*`/`scale_fill_*` calls; the data file read at the top of each
block is listed below.

**Manuscript mapping** (from `Manuscript-Edit-List.md`):

| Manuscript Fig. | File | Content |
|---|---|---|
| 1 | `FA_analysed_catchments` | analysed catchments |
| 2 | `FB_selection_map` | 332 candidates vs 222 analysed |
| 3–5 | docx images | static workflow diagrams (not pipeline products) |
| 6 | docx image | CART cross-check illustration (static; the pipeline only computes the comparison statistics) |
| 7 | docx image | KG–parameter framework flowchart (static) |
| 8 | `F4b_kg_delta_change_map` | 12-panel delta-change KG map |
| 9 | `F14_prevalence_surface` | P(class 3) surface, catchment 06614800 |
| 10 | `F8b_threshold_map` | SPF vs CZIPEF ΔP threshold maps (MAR) |
| 11 | `F8_threshold_scatter` | SPF vs CZIPEF scatter (n = 217) |
| 12 | `F9_threshold_difference_map` | direction of the threshold difference |
| 13 | `F13_parameter_cdf` | parameter CDFs by KG class |
| 14 | `F10_sensitivity` | PRCC/Sobol for MAR |

S1–S10 (supplementary, appended in LaTeX): F1, F2, F3, F4, F5, F6, F7, F10b,
F11, F12.

Block-by-block:

- **FA / FB (Figs 1–2)** — data: `US_Cat_30_1Deg.csv` + `calibration/summary.csv`.
  Points = catchments, size = area, colour = Analysed vs Candidate only.
  The subtitle prints "N of M candidate catchments passed calibration" —
  **this is where 222/332 appears**; if the sample changes, re-run stage 10
  and the caption numbers follow.
- **F1 (S1)** — `calibration/performance.csv`. Overlaid histograms of the
  median behavioural KGE and NSE per catchment, dashed line at 0.5 (the
  acceptance criterion).
- **F2 (S2)** — `validation/split_sample.csv`. Scatter KGE_cal vs KGE_val per
  direction (forward/reverse), 1:1 line, dotted line at KGE 0.5.
- **F3 (S3)** — `validation/parameter_windows.csv` merged with
  `kg/kg_baseline.csv`. Mean ± SE of 5 selected parameters (FC, beta, CFMAX,
  SFCF, k1) per window midpoint, coloured by KG class. **To show different
  parameters, edit the `pars <- c(...)` vector.**
- **F4 (S4)** — `kg/kg_baseline.csv`, points coloured by class with the
  **official Beck palette** (`kg_palette()`).
- **F4b (Fig. 8)** — `kg/kg_map_levels.csv`. 12 panels faceted
  `dp_lab ~ dt_lab` (ΔP rows × ΔT columns), Beck palette, point size 1.4.
  Panel labels are built in the block ("dP = −50 % (drier)" etc.).
- **F5 (S5)** — `kg/kg_transition_summary.csv`. Fraction of the 121 scenarios
  leaving the baseline class, viridis percent scale.
- **F14 (Fig. 9)** — `scenarios/cells_all.csv`, filtered to one example
  catchment (`camels_06614800`). Two panels (SPF/CZIPEF), `geom_tile` of
  `p3_mar` (fill = P(class C3), viridis, limits 0–1) plus a **white contour at
  0.5 — the threshold surface itself**. This figure exists to *show the
  reader* how a threshold emerges from the prevalence surface; to feature a
  different catchment, change the `gauge_id ==` filter and the subtitle.
- **F6 (S6)** — `attribution/varpart.csv`. Stacked bars per parameter:
  climate-unique / physio-unique / shared / unexplained.
- **F7 (S7)** — `attribution/rf_importance.csv`. Heatmap parameter × predictor,
  `%IncMSE`.
- **F8 (Fig. 11)** — `thresholds/comparison.csv` (finite `d_p` rows only).
  Scatter SPF vs CZIPEF ΔP threshold, 1:1 red dashed line, blue OLS line,
  faceted by indicator panel ("MAR (primary)", "LFI (…)", "MAMF (…)").
  **Facet labels come from `ind_panel()` + `INDICATOR_META`; the n per panel
  should match Table 8.**
- **F9 (Fig. 12)** — `comparison.csv` + baseline KG coordinates. Map of the
  *direction* of `d_p` (CZIPEF higher / lower / no change, ±0.005 tolerance),
  one panel per indicator.
- **F8b (Fig. 10)** — `comparison.csv` (MAR only) + KG coordinates, reshaped
  long: two map panels (SPF, CZIPEF) coloured by `p_threshold` (viridis,
  fixed limits 0.4–1.0 — **the shared colour limits are what makes the two
  panels comparable; keep them if you restyle**).
- **F10 (Fig. 14)** — `sensitivity/prcc_*.csv` + `sobol_*.csv`, MAR only.
  Dot plot of sensitivity index per parameter, dodged by method
  (PRCC / Sobol first / Sobol total), faceted by KG class.
- **F10b (S8)** — the same for LFI and MAMF (`facet_grid(metric ~ kg_class)`).
- **F11 (S9)** — `sensitivity/uncertainty.csv`. Boxplots of ensemble CV per KG
  class, filled by indicator; CV winsorised at 2 for display.
- **F13 (Fig. 13)** — `pools/pools.rds`. ECDFs of every parameter, coloured by
  KG class, free x scales, 4 columns.
- **F12 (S10)** — `tables/T7_threshold_identifiability.csv`. Bar chart, %
  catchments with an identifiable ΔP / ΔT threshold, grouped by framework —
  the figure that justifies reporting LFI/MAMF alongside MAR.

---

## 13. Tables → docx

`02-outputs/revision/tables/` (written by stages 02–09):

| File | Manuscript | Contents |
|------|-----------|----------|
| `T3_calibration_summary.csv` | Table 3 | calibration report (222 catchments etc.) |
| `T4_split_sample_summary.csv` | Table 4 | split-sample medians, % still behavioural |
| `T5_kg_transition_summary.csv` | Table 5 | observed + scenario KG transitions |
| `T5b_kg_map_transitions.csv` | Table 5b | % class change per (ΔP, ΔT) map panel |
| `T6_climate_vs_physiography.csv` | Table 6 | varpart % + KG-zone ΔR²/p |
| `T7_threshold_comparison.csv` | Table 7 | thresholds per indicator × framework with n, % identifiable, IQR |
| `T7_threshold_identifiability.csv` | (feeds F12) | % identifiable by threshold type |
| `T8_threshold_decomposition.csv` | Table 8 | higher/lower/equal + binomial/Wilcoxon + regression |
| `T9_sensitivity_summary.csv` | Table 9 | significant PRCC parameters per class × metric |

`03-writeup/Revision-1/Tables-R1.docx` holds the formatted Tables 3–9
(landscape, 7.5 pt); T8 is transposed there to fit the page.

## 14. Known limitations stated in the text (keep these when editing)

- Six catchments (one per class) carry the sensitivity analysis (Table 9).
- LFI/MAMF thresholds identifiable in only 10–26 % of catchments; the headline
  claim rests on MAR.
- KG pools capture only part of the parameter variation.
- `varpart` unique fractions clamped at 0 → Table 6 shares don't sum to 100 %.
- The delta-change KG map is a controlled experiment, not a projection.

## 15. Quick recipes

```powershell
# Redraw all figures after editing 10_figures.R
$env:TSFT_STAGES="10"; Rscript 01-analysis/R/run_all.R

# Rebuild only the thresholds (after touching cells_all.csv or the estimators)
$env:TSFT_STAGES="08"; Rscript 01-analysis/R/run_all.R

# Smoke test on 10 catchments into a scratch folder
$env:TSFT_NCATCH="10"; $env:TSFT_REV_DIR="D:/Research/202505_Non_Stationarity_KG/02-outputs/smoke"
Rscript 01-analysis/R/run_all.R

# Full pipeline (resumes from disk; cheap when outputs exist)
Rscript 01-analysis/R/run_all.R
```

LaTeX build: `03-writeup/Revision-1/latex-v2/` (pdflatex + bibtex on
`manuscript.tex` → `manuscript.pdf`, 50 pages; build commands in
`latex-v2/README.md`; the old pandoc `latex/` build was removed on 27 Nov 2026).
