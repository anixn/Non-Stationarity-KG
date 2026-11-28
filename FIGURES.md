# FIGURES.md — figure register and specification (CZIPEF)

> **Project:** `202505_Non_Stationarity_KG` — Revision 1 of HYDROL72949.
> **Manuscript:** `03-writeup/Revision-1/latex-v2/manuscript.tex`.
> **Standard:** `00_project-info/standards/scientific_figure_standard.md`
> (v2, element size table, 2026-11-28). This register replaces the earlier
> figure-spec register; there is one register for the project.
> **Live register:** yes — this is the file to update whenever a figure is
> created or changed. Sources for the conceptual diagrams and the theme notes
> stay in `03-writeup/Revision-1/latex-v2/figure-spec/`.

**Last updated:** 2026-11-28
**Style scheme in force:** v2 element table — axis titles **10 pt**; tick
labels, legends, strip labels and colorbars **9 pt**; panel labels **11 pt
bold** (`a.)`); in-plot annotations **9 pt**; insets **8 pt**. Three main
sizes only (11 / 10 / 9), never below 7 pt. This replaces the 2026-11-27
"10 pt everywhere" scheme.
**Design width:** 160 mm (A4, 2.5 cm margins) for every data figure; the
LaTeX build includes at `width=\linewidth`, so printed sizes equal the sizes
above.
**Export:** vector PDF (`cairo_pdf`) + 300 dpi PNG, white background.
**Publication folder:** `02-outputs/revision/figures/` (single output root;
the old `latex-v2/media/media/` and `latex-v2/si/` copies were removed on
2026-11-28).

---

## 1. Figure register — main text

| Fig | File stem | Type | One-sentence message | Script | Size (mm) | Status |
|---|---|---|---|---|---|---|
| 1 | `FA_analysed_catchments` | map | 222 of 332 candidate catchments passed calibration and form the analysed sample. | `10_figures.R` | 160 × 100 | final v002 |
| 2 | `FB_selection_map` | map | Candidates and the analysed sample cover the conterminous US without spatial clustering. | `10_figures.R` | 160 × 100 | final v002 |
| 3 | `fig3_framework` | conceptual, 2 panels | (a) Perturbed scenarios and behavioural sets drive HBV to streamflow; (b) indicator classes train the classifier that maps the scenario grid to vulnerability classes. | `fig3_framework.mmd` | 160 × 98 | final v002 |
| 4 | `fig4_hbv` | conceptual | The HBV modules that turn climate inputs into streamflow, with their governing equations. | `fig4_hbv.mmd` | 160 × 114 | final v001 |
| 5 | `fig5_calibration` | conceptual | Latin-hypercube sampling, simulation and the behavioural filter define the parameter sets used downstream. | `fig5_calibration.mmd` | 160 × 180 | final v001 |
| 6 | `fig6_cart_crosscheck` | conceptual/data | Isotonic and logistic thresholds are independently cross-checked with a CART tree. | `fig6_cart_crosscheck.mmd` | 160 × 166 | final v001 |
| 7 | `fig7_kg_parameter` | conceptual, 2 panels | (a) Behavioural sets are pooled by climate zone; (b) a scenario that changes the zone re-samples that pool and the threshold is recomputed (the CZIPEF mechanism). | `fig7_kg_parameter.mmd` | 160 × 134 | final v002 |
| 8 | `F4b_kg_delta_change_map` | map grid | Köppen–Geiger classes under three precipitation and four warming levels. | `10_figures.R` | 160 × 95 | final v002 |
| 9 | `F14_prevalence_surface` | data grid | The 121-cell scenario grid becomes a threshold; the vulnerable wedge differs between SPF and CZIPEF. | `10_figures.R` | 160 × 80 | final v002 |
| 10 | `F8b_threshold_map` | map | Precipitation thresholds for MAR are spatially structured but similar in broad pattern under SPF and CZIPEF. | `10_figures.R` | 160 × 70 | final v002 |
| 11 | `F8_threshold_scatter` | data, 3 panels | The two frameworks' thresholds are only weakly related for MAR and diverge strongly for individual catchments. | `10_figures.R` | 160 × 65 | final v002 |
| 12 | `F9_threshold_difference_map` | map, 3 panels | CZIPEF raises the threshold in some catchments and lowers it in others, with no regional coherence. | `10_figures.R` | 160 × 65 | final v002 |
| 13 | `F13_parameter_cdf` | data grid | Behavioural parameter distributions separate by climate zone, strongly for snow and soil parameters. | `10_figures.R` | 160 × 150 | final v002 |
| 14 | `F10_sensitivity` | data grid | Beta, FC and LP dominate MAR sensitivity in every climate class; snow parameters matter where snow is important. | `10_figures.R` | 160 × 110 | final v002 |

