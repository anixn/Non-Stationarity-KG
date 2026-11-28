[CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md) | [HELP](./help.md) | [STATUS](./PROJECT_STATUS.md)

# Writing-Session Help — CZIPEF Revision 1

> The one document to keep open while writing or revising the manuscript.
> Working manuscript: `03-writeup/Revision-1/latex-v2/manuscript.tex` → `manuscript.pdf` (50 pp, buildable, zero unresolved citations).
> Every number below is traceable to a pipeline table in `latex-v2/tables/`.

---

## 1. The paper in simple language

### What we did

**The problem.** Hydrological models (here HBV) are calibrated once on past data and their parameters are then assumed valid forever — the *stationarity* assumption. As climate changes, that assumption becomes unrealistic, and vulnerability assessments built on it inherit the error.

**Our idea — CZIPEF.** A catchment's "best" parameters should match its *climate*. So:

1. Calibrate HBV for 222 US catchments (CAMELS).
2. Pool the well-calibrated ("behavioural") parameter sets **by Köppen–Geiger climate zone** — each zone gets its own pool.
3. Stress-test each catchment over a synthetic scenario grid (precipitation ×0.5–1.5, temperature −2 to +8 °C; 121 cells). When a scenario moves a catchment into a **different climate zone**, resample parameters from the **new zone's pool** (Gaussian copula: empirical marginals + rank correlation, bounded by Table 2 ranges) instead of keeping them frozen.
4. Compare against the frozen-parameter approach (**SPF**) and estimate the **vulnerability threshold**: how much rainfall can drop (or temperature rise) before the catchment enters the most vulnerable class for mean annual runoff (MAR).

### Key findings (plain words)

- **It matters, but not in one direction.** For **72%** of catchments (157 of 217 with a paired threshold) the vulnerability threshold changed when parameters were allowed to evolve — **38% higher, 34% lower, 28% identical**; median difference zero; the two thresholds agree only weakly (slope 0.31, R² = 0.14). Ignoring non-stationarity is therefore *not* a neutral simplification: it can overstate vulnerability in some catchments and understate it in others.
- **Snow and soil parameters are climate-sensitive.** FC, beta, SFCF, TT and CFMAX separate most strongly between climate zones (e.g., median CFMAX 1.75 mm °C⁻¹ d⁻¹ in Dfc vs 4.44 in Dfa); groundwater parameters (k0, k1, k2, UZL, PERC) overlap more.
- **Climate is only part of the story.** Physiography explains as much or more of the parameter variation for beta, k0, PERC, UZL and MAXBAS — the zone pools are useful but imperfect (a limitation, stated honestly).
- **Secondary indicators are honest but weak.** Low-flow (LFI) and high-flow (MAMF) thresholds are identifiable in only 10–26% of catchments, and the MAR temperature threshold in < 7% — the conclusions rest on MAR.
- **Where catchments tip first.** Northern Great Plains catchments (Dakotas, Nebraska, Iowa) enter the vulnerable class with a 1–5% rainfall drop (thresholds 0.95–0.99); Pacific coastal catchments are most tolerant.

### What to do in future

1. Consume published **CMIP6 Köppen–Geiger projections** (Beck et al. 2023, Bayar et al.) through the same delta-change + reclassify mechanism.
2. Test a **zone-conditional PET benchmark** — the PET formulation itself is a vulnerability control (Hargreaves used here; Hamon alternative untested).
3. Add **physiography-conditioned pools** (climate + attributes), since climate alone leaves much variance unexplained.
4. Make LFI/MAMF thresholds reliable via **hierarchical/regional pooling** or longer records.
5. **Real-time updating** (data assimilation, remote sensing) and extension to more catchments and socio-economic dimensions.

---

## 2. The 3–4 keypoints for the editor (cover letter / highlights)

1. **First framework that closes a documented three-way gap.** Transferability studies quantify performance loss but don't redefine parameters; time-varying methods anchor drift to time/record, not to an interpretable class; the KG-projection literature stops at the climate surface. CZIPEF is the first to propagate **Köppen–Geiger zone transitions into hydrological parameterization and vulnerability thresholds** (Introduction gap paragraph; Discussion 5.1–5.2 comparisons).
2. **Large-sample, validated evidence.** 222 catchments, behavioural calibration (KGE ≥ 0.5, |PBIAS| ≤ 25%, ≥ 50 sets of 10,000 LHS), differential split-sample validation both directions (KGE drop ≤ 0.05), isotonic + logistic estimators with an independent CART cross-check, binomial bootstrap intervals.
3. **A quantified, falsifiable headline result.** The climate-zone-informed framework changes the MAR precipitation threshold in **72% of catchments (83 higher / 74 lower / 60 equal of 217)**, median difference zero (binomial p = 0.52), regression R² = 0.14 — i.e., the correction is **catchment-specific and climatically patterned, not a uniform shift**, so a stationary-parameter study risks overstating vulnerability in some catchments and understating it in others.
4. **Transparency about what is and is not identifiable.** The paper explicitly reports that temperature thresholds (≤ 7% of catchments) and the supplementary LFI/MAMF indicators (10–26%) are rarely identifiable, that single-catchment zone pools (BSk, Dsa, Dsc, ET) are shown but not interpreted, and that climate explains only part of parameter variation — "a limit of the framework, not a property of the model."

