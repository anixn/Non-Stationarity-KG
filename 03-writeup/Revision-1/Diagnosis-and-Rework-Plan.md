# Diagnosis, Reviewer Mapping, and Rework Plan
### Manuscript HYDROL72949 — “A Climate Zone-Informed Parameter Evolution Framework (CZIPEF)”
**Prepared for resubmission (Revision 1)**

> **Note (20 Nov 2026).** The bug table below documents the *old* code paths
> (`Step01–Step09`, `data/HBV Model Run/HBV.R`). Those files were removed after
> the new pipeline reproduced the analysis; the table is kept as the audit trail
> for the response to reviewers.

---

## 0. Bottom line

The idea — *use Köppen–Geiger (KG) transitions as a physically interpretable driver of
hydrological-model parameter evolution* — is publishable. The current version fails for a
different reason: **the evidence is circular and the code contains several result-changing
bugs.** The paper demonstrates a framework mostly against itself (synthetic scenarios,
parameters resampled from the same calibration pool), and several claims are not supported by
the numbers in the output folder.

A successful resubmission needs three things:

1. **Empirical proof that parameters are non-stationary** (split-sample / moving-window
   recalibration), not just a scenario exercise.
2. **Proof that climate is not the only control** (physiographic attribution), and a quantified
   statement of how much of the parameter signal is climate vs. catchment attributes.
3. **A transparent, reproducible vulnerability-threshold estimator** with uncertainty, plus
   honest, internally consistent claims.

The R pipeline has been rebuilt in `01-analysis/R/`. The old `.Rmd` files are left untouched
for provenance; the new scripts supersede them.

---

## 1. Reviewer comment → what it means → what to do

### Reviewer #2 — major

| # | Comment | What the reviewer is really saying | Rework |
|---|---------|-----------------------------------|--------|
| 1 | Parameters depend on geophysical characteristics, not only climate | Your central causal claim is incomplete. Show the relative role of climate vs physiography, or your framework is mis-specified. | `05_parameter_controls.R`: merge Caravan climatic + HydroATLAS physiographic attributes; variance partitioning (climate / physiography / shared) per parameter; mixed models with KG zone + slope + area + soil; random-forest importance. New Fig. “Climate vs physiography”. |
| 2 | Real-world validation is missing; framework demonstrated only through modelling experiments | You never show a parameter actually changing in observations. The KG transition is manufactured by your delta-change scenarios. | `03_temporal_validation.R`: differential split-sample test (calibrate 1981–1995 → validate 1996–2010 and reverse); 10-year moving-window recalibration; parameter-drift plots; performance-degradation table. `04_kg_transitions.R`: observed decadal KG classes and actual transitions. |
| 3 | Unclear whether HBV was calibrated per catchment; report calibration procedure and metrics | Calibration is the foundation and is currently invisible and weak (median top-50 KGE ≈ 0.46). | `02_calibrate.R`: explicit LHS design, warm-up, objective, acceptance thresholds, per-catchment metrics; report KGE/NSE/PBIAS distributions and % accepted. New Table 3 + Fig. 5. |
| 4 | Criteria for detecting climate-zone change are not described/justified | You never state the KG algorithm, the period, or the delta-change logic, and the baseline class is not validated against Beck et al. (2023). | `04_kg_transitions.R`: full KG criteria (monthly T/P thresholds, A/B/C/D/E logic), baseline 1981–2010, decadal reclassification, scenario matrix, transition counts, and a Beck-style delta-change map at +1.5/+2/+3/+4 °C using the official Beck class scheme and palette. New Methods §3.5; Figs. 4, 4b, 5. |
| 5 | Methodology poorly organised | The reader cannot tell calibration, pooling, resampling, simulation, and threshold extraction apart. | New Methods structure: 3.1 design, 3.2 HBV + calibration, 3.3 behavioural sets, 3.4 scenarios + KG, 3.5 pooling + resampling, 3.6 indicators + vulnerability, 3.7 threshold estimation, 3.8 sensitivity. Mirror this in the scripts. |
| 6 | “Vulnerability significantly underestimated” — how? Did KG changes actually occur? | This is the weakest claim. The data show 36% lower and 20% higher thresholds; “underestimated” is directionally wrong for the majority, and no significance test exists. | Replace the claim with the actual decomposition (41 higher / 75 lower / 89 unchanged). Add observed decadal transitions. Add a limitations paragraph. `08_thresholds.R` produces the decomposition with bootstrap CIs and a binomial test. |
| 7 | How was “uncertainty” quantified? Uncertainty ≠ sensitivity. | You call KDE resampling “uncertainty propagation” but never quantify uncertainty, and then call PRCC/Sobol “uncertainty”. | `09_sensitivity.R`: sensitivity = PRCC + Sobol (with CIs); uncertainty = spread of indicators across the behavioural ensemble (5–95% range, CV, variance decomposition). New subsection 3.8 and Table 5. Remove “uncertainty” where you mean sensitivity. |
| 8 | KDE — simplify and say why | The KDE is described at textbook length, is univariate (destroys parameter correlations), produces out-of-bounds values, and uses a reset seed per parameter. | `06_pool_resample.R`: replace with a bounded, correlation-preserving Gaussian-copula resampler (empirical marginals + latent correlation), with optional behavioural re-screening. Keep KDE only as a sensitivity check. Two sentences in Methods. |

