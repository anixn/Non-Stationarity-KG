# CZIPEF revision pipeline

Clean, reproducible replacement for the old `Step01`–`Step09` R Markdown chain.
The old chain has been removed; the scripts here are the only analysis code used
for the resubmission.

## Quick start

```r
# from the project root
source("01-analysis/R/00_config.R")
source("01-analysis/R/01_functions.R")
```

or run the whole pipeline:

```powershell
Rscript 01-analysis/R/run_all.R

# smoke test on 10 catchments
$env:TSFT_NCATCH="10"; Rscript 01-analysis/R/run_all.R

# single stage
$env:TSFT_STAGES="02"; Rscript 01-analysis/R/run_all.R

# a specific list of catchments
$env:TSFT_CATCHMENTS="camels_01013500,camels_02371500"; Rscript 01-analysis/R/run_all.R

# write a smoke test somewhere other than the production folder
$env:TSFT_REV_DIR="D:/Research/202505_Non_Stationarity_KG/02-outputs/smoke"
```

## Stages

| Stage | Script | What it does | Reviewer |
|-------|--------|--------------|----------|
| 02 | `02_calibrate.R` | LHS calibration, behavioural screening, parameter summary | #2.3 |
| 03 | `03_temporal_validation.R` | Forward/reverse split-sample, 10-year moving windows, drift trends | #2.2, #4 |
| 04 | `04_kg_transitions.R` | Baseline, decadal, annual and scenario KG classes; Beck-style delta-change KG maps | #2.4, #2.6 |
| 05 | `05_parameter_controls.R` | Climate vs physiography variance partitioning, nested models, RF | #2.1 |
| 06 | `06_pool_resample.R` | KG pools + bounded correlation-preserving resampling | #2.8 |
| 07 | `07_scenarios.R` | SPF and CZIPEF simulations over 121 scenarios; MAR, LFI, MAMF | #2.2 |
| 08 | `08_thresholds.R` | Isotonic/logistic thresholds, bootstrap CIs, SPF–CZIPEF comparison for all three indicators | #2.6 |
| 09 | `09_sensitivity.R` | PRCC + Sobol (sensitivity) and ensemble spread (uncertainty) for MAR, LFI, MAMF | #2.7 |
| 10 | `10_figures.R` | Publication figures with explicit axes | minor #6 |

## Flow indicators (MAR primary, LFI and MAMF alongside)

| Indicator | Definition | Vulnerability direction | Role |
|-----------|------------|-------------------------|------|
| **MAR** | Mean annual runoff (mm yr⁻¹) | a **decrease** | primary |
| **LFI** | Low-flow index, mean annual minimum / mean annual mean | a **decrease** | supplementary |
| **MAMF** | High-flow ratio, median annual maximum / median annual median | an **increase** (flood intensification) | supplementary |

All three use the same four classes: 0 (no vulnerability), 1 (<25% change),
2 (25–50%), 3 (>50%). The direction is stored once in `INDICATOR_META` and
read by `vuln_class()`; no script hard-codes a sign. The threshold tables
(`T7`, `T8`) and figures (`F8`, `F9`, `F10b`, `F12`) report all three, and
report non-identifiable thresholds explicitly instead of dropping them.

## Köppen–Geiger map logic (Beck et al. 2023)

The baseline and future KG maps are **not** copied from Beck et al.'s gridded
product. They use the same delta-change logic:

1. compute the observed 1981–2010 monthly climatology (P, Tmin, Tmax, Tmean);
2. apply a delta change (P × `dp`, T + `dt`);
3. reclassify with the Beck et al. (2023) class scheme in
   `01-analysis/data/kg_class_all.R`;
4. draw with the official Beck et al. (2023) RGB palette from `KG Classes.csv`.

`KG_MAP_LEVELS` in `00_config.R` holds the four reference warming levels
(+1.5, +2, +3, +4 °C). `dp` is 1.0 by default, so the map isolates the
temperature effect. If catchment-specific CMIP6/Beck precipitation deltas are
available, replace the `dp` column and the map becomes directly comparable
with Beck et al. (2023). Outputs: `kg/kg_map_levels.csv`,
`kg/kg_map_summary.csv`, figures `F4` and `F4b`.

## Result-changing fixes