**What to highlight everywhere (abstract, cover letter, visual abstract):**
- The **72% / 38-34-28** decomposition and "median difference is zero".
- "Stationarity cannot be treated as a neutral simplification."
- The **zone-conditioned parameter pool + copula resampler** as the methodological novelty (centrepiece Fig. 7).
- The **fallback rule** (scenarios whose destination class has no pool keep baseline sets and are excluded) — reviewers like explicit safeguards.
- "A transparent, reproducible **first step**" framing (deliberately not "new paradigm").

---

## 3. Number cheat-sheet (all verified against pipeline tables)

| Item | Value | Source |
|---|---|---|
| CAMELS inventory → candidates → analysed | 671 → 332 → 222 | T3, §2 |
| Calibration screen | 10,000 LHS; KGE ≥ 0.5; \|PBIAS\| ≤ 25%; ≥ 50 sets; 200 retained | T3 |
| Median behavioural KGE / NSE / \|PBIAS\| | 0.598 / 0.366 / 5.28% | T3 |
| Split-sample KGE (forward / reverse) | 0.582→0.574 / 0.593→0.550 | T4 |
| Observed decadal KG transitions | 20.7% of catchments | T5 |
| Any scenario transition / median classes visited | 91.9% / 3 | T5 |
| Delta-change class change (+1.5 °C / +4 °C) | 16–30% / 50–58% | T5b |
| Classes with parameter pools | 12 (BSk…ET); none in Af, Am, Aw, BSh, BWh, BWk | T5 |
| MAR P-threshold SPF / CZIPEF median (IQR) | 0.752 (0.707–0.791) / 0.741 (0.716–0.779) | T7 |
| Paired thresholds (MAR) | n = 217 | T7/T8 |
| Decomposition | 83 higher (38.2%) / 74 lower (34.1%) / 60 equal (27.6%) | T8 |
| Median difference / binomial p | 0 / 0.52 | T8 |
| SPF–CZIPEF regression (MAR) | y = 0.505 + 0.309x, R² = 0.138 | T8, Fig. 11 |
| LFI / MAMF paired thresholds | 41 (2/17/22) / 17 (3/4/10) | T8, Figs 11–12 |
| Identifiable P-thresholds | MAR 100/97.7%; LFI 25.7/23.9%; MAMF 9.9/11.7% | T7b |
| Identifiable T-threshold (MAR) | 6.8% SPF / 2.3% CZIPEF | T7b |
| Climate share largest / smallest | CFMAX 62.6% / MAXBAS 5.5% | T6 |
| ΔR² adding zone (significant) | 0.06–0.09 for beta, LP, TT, k2, PERC (p < 0.01) | T6 |
| Sobol first-order (BSk, MAR) | FC 0.64, beta 0.33, LP 0.12 | §4, T9 |
| Ensemble CV (MAR / MAMF / LFI) | 5–11% / 16–142% / 50–228% | Fig. S9 |
| Example catchment 06614800 | P-threshold 0.67 SPF vs 0.70 CZIPEF; T-threshold 3.9 °C; 25/121 vs 43/121 cells ≥ 0.5 | Fig. 9 |

**Do not invent numbers** — pull from this table or regenerate with `Rscript 01-analysis/R/run_all.R` (`TSFT_STAGES` to restrict).

---

## 4. Figure & table map (manuscript ↔ source)