### Reviewer #2 — minor

| # | Comment | Fix |
|---|---------|-----|
| 1 | “model parameters” vs “behavioural parameters” | Use **model parameters** for the 12 HBV parameters; **behavioural parameter sets** only for accepted sets. Global terminology pass. |
| 2 | L53–56 P9 unclear | Rewrite the bottom-up/top-down paragraph (currently repeats itself). |
| 3 | “Fifty parameters?” | Always “fifty behavioural parameter sets per catchment”. Define in Methods. |
| 4 | What is Eq. 6 for? | Eq. 6 becomes optional (KDE sensitivity check) or is removed; if kept, state it is the density estimator used to resample parameters. |
| 5 | Some figures/flowcharts unnecessary | Remove Fig. 3 and Fig. 5 (generic workflow), keep Fig. 4 (HBV), replace Fig. 7 with a compact 4-box schematic. |
| 6 | Fig. 13 axes unlabeled | All figures rebuilt with explicit axis labels, units, and colour legends. |

### Reviewer #4 — “not suitable” + validation note
The note “catchment parameters update with 30 years of data” points to exactly the missing
experiment: recalibrate with time. This is implemented as the moving-window analysis in
`03_temporal_validation.R`. Reviewer #4’s rejection is best answered by adding real temporal
evidence and toning the “new paradigm” language down to “a first step”.

---

## 2. Mistakes found in the current R pipeline

### 2.1 Result-changing code bugs (verified against the files in `02-outputs/`)

| # | Where | Bug | Consequence |
|---|-------|-----|-------------|
| 1 | `Step02/04/06*` `hargreaves_pet()` | Missing the **0.408** MJ m⁻² d⁻¹ → mm d⁻¹ conversion. Hargreaves–Samani requires Ra in mm/day. | PET is **≈2.45× too high** (verified: 8.20 vs 3.35 mm/d for USGS 02371500). Calibration compensates through biased parameters; temperature sensitivity is distorted. |
| 2 | `data/HBV Model Run/HBV.R` | Routing branch uses MATLAB `end` (`MAXBAS_w[2:end]`) and a malformed `I` index; it errors if `routing = 1`. | `routing = 0` is used everywhere, so **MAXBAS is an inert parameter** and the routing parameter in Table 2 does nothing. |
| 3 | `HBV.R` | `SP <- 152.4` initial snowpack for every catchment. | Warm catchments start with 152 mm of snow; 10% warm-up is the only safeguard. Should be 0. |
| 4 | `Step05` `compute_kde()` | `set.seed(123)` **inside** a function called once per parameter → identical random stream for FC, beta, LP, … | Induces artificial cross-parameter dependence; not a valid multivariate sample. |
| 5 | `Step05/06_b` KDE | Univariate KDE per parameter, no truncation, `MAXBAS <- 1` forced. | **~1% of samples fall outside the physical bounds** (up to 4.5% for some parameters); parameter correlations destroyed; MAXBAS fixed at its lower bound. |
| 6 | `Step03` | `dimnames(mapped_Class)[1] <- dimnames(Class)[1] <- ...` repeated for dims 2 and 3. | Dimension 1 (Δt) ends up labelled with **gauge IDs**; all downstream dimnames are wrong. |
| 7 | `Step04` | `pars[,13] <- KGE`, `pars[,14] <- NSE` but columns are named `NSE`, `KGE`. | Saved CSV columns are **swapped**. |
| 8 | `Step06_b` | `SAF <- (mean/median)/median` vs `Step06_a` `(mean−median)/median`. | SAF differs between SPF and CZIPEF files (it is dropped later, but the pipeline is inconsistent). |
| 9 | `Step08` | LFI and MAMF loops assign to `mar_thr`; MAMF-ORIG loops `54:205`; split signs hard-coded. | Misleading variable names; 53 missing ORIG MAMF values; LFI has **121/205 missing** dp thresholds, MAMF 87–141 missing. |
| 10 | `Step08` `comp_vul_thershold()` | `th_val[k]` is assigned conditionally but `th_n[k]` always; then `th_n <- th_n[seq_along(th_val)]`. | **Weights are misaligned** with thresholds, so the weighted average is wrong whenever a class-3 leaf has no split on the target variable. |
| 11 | `Step08` `tree_data_comp()` | Parses `capture.output(rpart)` text with fixed token positions (columns 1:5 and 10); shared `temp.txt`. | Fragile to rpart formatting; not parallel-safe. rpart objects should be used directly. |
| 12 | `Step06_c` | Never runs the model; writes only parameters. | The “parameter-only” run is dead code. |
| 13 | `Step09` | `for (cat_val in 1:205)`, `cbind` of unequal vectors, writes to directories that may not exist. | Not reproducible on a different catchment count. |
| 14 | `Sensitivity_HBV_V2` | Uses raw Caravan PET (not the Hargreaves PET used in the main run), no warm-up, and misreads PRCC CI columns (Lower = 0.009, Upper = −0.847). | Sensitivity results are not comparable to the main analysis and some intervals are reversed. |

