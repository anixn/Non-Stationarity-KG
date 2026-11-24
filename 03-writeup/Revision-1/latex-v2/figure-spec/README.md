# figure-spec — how to use this folder

Contains the publication-figure specification for the CZIPEF manuscript,
following the same house style as the CIMP6 India paper
(`D:\Datasets\CIMP6_India\manuscript\figures`).

| File | Purpose |
|---|---|
| `FIGURES.md` | Figure map (manuscript Fig. 1–14 + S1–S10), what each conceptual figure shows, house-style rules, reproduction commands |
| `TYPOGRAPHY_SPEC.md` | Font/size/geometry specification for the ggplot2 data figures (Roboto, base_size 12, 10 pt floor, per-figure canvas sizes) |
| `fig3_framework.mmd` | Fig. 3 — bottom-up framework for catchment vulnerability (replaces docx image 3) |
| `fig4_hbv.mmd` | Fig. 4 — HBV model structure with governing equations (replaces image 4) |
| `fig5_calibration.mmd` | Fig. 5 — Monte-Carlo calibration loop, 10,000 LHS → 200 behavioural sets (replaces image 5) |
| `fig6_cart_crosscheck.mmd` | Fig. 6 — CART independent cross-check workflow (replaces image 6; the rpart tree itself remains an R plot) |
| `fig7_kg_parameter.mmd` | Fig. 7 — KG-zone-conditioned parameter evolution loop, the CZIPEF centrepiece (replaces image 7) |

## Rendering the .mmd sources

1. Render each `.mmd` in the browser with **pele**
   (`https://cdn.jsdelivr.net/npm/pele@1/dist/pele.global.js`).
2. **Flatten the computed styles** before export (pele emits CSS variables
   that raster converters such as `rsvg` cannot resolve — arrows disappear
   otherwise) and download the flattened SVG.
3. Convert with rsvg:

```r
rsvg::rsvg_pdf("fig3_framework.svg", "../figures/fig3_framework.pdf")
rsvg::rsvg_png("fig3_framework.svg", "../figures/fig3_framework.png", width = 2200)
```

4. Wire into the manuscript by replacing the corresponding
   `media/media/imageN.png` include in
   `../manuscript.tex` with the new `figures/figN_*.png|pdf` include.

Colour convention (same as CIMP6): scenario/forcing cream
(`#fdf6e3`/`#a6611a`), model/engineering blue (`#e8f1fa`/`#1f4e79`),
parameter/output green (`#eaf5ea`/`#2e6b2e`), decision amber
(`#fdf1e0`/`#a6611a`).
