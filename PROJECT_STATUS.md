# Project Status and Research Summary

> **Purpose:** plain-language, continuously updated overview of the study —
> the research question, progress, findings, problems and next steps,
> readable without code or terminal logs.

**Last updated:** 2026-11-27 17:20\
**Overall status:** Manuscript preparation (analysis complete)\
**Current stage:** Revision-1 figures rebuilt to the project figure standard; manuscript re-built\
**Last working session:** 20261127

---

## 1. What is this study about?

- **Problem:** Hydrological models (here HBV) are calibrated once on past
  data and their parameters are then assumed valid forever — the
  *stationarity* assumption. Vulnerability assessments built on it inherit
  the error as climate changes.
- **Why it matters:** Threshold estimates (how much rainfall can drop before
  a catchment becomes vulnerable) feed drought and water-resources planning;
  if parameters cannot transfer to a changed climate, those estimates are
  biased in an unknown direction.
- **Research question:** Does conditioning model parameters on the
  Köppen–Geiger climate zone — and letting them evolve when a scenario moves
  a catchment into a different zone (CZIPEF) — change the estimated
  vulnerability threshold compared with a stationary-parameter framework
  (SPF)?
- **Intended contribution:** The first framework that propagates
  Köppen–Geiger zone transitions into hydrological parameterization and
  vulnerability thresholds, tested on a large validated sample with
  transparent reporting of what is and is not identifiable.

A full simple-language brief is in [`help.md`](help.md).

## 2. Research objectives

1. Quantify how climate-zone-conditioned parameter evolution (CZIPEF) changes
   precipitation and temperature vulnerability thresholds for mean annual
   runoff (MAR), against a stationary-parameter baseline (SPF).
2. Validate the comparison with differential split-sample tests, moving-window
   recalibration, an independent CART cross-check and bootstrap intervals.
3. Report honestly which indicators and thresholds are identifiable
   (MAR primary; LFI and MAMF supplementary) and where the framework's
   limits are.

## 3. Overall project status

| Research stage | Status | Short explanation |
|---|---|---|
| Research design | Completed | CZIPEF vs SPF over a 121-cell scenario grid; documented in `concept.md` and Methods |
| Data acquisition | Completed | CAMELS-US (Caravan formatting) + HydroATLAS attributes; 332 candidates selected |
| Data preparation | Completed | 1° selection list, forcing units corrected (PET conversion), documented in the pipeline README |
| Analysis and modelling | Completed | Production run 19–20 Nov 2026; 222 of 332 catchments pass; stages 02–09 zero failures |
| Validation and uncertainty | Completed | Split-sample both directions, moving-window drift, isotonic+logistic thresholds with CART cross-check, binomial bootstrap, PRCC/Sobol |
| Figures and tables | Completed | Tables T3–T9 auto-generated; all 19 data figures rebuilt 2026-11-27 to the project figure standard |
| Manuscript | In progress | latex-v2 rebuilt 2026-11-27 (50 pp, zero unresolved citations); remaining: journal-style bibliography, cover letter, optional PET robustness run |

## 4. Data and resources

| Dataset or resource | Purpose | Period / coverage | Source | Status / limitations |
|---|---|---|---|---|
| CAMELS-US daily forcing + streamflow (Caravan format) | HBV forcing and calibration target | 1981–2010 used; 671 US catchments | `D:/OneDrive/Research/Datasets/Caravan_B/timeseries/camels` (Caravan; GAUCHER et al. 2024-based extension of Newman et al.) | mm/day units; PET corrected in Revision-1 |
| Caravan climatic attributes | Climate predictors | per catchment | `…/attributes/camels/attributes_caravan_camels.csv` | — |
| HydroATLAS physiographic attributes | Physiography predictors | per catchment | `…/attributes_hydroatlas_camels.xlsx` | — |
| 1° selection list (`US_Cat_30_1Deg.csv`) | Candidate set: one catchment per 1° cell, 30-year complete record | 332 candidates | `01-analysis/data/` | 222 pass calibration acceptance |
| Köppen–Geiger lookup + classifier | Zone assignment (Beck et al. 2023 scheme) | — | `01-analysis/data/KG Classes.csv`, `kg_class_all.R` | Official RGB palette reused for maps |

