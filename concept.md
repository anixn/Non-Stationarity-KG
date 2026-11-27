 [CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md) | [HELP](./help.md) | [STATUS](./PROJECT_STATUS.md)

# Research Concept — CZIPEF

Authors: Ankit Deshmukh, Shreekant Varshney
Date: originated May 2025 · last updated 24 November 2026

---

## Core Idea

Catchment model parameters should follow the catchment's **climate**, not its calendar. Understand and quantify catchment **parameter non-stationarity** using the **Köppen–Geiger (KG) climate classification**: when a climate-change scenario moves a catchment into a different KG zone, sample model parameters from the **destination zone's pool of behavioural sets** instead of keeping the historically calibrated ones frozen.

## Hypothesis / Innovation

- **H1:** Parameters calibrated in one KG climate regime differ systematically from those calibrated in another (zone-conditioned pools separate, especially snow and soil parameters).
- **H2:** Replacing stationary parameters with climate-zone-conditioned parameters **changes the estimated vulnerability threshold for most catchments** — and the change is *not* in one consistent direction, so stationarity cannot be treated as a neutral simplification.
- **Innovation:** the first framework that propagates KG zone transitions *through* a hydrological model *into* vulnerability thresholds — closing a three-way gap between (i) transferability studies, (ii) time-varying parameter methods (anchored to time/record, not class), and (iii) the KG-change mapping literature (stops at the climate surface).

## Motivation

- Climate projections propagate uncertainty through the modelling chain; vulnerability thresholds computed from uncertain runoff may misrepresent real conditions.
- Stationarity — the foundation of standard calibration — is increasingly invalid (Milly 2008; Melsen 2021: ~55% of 605 US basins reorganize dominant controls under warming).
- Transferability experiments show calibration–evaluation climate contrast degrades model performance; KG zone boundaries are now projectable to 2099 (Beck et al. 2023) — but no one links the two.

## Research Objectives

1. Build climate-zone-conditioned pools of behavioural HBV parameter sets across 222 CAMELS catchments.
2. Propagate synthetic climate-zone transitions (delta-change + KG reclassification) into parameter resampling via a **Gaussian copula** (empirical marginals + rank correlation, bounded).
3. Estimate precipitation/temperature **vulnerability thresholds** per catchment, framework (SPF vs CZIPEF) and indicator (MAR primary; LFI, MAMF supplementary), with isotonic/logistic estimators, bootstrap intervals and a CART cross-check.
4. Quantify how much (and in which direction) vulnerability estimates change when stationarity is relaxed.
5. Attribute parameter variation to climate vs physiography (variance partitioning + random forest).

## Methodology (final)

Bottom-up exploratory framework: 121-cell scenario grid (ΔP ×0.5–1.5 × ΔT −2/+8 °C) → HBV (10,000 LHS; KGE ≥ 0.5, |PBIAS| ≤ 25%; 200 behavioural sets; ≥ 50-set floor) → indicator classes (0–3) → isotonic + logistic prevalence estimators (threshold = P = 0.5 crossing) → CART independent cross-check → fallback rule when destination class has no pool. See `01-analysis/R/README.md` and the manuscript §3.

## Data / Sources

- CAMELS (671 catchments; 332 candidates via 1° grid; 222 analysed), daily 1981–2010.
- Köppen–Geiger classes: Beck et al. (2023) scheme, used as delta-change logic (not a CMIP6 projection).
- HydroATLAS physiographic attributes (variance partitioning).
- Bibliography: `03-writeup/Revision-1/latex-v2/references.bib` (152 entries, WOS-verified).

## Validation Plan

- Differential split-sample (forward + reverse) and 10-year moving windows (Coron 2012; Dakhlaoui 2019).
- Binomial bootstrap intervals on thresholds; isotonic vs logistic vs CART agreement check.
- Parametric uncertainty (ensemble CV) explaining threshold identifiability.
- Sensitivity: PRCC + Sobol in six representative catchments (one per dominant class).

## Status

Concept fully implemented; manuscript complete (see `PROJECT_STATUS.md`). The headline empirical result: the MAR precipitation threshold changes in 72% of catchments (83 higher / 74 lower / 60 equal of 217), median difference zero, R² = 0.14 — catchment-specific, climatically patterned, not a uniform shift.

## Timeline

- 2025 Q2: concept + CAMELS pilot.
- 2025 Q3–Q4: first submission (Journal of Hydrology, HYDROL72949).
- 2026 Q4: Revision 1 — rebuilt pipeline, prior-art update, latex-v2, submission-ready.

## References

See `references.bib` in the LaTeX build; key anchors: milly2008stationarity, melsen2021climate, coron2012crash, dakhlaoui2019bootstrap, beck2023high, deshmukh2016physio, deshmukhWhittakerBiomeBasedFramework2019.
