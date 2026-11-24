# FIGURES.md — publication figure set for the CZIPEF manuscript

Applies to `Deshmukh_2025_KG_R1` revision (LaTeX build:
`03-writeup/Revision-1/latex-v2/manuscript.tex`). House style follows the
same conventions as the CIMP6 India paper
(`D:\Datasets\CIMP6_India\manuscript\figures\FIGURES.md`): conceptual
diagrams are **Mermaid → SVG** (flattened, exported as vector PDF + PNG) and
data figures are **ggplot2** with the shared theme (see `TYPOGRAPHY_SPEC.md`).

## Figure map (manuscript numbering → source)

| Fig | Type | Current file (docx export) | Planned source | Tool |
|---|---|---|---|---|
| 1 | data | `media/media/image1.png` (FA analysed catchments) | `02-outputs/revision/figures/FA_analysed_catchments.*` | ggplot2 |
| 2 | data | `media/media/image2.png` (FB selection map) | `02-outputs/revision/figures/FB_selection_map.*` | ggplot2 |
| 3 | conceptual | `media/media/image3.png` | `fig3_framework.mmd` — bottom-up framework | pele |
| 4 | conceptual | `media/media/image4.png` | `fig4_hbv.mmd` — HBV structure | pele |
| 5 | conceptual | `media/media/image5.png` | `fig5_calibration.mmd` — Monte-Carlo calibration | pele |
| 6 | data/schematic | `media/media/image6.png` | `fig6_cart_crosscheck.mmd` (workflow schematic; the rpart tree itself stays an R plot) | pele + rpart |
| 7 | conceptual | `media/media/image7.png` | `fig7_kg_parameter.mmd` — KG→parameter evolution | pele |
| 8 | data | `media/media/image8.png` | `F4b_kg_delta_change_map.*` (12-panel delta-change KG) | ggplot2 |
| 9 | data | `media/media/image9.png` | `F14_prevalence_surface.*` — P(C3) surface, catchment 06614800 | ggplot2 |
| 10 | data | `media/media/image10.png` | `F8b_threshold_map.*` — SPF vs CZIPEF maps (MAR) | ggplot2 |
| 11 | data | `media/media/image11.png` | `F8_threshold_scatter.*` — SPF vs CZIPEF scatter (n = 217) | ggplot2 |
| 12 | data | `media/media/image12.png` | `F9_threshold_difference_map.*` — direction of threshold difference | ggplot2 |
| 13 | data | `media/media/image13.png` | `F13_parameter_cdf.*` — parameter CDFs by class | ggplot2 |
| 14 | data | `media/media/image14.png` | `F10_sensitivity.*` — PRCC/Sobol for MAR | ggplot2 |

Supplementary figures S1–S10 are appended from
`02-outputs/revision/figures/` (calibration performance, split sample,
parameter drift, baseline KG, transitions, variance partition, RF
importance, LFI/MAMF sensitivity, uncertainty, identifiability) and stay
unchanged.

## What each conceptual figure is for

1. **Figure 3 — the bottom-up framework.** One glance answers "how is
   vulnerability estimated": perturbed climate scenario grid → HBV with
   behavioural parameter sets → streamflow indicators (Drought/Flood/MAR
   classes) → supervised ML → vulnerability class map. Use in §3.1.
2. **Figure 4 — the HBV structure.** Climate inputs → snow → soil →
   groundwater → routing, with the governing equations at each module. Use
   in §3.2 when the model is introduced.
3. **Figure 5 — Monte-Carlo calibration.** Forcing + LHS parameter sets →
   simulated streamflow → evaluation metrics → behavioural loop. Use in
   §3.2 (calibration protocol).
4. **Figure 6 — CART cross-check.** Where the isotonic/logistic estimator
   is cross-checked with a classification tree on the same prevalence
   table. Use in §3.2 (cross-check subsection).
5. **Figure 7 — the KG–parameter evolution loop (centrepiece).** Behavioural
   sets mapped to KG climate zones; each delta-change scenario samples the
   zone-matched pool; vulnerability recomputed. This is the CZIPEF
   mechanism the whole paper argues for.

## House style rules

- **Conceptual figures (Mermaid):** flowchart TD/TB, subgraphs for stages,
  `<br/>` for two-line labels, no emoji, no default theme. Palette
  (`classDef`): scenario/forcing cream `#fdf6e3,stroke:#a6611a`;
  model/engineering blue `#e8f1fa,stroke:#1f4e79`; parameter/output green
  `#eaf5ea,stroke:#2e6b2e`; decision/hypothesis amber `#fdf1e0,stroke:#a6611a`.
  Text is ≥ 16 px in the SVG so that, scaled to \linewidth (~3.3 in) the
  smallest type is ≥ 10 pt equivalent.
- **Data figures (ggplot2):** `theme_academic()` with Roboto, absolute
  element sizes from `TYPOGRAPHY_SPEC.md`; vector PDF for the manuscript +
  300-dpi PNG for review; one panel per panel-a element; Okabe–Ito palette.
- Captions in the docx already carry "Figure N …"; the LaTeX build strips
  the leading number.

## Reproduction

```r
# data figures
Rscript 02-outputs/revision/figures/10_figures.R   # (existing pipeline)
```

The five conceptual figures have already been rendered from the `.mmd`
sources in this folder with **pele** (library render at 16 px, CSS variables
flattened to literal values) and converted to vector PDF + 300-dpi PNG with
`rsvg`; outputs are in `../figures/`:

| Render | File |
|---|---|
| Fig. 3 | `../figures/fig3_framework.{svg,pdf,png}` |
| Fig. 4 | `../figures/fig4_hbv.{svg,pdf,png}` (equation callouts version) |
| Fig. 5 | `../figures/fig5_calibration.{svg,pdf,png}` |
| Fig. 6 | `../figures/fig6_cart_crosscheck.{svg,pdf,png}` |
| Fig. 7 | `../figures/fig7_kg_parameter.{svg,pdf,png}` |

`manuscript.tex` already includes these PNGs (the docx `media/media/imageN.png`
equivalents remain in `../media/` as backup). To re-render after editing a
`.mmd`: use pele (`https://pele.run/` or the library at
`https://cdn.jsdelivr.net/npm/pele@1/dist/pele.global.js`), flatten the
computed styles (replace `var(--pele-*)` with literal values), then:

```r
rsvg::rsvg_pdf("fig3_framework.svg",  "../figures/fig3_framework.pdf")
rsvg::rsvg_png("fig3_framework.svg",  "../figures/fig3_framework.png", width = 2200)
```