External datasets live outside the repo (path in `00_config.R`); raw inputs
are never modified.

## 5. Methodology in simple language

1. **Select catchments** — one per 1° grid cell with a complete 30-year
   record (332 candidates). Checked: record completeness, units.
2. **Calibrate HBV** per catchment with a 10,000-point Latin hypercube on
   1981–2010 (2-year warm-up); keep up to 200 behavioural sets
   (KGE ≥ 0.5, |PBIAS| ≤ 25%). 222 catchments pass.
3. **Validate transferability** — forward/reverse split-sample (1981–1995 vs
   1996–2010) and 10-year moving-window recalibration; parameter drift is
   what motivates zone pools.
4. **Assign Köppen–Geiger zones** to the baseline and to perturbed
   climatologies (Beck et al. 2023 scheme).
5. **Pool behavioural sets by zone** and resample with a bounded
   correlation-preserving Gaussian copula.
6. **Run the 121-cell scenario grid** (precipitation ×0.5–1.5, temperature
   −2…+8 °C) under SPF (frozen sets) and CZIPEF (zone-matched pools,
   re-sampled when the zone changes); compute MAR, LFI, MAMF per set.
7. **Estimate vulnerability thresholds** (isotonic crossing + logistic
   prevalence model, binomial bootstrap CIs), cross-checked with CART.
8. **Attribute and sensitivity** — variance partitioning, random-forest
   importance, PRCC + Sobol.
9. **Generate tables and figures** from stage outputs only (stages 08/10).

Scripts: `01-analysis/R/00_config.R … 10_figures.R`, orchestrated by
`run_all.R`. Details: [`01-analysis/R/README.md`](01-analysis/R/README.md).

## 6. Key findings so far

All numbers are from the 19–20 Nov 2026 production run and are traceable to
tables in `02-outputs/revision/tables/` (see the cheat-sheet in `help.md`).

- **Validated:** For **72% of catchments (157 of 217 with a paired
  threshold)** the MAR precipitation threshold changed under CZIPEF —
  **38% higher, 34% lower, 28% identical**; median difference zero;
  regression slope 0.31, R² = 0.14. Non-stationarity is therefore *not* a
  neutral simplification: it shifts vulnerability estimates in both
  directions by catchment.
- **Validated:** Snow and soil parameters separate most strongly between
  climate zones (e.g., median CFMAX 1.75 mm °C⁻¹ d⁻¹ in Dfc vs 4.44 in Dfa);
  groundwater parameters overlap more.
- **Validated (as a limitation):** Climate explains only part of parameter
  variation; physiography explains as much or more for beta, k0, PERC, UZL
  and MAXBAS.
- **Validated (reporting honesty):** Temperature thresholds are identifiable
  in ≤ 7% of catchments and supplementary LFI/MAMF thresholds in 10–26%;
  conclusions rest on MAR.
- **Preliminary:** Northern Great Plains catchments enter the vulnerable MAR
  class with a 1–5% rainfall drop; Pacific coastal catchments are most
  tolerant (spatial pattern from the threshold maps, consistent across
  estimators).

## 7. Latest working session

**Date:** 20261127\
**Session objective:** Apply the toolkit standards (project status template,
file/folder standard, scientific figure standard) to the project; rebuild all
figures to the figure standard.\
**Session outcome:** Completed

### Work completed

- Read the three toolkit standards and archived copies in
  `00_project-info/standards/`.
- Kept the existing numbered project tree (the pipeline paths depend on it);
  documented the standard↔project folder mapping in
  `00_project-info/project_structure.md` so the structure is remembered.