## 1b. Figure register — supplementary

| Fig | File stem | Type | One-sentence message | Script | Size (mm) | Status |
|---|---|---|---|---|---|---|
| S1 | `F1_calibration_performance` | data, 2 panels | Distribution of the median KGE and NSE of the retained behavioural sets. | `10_figures.R` | 160 × 70 | final v002 |
| S2 | `F2_split_sample` | data, 2 panels | Forward and reverse split-sample skill: calibration KGE against validation KGE. | `10_figures.R` | 160 × 70 | final v002 |
| S3 | `F3_parameter_drift` | data grid | Ten-year moving-window recalibration shows parameter drift by climate class. | `10_figures.R` | 160 × 120 | final v002 |
| S4 | `F4_kg_baseline_map` | map | Baseline Köppen–Geiger class of the analysed catchments (1981–2010). | `10_figures.R` | 160 × 100 | final v002 |
| S5 | `F5_kg_transition_map` | map | Fraction of the 121 scenarios in which a catchment leaves its baseline class. | `10_figures.R` | 160 × 100 | final v002 |
| S6 | `F6_variance_partition` | data | Climate, physiography, shared and unexplained fractions of parameter variance. | `10_figures.R` | 160 × 90 | final v002 |
| S7 | `F7_rf_importance` | data | Random-forest importance of climate and physiographic predictors by parameter. | `10_figures.R` | 160 × 100 | final v002 |
| S8 | `F10b_sensitivity_LFI_MAMF` | data grid | PRCC and Sobol sensitivity for the two supplementary indicators. | `10_figures.R` | 160 × 130 | final v002 |
| S9 | `F11_uncertainty` | data | Parametric uncertainty of the three indicators from the retained behavioural sets. | `10_figures.R` | 160 × 75 | final v002 |
| S10 | `F12_threshold_identifiability` | data, 2 panels | Share of catchments with an identifiable precipitation and temperature threshold. | `10_figures.R` | 160 × 70 | final v002 |

Status values: `draft` → `review` → `final`; bump `v001` → `v002` after a
review-stage change. All v002 figures were rebuilt on 2026-11-28 when the
v2 element table replaced the "10 pt everywhere" scheme.

---

## 2. Figure specification — main text

Each block is the mandatory eight-line description from
`scientific_figure_standard.md` §2.2. Units are given in parentheses on the
axes; `(–)` marks dimensionless quantities.

### Fig. 1 — Analysed catchments
```text
Figure:      FA_analysed_catchments
Message:     222 of the 332 candidates passed calibration and form the analysed sample.
Type:        map, 1 panel
Data:        US_Cat_30_1Deg.csv (332 candidates) + calibration/summary.csv (222 analysed)
Encodings:   x = longitude (°), y = latitude (°); colour = status; size = area (km²)
Size/export: 160 × 100 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Green circles mark the 222 catchments that passed the calibration and
             climate-zone requirements and grey circles the candidate-only catchments;
             dot size is catchment area (km²).
```

### Fig. 2 — Candidate catchments and the analysed sample
```text
Figure:      FB_selection_map
Message:     Candidates and the analysed sample cover the conterminous US without spatial clustering.
Type:        map, 1 panel
Data:        US_Cat_30_1Deg.csv + calibration/summary.csv
Encodings:   x = longitude (°), y = latitude (°); colour and shape = status
Size/export: 160 × 100 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Blue circles mark the 110 candidate-only catchments and red crosses the
             222 analysed catchments, drawn from 332 candidates (one per 1° cell).
```