### 2.2 Scientific / design mistakes

1. **Circular validation.** The “non-stationary” parameter sets are drawn from pools that were
   calibrated under the *historical* climate. They are never shown to be behavioural under the
   perturbed climate. The comparison therefore measures the difference between two parameter
   distributions, not a validated parameter evolution.
2. **No temporal calibration/validation.** Every catchment is calibrated and evaluated on the
   same 1981–2010 record (only a 10% warm-up is removed). There is no split-sample, no
   differential split-sample, no moving window.
3. **Climate-only attribution.** Pooling by KG zone mixes climate with physiography, land
   cover, soil, and geology. The CDF differences in Fig. 13 can be produced by physiography
   alone. Reviewer #1 is correct.
4. **“Uncertainty” is never quantified.** KDE is a resampling device, not an uncertainty
   analysis. PRCC/Sobol measure sensitivity.
5. **CART threshold is not a physical threshold.** For MAR, class 3 is almost a deterministic
   function of ΔP; the tree mostly recovers a ΔP split. The ΔT threshold is often not
   identifiable (verified: for USGS 01013500, class 3 never occurs at ΔP = 1 for any ΔT, so a
   ΔT threshold cannot exist). The weighted-average extraction adds noise.
6. **KG transitions are scenario artefacts.** No observed decadal transition is reported, and
   the baseline class is not compared with Beck et al. (2023). “No catchment preserved its
   historical zone across all 121 scenarios” is trivially true because the scenario space
   includes extreme drying.
7. **Claims do not match the numbers.**
   - 205 catchments analysed, but the text says 304 selected.
   - 6 pooled classes exist (`BSk, Cfa, Cfb, Dfa, Dfb, Dfc`), but the text lists 8.
   - “56% show significant changes” is actually 56.6% showing *any* difference (89 unchanged);
     no significance test was performed.
   - “Vulnerability is significantly underestimated” is directionally wrong for the majority:
     36.6% have a *lower* CZIPEF threshold (less vulnerable), 20% higher.
   - Calibration acceptance is described as NSE, KGE > 0 and |PBIAS| < 25, but the code uses
     **0.25**; the TT bound is −1.5 in code and −2.5 in the table; the period is 1981–2010 in
     code and 1980–2010 in text.

---

## 3. The revised evidence chain

```
Observed daily P, T, Q (CAMELS/Caravan)
        │
        ├── (A) Temporal validation  ──►  Is the parameter non-stationary?      [02, 03]
        │       split-sample + moving window + differential split-sample
        │
        ├── (B) KG transitions       ──►  Did climate zones actually change?    [04]
        │       decadal observed classes + scenario matrix + Beck comparison
        │
        ├── (C) Attribution          ──►  Climate or physiography?              [05]
        │       variance partitioning + mixed models + RF
        │
        ├── (D) Resampling           ──►  Are new sets behavioural & bounded?   [06]
        │       copula + truncation + re-screening
        │
        ├── (E) Scenarios            ──►  SPF vs CZIPEF                         [07]
        │
        └── (F) Thresholds           ──►  Transparent, with uncertainty         [08]
                isotonic + logistic + bootstrap; no CART text parsing
```