- Rewrote `01-analysis/R/10_figures.R` around a centralised
  `theme_publication()`: Roboto throughout (Arial fallback) at 10 pt, bold
  `a.)`/`b.)` panel labels where panels carry distinct content, fixed
  colourblind-safe palettes (Okabe–Ito/Tol, viridis, Beck 2023 KG palette,
  red–blue diverging), units in parentheses, white background, subtle
  horizontal gridlines, vector PDF + 300 dpi PNG.
- Redesigned figure sizes to the manuscript's real printed width (A4,
  2.5 cm margins → 160 mm), so text prints at exactly 10 pt.
- Fixed while verifying renders: a facet-order bug (panel labels were
  re-sorting facets alphabetically), crowded year/index tick labels, clipped
  axis titles on F2/F8/F12, the F4b 12-panel map layout (short ΔP row labels,
  fewer ticks, 95 mm height), and replaced the meaningless single-observation
  boxplots in F11 with points (stage 09 has one representative catchment per
  class).
- Regenerated all 19 data figures (FA, FB, F1–F14 incl. F4b, F8b, F10b) in
  stage 10 (≈20 s).
- Copied the new PNGs into the LaTeX build inputs (`latex-v2/si/` and
  `latex-v2/media/media/`) and synced captions: Fig. 9 now reads "(a) SPF
  and (b) CZIPEF"; Fig. 12 colour wording is red higher / blue lower / grey
  identical (was red/green/blue with a non-colblind-safe palette).
- Updated `figure-spec/TYPOGRAPHY_SPEC.md` to the new standard (the old
  12–13 pt spec is superseded) and fixed the outdated reproduction command in
  `figure-spec/FIGURES.md`.
- Rebuilt `manuscript.pdf` (50 pages, zero unresolved citations).
- Created this `PROJECT_STATUS.md` per the toolkit template.

### Files created

| File and location | Purpose |
|---|---|
| `PROJECT_STATUS.md` | Standing project status (this file) |
| `00_project-info/project_structure.md` | Structure memory: standard↔project mapping + conventions |
| `00_project-info/standards/*.md` (3 files) | Archived toolkit standards |
| `02-outputs/revision_figs_std.log` | Figure-stage run log for this session |

### Files modified

| File and location | What changed |
|---|---|
| `01-analysis/R/10_figures.R` | Complete restyle to the figure standard; panel-label helper; fixed palettes; per-figure sizes |
| `01-analysis/R/00_config.R` | Plotting constants now describe the standard (FIG_DPI 300, FIG_W_MM 160) |
| `02-outputs/revision/figures/*` (PDF + PNG ×19) | Regenerated |
| `03-writeup/Revision-1/latex-v2/si/*.png`, `…/media/media/*.png` | Refreshed copies of the new figures |
| `03-writeup/Revision-1/latex-v2/manuscript.tex` | Fig. 9 and Fig. 12 captions synced; PDF rebuilt (50 pp) |
| `03-writeup/Revision-1/latex-v2/figure-spec/TYPOGRAPHY_SPEC.md` | Rewritten to the new standard |
| `03-writeup/Revision-1/latex-v2/figure-spec/FIGURES.md` | House-style + reproduction notes updated |

### Results and interpretation

The figures are now visually consistent (one font, one theme, one palette
mapping per variable) and print at exactly 10 pt at the manuscript's text
width. No data, thresholds or statistics changed — this session touched only
presentation. Two captions were reworded to match the new panel labels and
the colourblind-safe palette; the underlying results (83 higher / 74 lower /
60 identical) are unchanged.

### Problems and errors

- **Facet order reversed by panel labels** (CZIPEF drawn left of SPF, labels
  mismatched) — resolved: the `panel_labels()` helper now keeps the facet
  column as a factor with the plot's level order.