### Fig. 3 — Bottom-up vulnerability framework
```text
Figure:      fig3_framework
Message:     Perturbed climate → HBV → streamflow indicators → supervised ML → vulnerability class map.
Type:        conceptual flowchart, 2 panels (a scenarios/model, b indicators/map)
Data:        none (method diagram); source fig3_framework.mmd
Encodings:   colour = stage type (forcing cream, model blue, parameter green, output cream)
Size/export: 160 × 98 mm; PDF vector + PNG 300 dpi
Script:      figure-spec/fig3_framework.mmd, rendered with pele
Status:      final v002 (2026-11-28; two-panel layout)
Caption:     (a) Perturbed scenarios and behavioural sets drive HBV to streamflow;
             (b) indicator classes train the classifier that maps the scenario grid
             to vulnerability classes, cross-checked with CART (Fig. 6).
```

### Fig. 4 — HBV model structure
```text
Figure:      fig4_hbv
Message:     Snow, soil, groundwater and routing modules and their governing equations.
Type:        conceptual flowchart, 1 panel
Data:        none (method diagram); source fig4_hbv.mmd
Encodings:   colour = module family; arrows = water flux
Size/export: 160 × 114 mm; PDF vector + PNG 300 dpi
Script:      figure-spec/fig4_hbv.mmd, rendered with pele
Status:      final v001 (2026-11-24; unchanged 2026-11-28)
Caption:     Conceptual structure of the HBV model used in the study, with the
             governing equations of each module.
```

### Fig. 5 — Monte-Carlo calibration
```text
Figure:      fig5_calibration
Message:     LHS sampling → simulation → KGE/PBIAS filter → behavioural parameter sets.
Type:        conceptual flowchart, 1 panel
Data:        none (method diagram); source fig5_calibration.mmd
Encodings:   colour = stage; arrows = loop and acceptance decision
Size/export: 160 × 180 mm; PDF vector + PNG 300 dpi
Script:      figure-spec/fig5_calibration.mmd, rendered with pele
Status:      final v001 (2026-11-24; unchanged 2026-11-28)
Caption:     Monte-Carlo calibration methodology adopted for the hydrological model.
```

### Fig. 6 — Threshold estimation and CART cross-check
```text
Figure:      fig6_cart_crosscheck
Message:     Isotonic and logistic thresholds are accepted only when the CART tree agrees within one cell.
Type:        conceptual workflow, 1 panel
Data:        none (method diagram); the rpart tree itself is an R diagnostic
Encodings:   colour = estimator; arrows = agreement decision
Size/export: 160 × 166 mm; PDF vector + PNG 300 dpi
Script:      figure-spec/fig6_cart_crosscheck.mmd, rendered with pele
Status:      final v001 (2026-11-24; unchanged 2026-11-28)
Caption:     Cell-wise indicator classes are mapped to thresholds with isotonic
             regression and a logistic model, and cross-checked with CART.
```

### Fig. 7 — KG-conditioned parameter evolution (CZIPEF)
```text
Figure:      fig7_kg_parameter
Message:     A scenario that changes the climate zone re-samples the zone-matched pool and changes the threshold.
Type:        conceptual flowchart, 2 panels (a pooling, b scenario re-sampling)
Data:        none (method diagram); source fig7_kg_parameter.mmd
Encodings:   colour = stage type; arrows = pool matching and re-sampling loop
Size/export: 160 × 134 mm; PDF vector + PNG 300 dpi
Script:      figure-spec/fig7_kg_parameter.mmd, rendered with pele
Status:      final v002 (2026-11-28; two-panel layout so the diagram fits one page
             and all labels stay at or above 8 pt)
Caption:     (a) Behavioural sets are pooled by climate zone with a Gaussian copula;
             (b) each scenario is reclassified, sets are re-sampled from the zone-
             matched pool and the threshold is recomputed against SPF.
```

### Fig. 8 — Delta-change Köppen–Geiger classes
```text
Figure:      F4b_kg_delta_change_map
Message:     Warming and precipitation change move catchments between Köppen–Geiger classes.
Type:        map grid, 3 rows × 4 columns
Data:        kg/kg_map_levels.csv (121-cell grid; 222 catchments)
Encodings:   x = longitude (°), y = latitude (°); colour = future KG class; rows = ΔP, columns = ΔW
Size/export: 160 × 95 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Classes under ΔP = −50/0/+50% and warming of +1.5/+2/+3/+4 °C,
             assigned with the Beck et al. (2023) scheme to perturbed normals.
```

