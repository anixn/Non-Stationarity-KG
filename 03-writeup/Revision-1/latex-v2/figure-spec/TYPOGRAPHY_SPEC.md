# TYPOGRAPHY_SPEC.md — fonts and spacing for the CZIPEF data figures

> **Superseded on 2026-11-27.** This spec previously followed the CIMP6 India
> house style (13 pt titles, bold 12 pt axis titles, base 12). It is now
> aligned with the project figure standard
> (`00_project-info/standards/scientific_figure_standard.md`). The style is
> implemented once, centrally, in `theme_publication()` inside
> `01-analysis/R/10_figures.R`; figures are regenerated with
> `Rscript 01-analysis/R/run_all.R` and `TSFT_STAGES=10`.

## Current rules (per the project figure standard)

| Property | Value |
|---|---|
| Font family | **Roboto**, static Regular + Bold, registered through sysfonts/showtext (Arial fallback if Roboto is absent) |
| Text size | **10 pt everywhere** — titles, axis titles, tick labels, legends, strips, panel labels, annotations |
| Titles | plain (never bold), left-aligned |
| Panel labels | bold lowercase **a.)**, **b.)**, **c.)** at the upper-left of each panel; applied when panels carry distinct content, omitted on homogeneous facet grids whose strips already identify the panels |
| Palette | Okabe-Ito/Tol for categories (fixed variable-to-colour mapping across figures), viridis for continuous variables, the official Beck et al. (2023) palette for KG maps, red-blue diverging (#D7191C / grey / #2C7BB6) for signed differences |
| Axis titles | units in parentheses, e.g. `Longitude (°)`, `Temperature change (°C)`, `Precipitation multiplier (–)`; `(–)` marks dimensionless |
| Grid | subtle horizontal major gridlines only (0.3 pt, grey 88); no minor grid |
| Background | white; no strip fills, no borders beyond the classic axis line |
| Export | vector PDF (cairo_pdf) + 300 dpi PNG per figure |

## Geometry

| Constraint | Value |
|---|---|
| Page | A4 with 2.5 cm margins → text width **160 mm** |
| Design width | every figure is designed at exactly **160 mm** wide, so the LaTeX `width=\linewidth,keepaspectratio` include renders at scale 1.0 and text prints at exactly 10 pt |
| Heights | 65–150 mm, set per figure in `10_figures.R` |

## Fixed colour mappings (do not change between figures)

| Variable | Colour(s) |
|---|---|
| KGE | #0072B2 |
| NSE | #E69F00 |
| SPF | #0072B2 |
| CZIPEF | #D55E00 |
| MAR / LFI / MAMF | #0072B2 / #E69F00 / #009E73 |
| PRCC / Sobol first / Sobol total | #0072B2 / #E69F00 / #009E73 |
| Analysed (Fig. 1) | #009E73 (green, per caption) |
| Analysed / candidate (Fig. 2) | #b2182b crosses / #2166ac circles (per caption) |
| Threshold difference | red #D7191C higher, blue #2C7BB6 lower, grey no change |
| KG maps | Beck et al. (2023) official palette (`kg_palette()`) |
| KG classes (non-map figures) | Okabe-Ito + Tol bright, assigned in sorted class order (`kg_class_pal()`) |

## Pass/fail check

```
Smallest figure text = 10 pt (all elements)
Requirement          = 10 pt minimum
Design width = 160 mm = \linewidth at 2.5 cm A4 margins → scale 1.0
=> PASS for all 19 data figures at final saved size.
```