---

## 4. New script map (`01-analysis/R/`)

| Script | Purpose | Reviewer |
|--------|---------|----------|
| `00_config.R` | Paths, parameter bounds, periods, thresholds, seeds | — |
| `01_functions.R` | HBV (fixed routing), PET (fixed units), metrics, indices, KG, resampling, threshold estimators | — |
| `02_calibrate.R` | LHS calibration + behavioural screening + parameter summary | #2.3 |
| `03_temporal_validation.R` | Split-sample, differential split-sample, moving window, parameter drift | #2.2, #4 |
| `04_kg_transitions.R` | Baseline/decadal/scenario KG classes and transition statistics | #2.4, #2.6 |
| `05_parameter_controls.R` | Climate vs physiography attribution | #2.1 |
| `06_pool_resample.R` | Pooling + bounded correlation-preserving resampling + diagnostics | #2.8 |
| `07_scenarios.R` | SPF/CZIPEF scenario simulation | #2.2 |
| `08_thresholds.R` | Robust vulnerability thresholds + SPF/CZIPEF comparison | #2.6 |
| `09_sensitivity.R` | PRCC/Sobol + parametric uncertainty | #2.7 |
| `10_figures.R` | Publication figures with explicit axes | minor #6 |
| `run_all.R` | Stage orchestration | — |

---

## 5. Claim-by-claim corrections for the manuscript

| Current statement | Replace with |
|-------------------|--------------|
| “56% of catchments demonstrate significant changes in vulnerability” | “In 116 of 205 catchments (56.6%) the CZIPEF ΔP threshold differed from SPF; 75 (36.6%) were lower, 41 (20.0%) higher, and 89 (43.4%) identical. A bootstrap test and a binomial test on the direction of change are reported in Table 4.” |
| “Conventional stationarity assumptions systematically overlook vulnerability” | “Stationarity assumptions do not bias vulnerability in a single direction: they overestimate vulnerability in 36.6% of catchments and underestimate it in 20.0%.” |
| “New paradigm / new standard” | “A first step toward climate-zone-informed parameter evolution.” |
| “304 catchments” | “205 catchments met the calibration and climate-zone criteria (from 332 grid-selected and 671 initial).” |
| “BSh, BSk, Cfa, Cfb, Cfc, Dfa, Dfb, Dfc” | “BSk, Cfa, Cfb, Dfa, Dfb, Dfc (6 classes).” |
| “Parameters are functions of climate” | “Climate explains X% of parameter variance; physiography explains Y%; Z% is shared (Fig. 15).” |
| “KDE propagates uncertainty” | “A bounded copula resampler generates parameter sets from the climate-zone pool; sensitivity is quantified separately with PRCC/Sobol.” |
| “56% of catchments show a changed threshold” (assumed) | Report the actual number from the revised estimator. The new comparison uses only scenarios with pool support and excludes fallback cells from both frameworks; the effect may be smaller than the old 56%, which included fallback scenarios and matched resampled rows by position. Do not force the old number. |

---

## 6. Decisions taken (19 November 2026)

1. **Re-run the full calibration.** The PET and routing fixes change the
   calibration, so the production run is required. This is the only way
   calibration metrics and all downstream thresholds become defensible.
2. **Keep all three indicators, with MAR primary.** LFI and MAMF are computed,
   thresholded and reported alongside MAR with an explicit vulnerability
   direction. Non-identifiable thresholds are reported, not hidden. See
   `Indicator-and-KG-Map-Decisions.md`.
3. **Keep routing.** The routing bug is fixed, so MAXBAS is identifiable and
   stays in Table 2.
4. **Beck et al. (2023) is a class scheme and a delta-change logic, not a
   raster comparison.** The KG map applies observed-climatology delta changes
   and reclassifies with the Beck scheme; catchment-specific CMIP6 deltas can
   replace the default `dp` values later. See
   `Indicator-and-KG-Map-Decisions.md`.

Remaining work is execution and writing, not methodological choice: run the
205-catchment pipeline, regenerate the figures/tables, and update the
manuscript numbers and Methods.