### Fig. 9 — Prevalence surface for catchment 06614800
```text
Figure:      F14_prevalence_surface
Message:     The vulnerable region is a wedge that opens towards drier and warmer conditions, larger under CZIPEF.
Type:        data grid, 2 panels (a SPF, b CZIPEF)
Data:        scenarios/cells_all.csv, gauge_id = camels_06614800
Encodings:   x = precipitation multiplier (–), y = temperature change (°C); fill = P(class C3); white contour = 0.5
Size/export: 160 × 80 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Probability that MAR is in the most vulnerable class under (a) SPF and
             (b) CZIPEF; cells are the 121 scenario combinations.
```

### Fig. 10 — Precipitation threshold maps (SPF vs CZIPEF)
```text
Figure:      F8b_threshold_map
Message:     Thresholds are spatially structured and broadly similar in pattern between frameworks.
Type:        map, 2 panels (a SPF, b CZIPEF)
Data:        thresholds/comparison.csv (MAR) + kg/kg_baseline.csv
Encodings:   x = longitude (°), y = latitude (°); colour = ΔP threshold (fraction of historical P); shared colour scale 0.4–1.0
Size/export: 160 × 70 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Precipitation thresholds for MAR under (a) SPF and (b) CZIPEF; lower
             values mean a smaller rainfall reduction is enough.
```

### Fig. 11 — SPF vs CZIPEF threshold scatter
```text
Figure:      F8_threshold_scatter
Message:     The pooled relationship is weak (R² = 0.14) but individual thresholds move substantially.
Type:        data scatter, 3 panels (a MAR, b LFI, c MAMF)
Data:        thresholds/comparison.csv (n = 217 paired MAR thresholds)
Encodings:   x = SPF ΔP threshold, y = CZIPEF ΔP threshold (fraction of historical P); dashed red = 1:1, blue = OLS fit
Size/export: 160 × 65 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     SPF against CZIPEF thresholds by indicator; MAR fit
             y = 0.505 + 0.309x, R² = 0.14, n = 217.
```

### Fig. 12 — Direction of the threshold difference
```text
Figure:      F9_threshold_difference_map
Message:     CZIPEF raises thresholds in 83, lowers them in 74 and leaves 60 unchanged; no regional coherence.
Type:        map, 3 panels (a MAR, b LFI, c MAMF)
Data:        thresholds/comparison.csv + kg/kg_baseline.csv
Encodings:   x = longitude (°), y = latitude (°); colour = CZIPEF higher (red #D7191C) / lower (blue #2C7BB6) / unchanged (grey); |Δ| ≤ 0.005 counts as unchanged
Size/export: 160 × 65 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     Direction of the SPF–CZIPEF difference by indicator; red higher,
             blue lower, grey identical.
```

### Fig. 13 — Parameter CDFs by climate zone
```text
Figure:      F13_parameter_cdf
Message:     Snow and soil parameters separate most strongly between zones; groundwater parameters overlap.
Type:        data grid, 12 panels (one per HBV parameter)
Data:        pools/pools.rds (behavioural sets pooled by KG class)
Encodings:   x = parameter value (model units); y = cumulative probability (–); colour = KG class
Size/export: 160 × 150 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     CDFs of the pooled behavioural sets by Köppen–Geiger class; single-
             catchment classes appear as step curves.
```

### Fig. 14 — Parameter sensitivity of MAR
```text
Figure:      F10_sensitivity
Message:     Beta, FC and LP dominate MAR sensitivity in every class; snow parameters matter in snow-influenced classes.
Type:        data grid, 6 panels (one per representative class)
Data:        sensitivity/prcc_*.csv + sensitivity/sobol_*.csv
Encodings:   x = sensitivity index (–); y = HBV parameter; colour = method (PRCC / Sobol first / Sobol total)
Size/export: 160 × 110 mm; PDF vector + PNG 300 dpi
Script:      01-analysis/R/10_figures.R
Status:      final v002 (2026-11-28)
Caption:     PRCC and Sobol sensitivity of the HBV parameters for MAR in six
             catchments representing BSk, Cfa, Cfb, Dfa, Dfb and Dfc.
```

---

