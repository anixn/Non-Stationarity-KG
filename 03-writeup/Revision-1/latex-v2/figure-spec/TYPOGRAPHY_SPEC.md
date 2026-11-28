# TYPOGRAPHY_SPEC.md — fonts, sizes and geometry for the CZIPEF data figures

> **Status:** current from 2026-11-28. Implements the v2 element table in
> `00_project-info/standards/scientific_figure_standard.md`. It replaces the
> earlier CIMP6 house style (13 pt titles, 12 pt base) and the short-lived
> 2026-11-27 "10 pt everywhere" scheme.
>
> The style is implemented once, centrally, in `theme_publication()` inside
> `01-analysis/R/10_figures.R`; figures are regenerated with
> `TSFT_STAGES=10 Rscript 01-analysis/R/run_all.R`. The project register is
> `FIGURES.md` at the repository root.

## Current rules (per the project figure standard, v2)

| Property | Value |
|---|---|
| Font family | **Roboto**, static Regular + Bold, registered through sysfonts/showtext (Arial fallback if Roboto is absent) |
| Axis titles | **10 pt**, regular |
| Axis tick labels | **9 pt**, regular |
| Figure legends (title and text) | **9 pt**, regular; title may be medium, not bold |
| Strip labels (facets) | **9 pt**, regular |
| Colorbar title and ticks | **9 pt**, regular |
| Panel labels | **11 pt bold**, house format **a.)**, **b.)**, **c.)**, upper-left inside each panel; used when panels carry distinct content |
| In-plot annotations | **9 pt**, regular |
| Inset text | **8 pt**, regular (only when the inset is small) |
| Minimum | no text below **7 pt** |
| Hierarchy | at most three main sizes — **11** (panel labels) / **10** (axis titles and titles) / **9** (everything secondary); insets may use 8 |
| Titles | plain (never bold), left-aligned, 10 pt |
| Palette | Okabe-Ito/Tol for categories (fixed variable-to-colour mapping across figures), viridis for continuous variables, the official Beck et al. (2023) palette for KG maps, red-blue diverging (#D7191C / grey / #2C7BB6) for signed differences |
| Axis titles | units in parentheses, e.g. `Longitude (°)`, `Temperature change (°C)`, `Precipitation multiplier (–)`; `(–)` marks dimensionless |
| Grid | subtle horizontal major gridlines only (0.3 pt, grey 88); no minor grid |
| Background | white; no strip fills, no borders beyond the classic axis line |
| Export | vector PDF (cairo_pdf) + 300 dpi PNG per figure |

## Geometry

| Constraint | Value |
|---|---|
| Page | A4 with 2.5 cm margins → text width **160 mm** |
| Design width | every data figure is designed at exactly **160 mm** wide, so the LaTeX `width=\linewidth,keepaspectratio` include renders at scale 1.0 and text prints at the sizes above |
| Heights | 65–150 mm, set per figure in `10_figures.R` |
| Conceptual diagrams | 160 mm wide; Figs. 3 and 7 are two-panel layouts (160 × 98 mm and 160 × 134 mm); the remaining conceptual diagrams are 160 mm wide with heights set by their aspect |

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

```text
Axis titles               = 10 pt   requirement 9–10 pt   PASS
Tick labels / legends     =  9 pt   requirement 8–9 pt    PASS
Panel labels              = 11 pt bold, a.) format        PASS
Smallest text in any data figure = 9 pt (no insets used)  PASS (floor 7 pt)
Design width = 160 mm = \linewidth at 2.5 cm A4 margins → scale 1.0
=> PASS for all 19 data figures at final saved size.
```