- **Clipped axis titles** on F2, F8, F12 — resolved by wrapping titles.
- **Crowded tick labels** on F3 (years) and F10/F10b (sensitivity indices) —
  resolved with explicit breaks.
- **F11 boxplots rendered as single lines** — not an error but meaningless:
  one representative catchment per class gives one CV per cell. Replaced with
  points; documented in the script.
- Unresolved: none from this session.

### Decisions made

- **Kept the existing folder tree** instead of renaming to the generic
  `00…07` template (standard's "preserve existing structure" rule; pipeline
  paths depend on it). The mapping is recorded in `00_project-info/`.
- **Panel labels** are applied where panels carry distinct content
  (F1, F2, F8, F8b, F9, F12, F14) and omitted on homogeneous facet grids
  (F3, F4b, F10, F10b, F13) whose strips already identify panels.
- **F9 palette** changed from default hue (red/green/blue) to a
  colourblind-safe red/blue/grey diverging mapping; caption updated to match.
- **F11 presentation** changed from boxplot to points; data untouched.

### Verification performed

- Viewed all 19 regenerated PNGs at full size and checked: font rendering,
  panel labels and order, tick crowding, title clipping, legend placement,
  map label overlaps, palette consistency.
- Confirmed the LaTeX build compiles clean (50 pp, output written; 3 known
  cosmetic bibtex warnings unchanged).

## 8. Pending tasks

| Priority | Task | Why it is needed | Status / dependency |
|---|---|---|---|
| High | Switch bibliography to the target journal's style | Submission formatting | Pending; needs target journal choice |
| High | Copy updated figures/captions into the R1 docx (`Deshmukh_2025_KG_R1.docx`) if the docx is still the submission vehicle | Keep both manuscript formats consistent | Pending |
| Medium | Cover letter draft from `help.md` §2 | Submission requirement | Pending |
| Medium | Optional Hamon-PET robustness run | Reviewer-flagged robustness check | Pending; separate full run (~1 day compute) |
| Low | Re-render conceptual Figs 3–7 only if their `.mmd` sources change | House-style refresh | Not needed now |

## 9. Next recommended steps

1. Confirm the submission vehicle (docx vs latex-v2 PDF) and mirror the
   2026-11-27 figure/caption updates into it.
2. Choose the target journal; switch `apalike` to its bibliography style and
   re-run the LaTeX build.
3. Draft the cover letter from `help.md` §2 keypoints.
4. Decide on the optional Hamon-PET robustness run before resubmission.

## 10. Important research decisions and limitations

- **Calibration 1981–2010 with 2-year warm-up** (text must say 1981, not
  1980); split-sample 1981–1995 / 1996–2010.
- **Acceptance: KGE ≥ 0.5 and |PBIAS| ≤ 25%**; NSE reported but not used for
  screening (structurally limited basins would be discarded).
- **Routing enabled** (`USE_ROUTING = TRUE`), so MAXBAS is identifiable.
- **MAR is the primary indicator**; LFI and MAMF are supplementary with the
  same four vulnerability classes; vulnerability direction is stored once in
  `INDICATOR_META`.
- **KG maps are a delta-change product** built with the Beck et al. (2023)
  class scheme, not a copy of their gridded future map.
- **Zone pools for classes with few catchments** (BSk, Dsa, Dsc, ET) are
  shown but not interpreted; scenarios landing in an unsupported class keep
  baseline sets and are excluded (fallback rule, `MAX_FALLBACK = 0.10`).
- **Climate explains only part of parameter variation** — physiography
  matters as much for several parameters; stated as a framework limit.
- **Seeds:** `SEED <- 20251119` in `00_config.R`; per-catchment seeds derived
  deterministically (hash), so runs are reproducible.

## 11. Reproducibility and execution