| Fix | Old behaviour | New behaviour |
|-----|---------------|---------------|
| PET units | Hargreaves without the 0.408 MJ→mm conversion; PET ≈ 2.45× too high | Correct mm/day PET |
| Routing | MATLAB `end` in the routing branch made `routing = 1` fail; MAXBAS was inert | Correct triangular weights; `USE_ROUTING = TRUE` |
| Initial snow | `SP = 152.4` mm for every catchment | `SP = 0` |
| Resampling | Univariate KDE, seed reset per parameter, ~1% out of bounds, MAXBAS fixed at 1 | Gaussian copula with empirical marginals, bounded by construction; KDE kept as a sensitivity check |
| Vulnerability classes | Per-set relative change matched by row position; resampled rows were not comparable | Per-set relative change against the baseline ensemble median; one direction-aware classifier for all three indicators |
| Thresholds | CART printed to a text file, parsed by column position; split signs hard-coded; weights misaligned | Isotonic crossing + logistic prevalence model + binomial bootstrap; direction learned from data; all three indicators |
| SAF | Two different formulas in Step06_a and Step06_b | One formula in `flow_indices()` |
| Dimensions | Step03 dimnames overwrote dimension 1 with gauge IDs | Explicit, correct dimnames |
| Column labels | Step04 saved KGE under the `NSE` header | Correct names |

## Configuration

Everything is in `00_config.R`:

- `PAR_BOUNDS` — the 12 HBV parameters and their bounds (Table 2 of the paper).
- `PERIOD_FULL`, `PERIOD_CAL`, `PERIOD_VAL` — one definition for every stage.
- `BEHAV_KGE`, `BEHAV_NSE`, `BEHAV_PBIAS` — acceptance criteria.
- `N_LHS`, `N_LHS_VALID`, `N_KEEP`, `N_ENSEMBLE` — computational budget.
- `DP`, `DT` — scenario grid.
- `INDICATORS`, `PRIMARY_INDICATOR`, `INDICATOR_META` — the three flow indicators and their vulnerability direction.
- `KG_MAP_LEVELS` — delta-change warming levels for the Beck-style KG map.
- `USE_ROUTING` — enable/disable MAXBAS.
- `N_CORES` — parallelism.
- `TSFT_REV_DIR` — output root override (smoke tests).

## Expected cost

With the defaults (`N_LHS = 10,000`, `N_LHS_VALID = 2,000`,
`N_ENSEMBLE = 50`), 332 candidate catchments (222 analysed) and 8 workers, the
full Revision 1 run took:

| Stage | Measured time |
|-------|---------------|
| 02 calibration | 178 min |
| 03 validation | 89 min |
| 04 KG | 36 min |
| 05 attribution | < 1 min |
| 06 pools | < 1 min |
| 07 scenarios | 786 min |
| 08 thresholds | 11 min |
| 09 sensitivity | 305 min |
| 10 figures | < 1 min |

Stage 07 dominates because it simulates 121 scenarios x 2 frameworks x 222
catchments with 50-member ensembles.

For a first pass use `N_LHS = 2000`, `N_LHS_VALID = 500`, `N_ENSEMBLE = 20`.

## Output layout

```
02-outputs/
├── revision/                 production products (regenerated by run_all.R)
│   ├── calibration/          psets/, summary.csv, performance.csv
│   ├── validation/           split_sample.csv, parameter_windows.csv, drift_trends.csv
│   ├── kg/                   kg_baseline.csv, kg_decadal.csv, kg_annual.csv,
│   │                         kg_scenario_long.csv, kg_transition_summary.csv,
│   │                         kg_map_levels.csv, kg_map_summary.csv
│   ├── attribution/          varpart.csv, nested_models.csv, rf_importance.csv
│   ├── pools/                <class>_pool.csv, pool_summary.csv,
│   │                         resample_diagnostics.csv, pools.rds
│   ├── scenarios/            cells/<id>.csv, cells_all.csv, fallback.csv
│   ├── thresholds/           thresholds.csv, comparison.csv, decomposition.csv
│   ├── sensitivity/          prcc_<id>.csv, sobol_<id>.csv, uncertainty.csv
│   ├── figures/              FA, FB, F1–F14 (PDF + PNG)
│   └── tables/               T3–T9, T5b, T7 identifiability
├── reference/                legacy artefacts read for cross-checks (CART, Step05 RData)
├── legacy/                   superseded outputs kept for provenance
└── smoke/                    small end-to-end test; safe to delete
```

## Decisions stated in the manuscript

1. **Routing is enabled.** MAXBAS is therefore identifiable. If the authors
   prefer to keep the original routing-free runs, set `USE_ROUTING = FALSE` and
   remove MAXBAS from Table 2 and from `PAR_BOUNDS`.
2. **Calibration is on 1981–2010, with 2 years of warm-up.** The split-sample
   experiment uses 1981–1995 and 1996–2010. The text must say 1981, not 1980.
3. **Acceptance is KGE ≥ 0.5 and |PBIAS| ≤ 25%.** NSE is reported but not used
   to screen, because requiring NSE ≥ 0.5 as well discards catchments where HBV
   is structurally limited (e.g. karst or regulated basins).
4. **MAR is the primary indicator; LFI and MAMF are reported alongside it.**
   The direction of vulnerability is explicit: a decrease for MAR and LFI, an
   increase for MAMF.
5. **The KG map is a delta-change product built with the Beck et al. (2023)
   class scheme**, not a copy of their gridded future map. Observed decadal
   reclassification is reported separately.