| Fig | Content | File | Caption status |
|---|---|---|---|
| 1 | Analysed catchments (green) vs candidate-only (grey); dot size = area | `02-outputs/revision/figures/FA_analysed_catchments.pdf` | v002 28 Nov 2026 |
| 2 | Red cross = 222 analysed, blue circle = 110 candidate-only | `02-outputs/revision/figures/FB_selection_map.pdf` | v002 |
| 3 | Bottom-up framework workflow | `02-outputs/revision/figures/fig3_framework.pdf` (mmd) | v001 |
| 4 | HBV structure + governing equations (incl. fixed CFR, CWH, SP) | `02-outputs/revision/figures/fig4_hbv.pdf` (mmd) | v001 |
| 5 | Monte-Carlo calibration loop | `02-outputs/revision/figures/fig5_calibration.pdf` (mmd) | v001 |
| 6 | Threshold estimation + CART cross-check workflow (NOT a tree plot) | `02-outputs/revision/figures/fig6_cart_crosscheck.pdf` (mmd) | v001 |
| 7 | KG-zone-conditioned parameter evolution (centrepiece), two panels | `02-outputs/revision/figures/fig7_kg_parameter.pdf` (mmd) | v002 28 Nov 2026 |
| 8 | Delta-change KG map, 3 ΔP rows × 4 ΔT columns | `02-outputs/revision/figures/F4b_kg_delta_change_map.pdf` | v002 |
| 9 | P(class 3) surface, catchment 06614800, SPF vs CZIPEF | `02-outputs/revision/figures/F14_prevalence_surface.pdf` | v002 |
| 10 | Precipitation threshold maps, SPF vs CZIPEF (MAR) | `02-outputs/revision/figures/F8b_threshold_map.pdf` | v002 |
| 11 | Threshold scatter, **3 panels** (MAR/LFI/MAMF) | `02-outputs/revision/figures/F8_threshold_scatter.pdf` | v002 |
| 12 | Direction of difference, **3 panels** (MAR/LFI/MAMF) | `02-outputs/revision/figures/F9_threshold_difference_map.pdf` | v002 |
| 13 | Parameter CDFs by KG class (12 classes; 4 step-like) | `02-outputs/revision/figures/F13_parameter_cdf.pdf` | v002 |
| 14 | PRCC + Sobol for MAR, six representative catchments | `02-outputs/revision/figures/F10_sensitivity.pdf` | v002 |
| S1–S10 | calibration, split-sample, drift, KG maps, variance partition, RF, LFI/MAMF sensitivity, uncertainty, identifiability | `02-outputs/revision/figures/F*.pdf` | v002 |

| Table | Content |
|---|---|
| 1 | Köppen–Geiger classes (inline) |
| 2 | HBV parameter ranges (inline) |
| 3 / 4 | Calibration summary / split-sample |
| 5 / 5b | Observed decadal KG transitions / delta-change map transitions |
| 6 | Climate vs physiography variance shares |
| 7 / 7b | Thresholds by indicator & framework / identifiability |
| 8 | SPF–CZIPEF decomposition |
| 9 | Significant parameters by class & indicator |

House style for figures: root `FIGURES.md` (register) + `latex-v2/figure-spec/TYPOGRAPHY_SPEC.md` (v2 sizes). Conceptual: Mermaid → pele → PDF/PNG; data: ggplot2 `theme_publication()`, designed at 160 mm.

---

## 5. Terminology discipline (use exactly these)

- **SPF** = Stationary Parameter Framework (frozen behavioural sets). **CZIPEF** = Climate Zone-Informed Parameter Evolution Framework.
- "behavioural parameter sets" (not "parameters") when referring to the retained ensembles.
- "climate-zone pools", "zone-matched pool", "Gaussian copula resampler" (not KDE — KDE was considered and rejected; eq. 6 stays as the definition).
- "vulnerability threshold" = the ΔP (or ΔT) at which the temperature-averaged probability of the most vulnerable class crosses 0.5.
- Classes are **Class 0–3** (0 = no vulnerability; 3 = most vulnerable; direction-aware: decrease for MAR/LFI, increase for MAMF).
- Beck et al. (2023) supplies "class definitions and delta-change logic" — never call the maps a CMIP6 projection or a pixel-level raster comparison.
- Frame the contribution as a **first step**, not a new paradigm.

## 6. Known limits to state proactively (reviewer-proofing)

1. Synthetic delta-change scenarios, not GCM-driven projections.
2. Climate-zone pools capture only part of between-catchment variation (physiography).
3. Four zone pools come from a single catchment each (BSk, Dsa, Dsc, ET) — shown, not interpreted.
4. Fallback scenarios (destination class has no pool) keep baseline sets and are excluded from threshold estimation.
5. Only six representative catchments for PRCC/Sobol (class-level, not catchment-level).
6. LFI/MAMF and temperature thresholds rarely identifiable — conclusions rest on MAR.

## 7. Build & verify commands

```powershell
# from repo root
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
cd 03-writeup/Revision-1/latex-v2; bibtex manuscript; cd ..\..\..
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
```

Verify before submitting: zero `undefined` citations in `manuscript.log`, figures match captions (§4 map above), numbers match the cheat-sheet (§3).
