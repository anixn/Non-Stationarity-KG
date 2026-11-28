# figure-spec — conceptual figure sources and theme notes

This folder holds the **sources** for the five conceptual diagrams and the
typography notes for the data figures. It is not the figure register.

| File | Purpose |
|---|---|
| `fig3_framework.mmd` + `.svg` | Fig. 3 — bottom-up vulnerability framework |
| `fig4_hbv.mmd` + `.svg` | Fig. 4 — HBV structure with governing equations |
| `fig5_calibration.mmd` + `.svg` | Fig. 5 — Monte-Carlo calibration loop |
| `fig6_cart_crosscheck.mmd` + `.svg` | Fig. 6 — threshold estimation and CART cross-check |
| `fig7_kg_parameter.mmd` + `.svg` | Fig. 7 — KG-conditioned parameter evolution (CZIPEF) |
| `TYPOGRAPHY_SPEC.md` | Font, size and geometry rules for the ggplot2 data figures |

**The live figure register is `FIGURES.md` at the repository root** — it maps
every manuscript and supplementary figure to its file, script, data, size and
status. Do not create a second register here.

Publication outputs (PDF + PNG) for all 19 figures are in
`02-outputs/revision/figures/`; the manuscript reads them directly.

## Rendering a `.mmd` source

1. Render in the browser with **pele**
   (`https://pele.run/` or
   `https://cdn.jsdelivr.net/npm/pele@1/dist/pele.global.js`).
2. Flatten the computed styles before export (pele emits CSS variables that
   raster converters cannot resolve; arrows disappear otherwise) and save the
   SVG in this folder.
3. Convert to PDF + PNG and write straight into the publication folder:

```r
rsvg::rsvg_pdf("fig3_framework.svg", "../../../../02-outputs/revision/figures/fig3_framework.pdf")
rsvg::rsvg_png("fig3_framework.svg", "../../../../02-outputs/revision/figures/fig3_framework.png", width = 2200)
```

4. Update the Fig. 3–7 rows in the root `FIGURES.md` (status/version/date).

Palette: scenario/forcing cream `#fdf6e3` / `#a6611a`; model/engineering blue
`#e8f1fa` / `#1f4e79`; parameter/output green `#eaf5ea` / `#2e6b2e`; decision
amber `#fdf1e0` / `#a6611a`.