## 3. Conceptual figure sources and rendering

The five conceptual diagrams are Mermaid sources. They live in
`03-writeup/Revision-1/latex-v2/figure-spec/` together with the rendered SVG;
the publication PDF + PNG are in `02-outputs/revision/figures/`.

| Fig | Source | Editable render | Publication files |
|---|---|---|---|
| 3 | `figure-spec/fig3_framework.mmd` | `figure-spec/fig3_framework.svg` | `02-outputs/revision/figures/fig3_framework.{pdf,png}` |
| 4 | `figure-spec/fig4_hbv.mmd` | `figure-spec/fig4_hbv.svg` | `02-outputs/revision/figures/fig4_hbv.{pdf,png}` |
| 5 | `figure-spec/fig5_calibration.mmd` | `figure-spec/fig5_calibration.svg` | `02-outputs/revision/figures/fig5_calibration.{pdf,png}` |
| 6 | `figure-spec/fig6_cart_crosscheck.mmd` | `figure-spec/fig6_cart_crosscheck.svg` | `02-outputs/revision/figures/fig6_cart_crosscheck.{pdf,png}` |
| 7 | `figure-spec/fig7_kg_parameter.mmd` | `figure-spec/fig7_kg_parameter.svg` | `02-outputs/revision/figures/fig7_kg_parameter.{pdf,png}` |

To re-render after editing a `.mmd`: open it with **pele**
(`https://pele.run/` or the library at
`https://cdn.jsdelivr.net/npm/pele@1/dist/pele.global.js`), flatten the
computed styles (replace `var(--pele-*)` with literal values), download the
SVG, then:

```r
rsvg::rsvg_pdf("fig3_framework.svg", "../../../../02-outputs/revision/figures/fig3_framework.pdf")
rsvg::rsvg_png("fig3_framework.svg", "../../../../02-outputs/revision/figures/fig3_framework.png", width = 2200)
```

House palette (same as the CIMP6 India paper): scenario/forcing cream
`#fdf6e3` / stroke `#a6611a`; model/engineering blue `#e8f1fa` / stroke
`#1f4e79`; parameter/output green `#eaf5ea` / stroke `#2e6b2e`; decision amber
`#fdf1e0` / stroke `#a6611a`. Text is 16 px in the SVG; at the printed sizes
above that is about 9 pt for the two-panel Figs. 3 and 7, with no label below
8 pt.

---

## 4. Fixed colour and style mappings

| Variable | Colour(s) |
|---|---|
| KGE / NSE | #0072B2 / #E69F00 |
| SPF / CZIPEF | #0072B2 / #D55E00 |
| MAR / LFI / MAMF | #0072B2 / #E69F00 / #009E73 |
| PRCC / Sobol first / Sobol total | #0072B2 / #E69F00 / #009E73 |
| Analysed (Fig. 1) | #009E73 green |
| Analysed / candidate (Fig. 2) | #b2182b crosses / #2166ac circles |
| Threshold difference | red #D7191C higher, blue #2C7BB6 lower, grey #A6A6A6 unchanged |
| KG maps | Beck et al. (2023) official palette (`kg_palette()`) |
| KG classes (non-map figures) | Okabe–Ito + Tol bright, sorted class order (`kg_class_pal()`) |
| Continuous fills | viridis |

Grid: subtle horizontal major gridlines only (0.3 pt, grey 88); no minor
grid. Background white; no strip fills; classic axis line. Axis titles carry
units and `(–)` marks dimensionless quantities.

---

## 5. Reproduction

```powershell
# Rebuild every data figure without re-running the model
$env:TSFT_STAGES = "10"
Rscript 01-analysis/R/run_all.R
```

Stage 10 writes PDF + PNG for all 19 data figures to
`02-outputs/revision/figures/`. The manuscript reads those files directly;
no copies are made. The figure-only run takes about 30 s.

**Checklist before marking a figure final** (from the standard §14): Roboto
applied; axis titles 9–10 pt; ticks/legends 8–9 pt; panel labels 11 pt bold
and clear of data; no text below 7 pt; at most three main sizes; palettes
colourblind-safe and fixed; units on axes; nothing clipped or overlapping;
vector PDF and 300 dpi PNG exported; figure inspected at 100 %.