- **Main scripts and execution order:** `01-analysis/R/run_all.R` → stages
  02–10 (`00_config.R`, `01_functions.R`, `02_calibrate.R`,
  `03_temporal_validation.R`, `04_kg_transitions.R`,
  `05_parameter_controls.R`, `06_pool_resample.R`, `07_scenarios.R`,
  `08_thresholds.R`, `09_sensitivity.R`, `10_figures.R`).
- **Input data locations:** external Caravan/HydroATLAS paths in
  `00_config.R` (`D:/OneDrive/Research/Datasets/Caravan_B/...`).
- **Output locations:** `02-outputs/revision/` (tables, figures, stage CSVs);
  smoke tests via `TSFT_REV_DIR`.
- **Software and versions:** R 4.4.1; ggplot2 3.5.x; TinyTeX for the PDF
  build; showtext/sysfonts for fonts.
- **Random seeds:** `SEED 20251119`; deterministic per-catchment seeds.
- **Configuration:** everything in `00_config.R` (bounds, periods, budgets,
  scenario grid, indicator metadata); no paths hard-coded elsewhere.
- **Known execution requirements:** stage 10 figures need the stage 02–09
  outputs; Roboto or Arial installed for the figure font; stage 07 dominates
  runtime (~13 h full run) — figures alone rerun with
  `TSFT_STAGES=10 Rscript 01-analysis/R/run_all.R` in ≈20 s.

## 12. Overall research assessment

- The original Revision-1 objectives (reviewer responses #2.1–#2.8, minor
  #6) are fully addressed by the production run; the manuscript text, tables
  and now the figures are consistent with it.
- Supported findings: the 72% threshold-shift decomposition (83/74/60 of
  217), zero median difference, weak overall agreement (R² = 0.14),
  zone-separation of snow/soil parameters, and honest identifiability
  reporting.
- Main weaknesses: physiography explains much of the residual parameter
  variance; LFI/MAMF and ΔT thresholds are rarely identifiable; zone pools
  for rare classes rest on single catchments.
- Before submission: journal-style bibliography, cover letter, optional PET
  robustness run, and mirroring the new figures into whichever submission
  format is chosen.

## 13. Session history

### 20261127 — Figures rebuilt to the project figure standard

- **Objective:** apply the toolkit standards; rebuild all data figures
  (Roboto 10 pt, `a.)` panel labels, colourblind-safe palettes, 160 mm
  design width, 300 dpi).
- **Work completed:** rewrote `10_figures.R` + config constants; fixed the
  facet-order bug, tick crowding, clipped titles, F4b layout, F11
  presentation; regenerated 19 figures; synced LaTeX copies and two
  captions; rebuilt the PDF; created `PROJECT_STATUS.md` and
  `00_project-info/` (standards archive + structure map).
- **Files created or modified:** see Section 7.
- **Results:** all figures verified visually at final size; manuscript
  rebuilt at 50 pp; no statistical results changed.
- **Problems or unresolved issues:** none outstanding from the session.
- **Decisions:** keep existing folder tree; panel-label policy; F9 diverging
  palette with caption sync; F11 points instead of single-observation
  boxplots.
- **Next steps:** see Section 9.

### 20261124 — Figure/caption/text consistency audit (from `progress.md`)

- Audited captions, legends and text–table mismatches; fixed +2 °C
  class-change range, Table 9 significance claims, Table 6 ΔR² sentence;
  rebuilt PDF (50 pp).

### 20261120 — Production run and cleanup (from `progress.md`)

- Full 222-catchment production run completed; numbers filled; project
  cleaned 1.4 GB → 128 MB; superseded code removed.

---

## Instructions for maintaining this file

- **Start of session:** read `readme.md`, this file, and
  `00_project-info/project_structure.md`; inspect relevant files before
  assuming project state.
- **End of session:** update Sections 3, 6, 7, 8 and the session history
  (newest first) before reporting the session as complete. Never invent
  results or claim checks that were not performed.
- **Final requirement:** this file must always answer — What was done? What
  does it mean? What is the project state now? What should happen next?
