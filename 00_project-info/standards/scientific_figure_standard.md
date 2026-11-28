# Scientific Figure and Visualisation Specification

> **What this file is for:** how every figure is described, built, modified,
> and checked. Read it before creating or changing any figure.
>
> **Companion files:**
> - `working_file.md` — project structure, run workflow, after-run summary.
> - `research_file_and_folder_standard.md` — where files and folders live.
> - `figure_spec_template.md` — the one-page card that describes one figure.
> - `run_summary_template.md` — the report written after every run.
> - `project_status_template.md` — the plain-language project status file.

**Applies to:** hydrology, water resources, drought, low-flow, remote sensing,
climate science, statistical analysis, and machine-learning figures.
**Style name:** Roboto, final-size design, colourblind-safe.
**Status:** v2 — element sizes adopted from the project size table
(2026-11-28).

---

## 0. How to use this file in three steps

1. **Before drawing:** fill one Figure Spec Card (`figure_spec_template.md`)
   for the figure. One card per figure.
2. **While drawing:** use the element size table in §1 and the one central
   theme function. Never set font sizes figure by figure.
3. **Before delivering:** run the checklist in §14 at 100 % zoom and record
   the figure in the project figure register (`FIGURES.md`).

If a journal's instructions conflict with this file, **the journal wins** —
record the exception in the figure register so the next figure is consistent.

---

## 1. Typography and element sizes

### 1.1 The size table (authoritative)

These are **final printed sizes**, measured at 100 % scale on the page. Do not
design large and shrink later — shrinking changes every size in this table.

| Figure element | Recommended size | Default used | Weight | Notes |
|---|---|---|---|---|
| Axis titles | 9–10 pt | **10 pt** | regular | Units in parentheses |
| Axis tick labels | 8–9 pt | **9 pt** | regular | No unnecessary decimals |
| Figure legends (title and text) | 8–9 pt | **9 pt** | regular | Title may be medium, not bold |
| Panel labels — a.), b.), c.) | 10–11 pt, bold | **11 pt bold** | bold | House format; use (a) only if the journal requires |
| Annotations inside plots | 8–9 pt | **9 pt** | regular | Metric boxes, arrows, callouts |
| Inset text | 7–8 pt | **8 pt** | regular | Only when the inset is small |
| Map labels | 8–9 pt | **9 pt** | regular | Place names, stations, rivers |
| Colorbar labels (title and ticks) | 8–9 pt | **9 pt** | regular | Units in the title |
| In-figure title (optional) | 10 pt | **10 pt** | regular | Prefer the caption instead |
| Caption (typeset by journal) | journal size | — | regular | Not part of the image |
| Significance marks, superscripts | 8 pt | **8 pt** | regular | Never below 7 pt |

### 1.2 Typography rules

- **One manuscript, one size scheme.** A project that adopted an earlier
  "10 pt everywhere" rule may keep it for an in-progress revision, but new
  figures use the table above. Never mix the two schemes within one
  manuscript; record which scheme a project uses in its `FIGURES.md`.

- **Font family:** Roboto throughout — titles, axis labels, ticks, legends,
  panel labels, annotations, map labels, colorbar. Fall back to Arial only if
  Roboto is not installed, and record the fallback.
- **Minimum size:** no text anywhere below **7 pt**. If a label only fits
  below 7 pt, remove the label or enlarge the panel — never shrink the type.
- **Hierarchy:** use at most three main sizes in one figure, for example
  **11** (panel labels) / **10** (axis titles) / **9** (everything secondary).
  Small insets may fall to **8**. A figure with five different sizes looks
  unfinished.
- **Panel labels:** lowercase letters in the house format **a.)**, **b.)**,
  **c.)**, bold, upper-left inside the panel, clear of the data. If a journal
  requires `(a)`, switch the whole manuscript at once — never mix formats.
- **Titles:** plain, left-aligned, 10 pt. Do not bold, underline, or centre.
- **Date format:** use the project's standard date format consistently
  (e.g. `2026-11-28` in prose; `YYYY-MM-DD` on axes).
- **Unicode:** use proper symbols — °C, mm, −, ×, ≥, ρ, η² — and check they
  survive PDF export.
- **Page context:** the default page is A4 with 2.5 cm margins, giving a
  **160 mm text width**. Design data figures at 160 mm wide.

### 1.3 Two rules that prevent most size mistakes

1. **Design at final size.** A figure designed at 160 mm and included at
   `width=\linewidth` prints at scale 1.0, so 9 pt is really 9 pt.
2. **In ggplot2, `size` is not points.** Text `size` is in millimetres
   (1 pt = 0.3528 mm). To get 9 pt, write `size = 9 / .pt`. In the theme,
   `element_text(size = 9)` *is* points and needs no conversion. This single
   difference causes most wrong-sized annotations.

---

## 2. Describing a figure — the Figure Spec Card

Every figure gets a short written description **before** it is drawn. This is
what makes the figure understandable months later and reproducible by someone
else. Keep it in the project's `FIGURES.md` register, one block per figure.

### 2.1 Required fields

| Field | What to write | Example |
|---|---|---|
| Figure ID | Manuscript number and file stem | `Fig. 4` / `fig_04_model_performance` |
| One-sentence message | What the reader must take away | "GR4J and GR6J diverge most in semi-arid catchments." |
| Figure type | Data / map / conceptual / photo / mixed | Data — multi-panel scatter |
| Source script | The one script that draws it | `02_scripts/06_generate_figures.R` |
| Input data | Files or result tables read | `03_results/model_performance_summary.csv` |
| Panels | What each panel shows, in order | a) calibration, b) validation, c) low flow |
| Encodings | x, y, colour, shape, size, facet | x = observed, y = simulated, colour = model |
| Statistics shown | Metrics, n, uncertainty, units | NSE, KGE, n = 192, 90 % band |
| Size | Width × height in mm | 160 × 110 mm |
| Export | Formats and DPI | PDF (vector) + PNG 300 dpi |
| Status | Draft / review / final + version | Final `v002` |
| Caption draft | The sentence that will go under it | "Observed versus simulated …" |

### 2.2 The eight-line description

If a full card is too much, this minimum is mandatory. It fits in a comment
at the top of the plotting script and in the register:

```text
Figure:      fig_04_model_performance
Message:     GR4J and GR6J diverge most at low flows in semi-arid catchments.
Type:        data, 3 panels (a calibration, b validation, c low-flow bias)
Data:        03_results/model_performance_summary.csv (n = 192 catchments)
Encodings:   x = observed, y = simulated; colour = model; dashed = 1:1 line
Size/export: 160 x 110 mm; PDF vector + PNG 300 dpi
Script:      02_scripts/06_generate_figures.R
Status:      final v002 (2026-11-28)
```

### 2.3 Figure register

Keep one register per project, next to the manuscript figures, named
`FIGURES.md`. One row per figure:

| Fig | File | Type | Message (short) | Script | Size (mm) | Status |
|---|---|---|---|---|---|---|
| 1 | `fig_01_study_area` | map | Study catchments and climate zones | `06_generate_figures.R` | 160 × 120 | final v002 |
| 2 | `fig_02_methodology` | conceptual | Five-stage framework | `fig02.mmd` | 160 × 90 | final v001 |
| 3 | `fig_03_model_performance` | data | Calibration vs validation skill | `06_generate_figures.R` | 160 × 110 | review v003 |

The register is the map from "figure in the manuscript" to "script and data
that produced it". Without it, figures become un-reproducible.

---

## 3. Modifying a figure — the change workflow

Never edit an exported PDF, PNG, SVG, or a figure pasted into Word. Any change
made by hand is lost the next time the figure is regenerated. All changes go
through the script.

### 3.1 The seven-step loop

1. **Write the request in plain language.** Name the figure, the panel, the
   element, and the desired result. Example: "Fig. 3, panel b: the legend
   covers the data — move it to the top; keep all text the same size."
2. **Classify the change** using the table in §3.3.
3. **Find the control.** Locate the element in the script with the map in
   §3.2. Change it there, once, in the shared theme if the change should
   apply to every figure.
4. **Regenerate only that figure** (see the project's run command; in most
   projects `TSFT_STAGES=10` or the figure-only script).
5. **Inspect at 100 %** next to the previous version. Check clipping,
   overlaps, and that nothing else moved.
6. **Run the checklist** in §14.
7. **Record it:** update the figure register row (status, version, date) and
   add a line to `PROJECT_STATUS.md` / `RUN_SUMMARY.md`.

### 3.2 Where each element is controlled

| Element | ggplot2 (R) | Matplotlib (Python) |
|---|---|---|
| Axis title | `labs(x =, y =)`; `theme(axis.title = element_text(size = 10))` | `set_xlabel(..., fontsize = 10)`; `axes.labelsize` |
| Tick labels | `theme(axis.text = element_text(size = 9))`; `scale_*()` breaks/labels | `tick_params(labelsize = 9)`; `xtick.labelsize` |
| Legend | `theme(legend.position, legend.text = element_text(size = 9), legend.title)` | `legend(fontsize = 9, loc = ...)`; `legend.fontsize` |
| Panel label | `plot.tag` in the theme, or `patchwork::plot_annotation(tag_levels = "a")` | `ax.text(...)` or `fig.text(...)`, `fontsize = 11, fontweight = "bold"` |
| Annotation in plot | `annotate("text", size = 9 / .pt)` | `ax.text(..., fontsize = 9)` |
| Inset | `patchwork::inset_element()` / `cowplot::ggdraw()` | `mpl_toolkits.axes_grid1.inset_locator` |
| Map label | `geom_text(size = 9 / .pt)` / `geom_sf_text()` | `ax.text(..., fontsize = 9)` |
| Colorbar | `guide_colourbar()` + `theme(legend.text = element_text(size = 9))` | `cbar.set_label(..., fontsize = 9)`; `tick_params(labelsize = 9)` |
| Figure size | `ggsave(width, height, units = "mm")` | `figsize = (mm/25.4, ...)` |
| Export | `ggsave(device = cairo_pdf)` + PNG `dpi = 300` | `savefig(dpi = 300, bbox_inches = "tight")` |

### 3.2.1 Common size fixes

When a figure looks wrong, the cause is usually one of these:

| Symptom | Element to change | Target |
|---|---|---|
| Tick labels crowd the axis | tick labels, and fewer breaks | 8–9 pt |
| Axis title looks small next to ticks | axis title | 10 pt |
| Legend dominates the panel | legend text and key size | 8–9 pt; key 3–4 mm |
| Panel letters are lost | panel label | 11 pt bold |
| Annotation is hard to read | annotation | 9 pt (8 pt only in dense panels) |
| Inset text is unreadable | inset text, or enlarge the inset | 7–8 pt |
| Map labels collide | map labels, and fewer labels | 8–9 pt |
| Colorbar is unreadable | colorbar title and ticks | 8–9 pt |
| Whole figure looks "off" | design width | 160 mm, scale 1.0 |

### 3.3 Change classes and what each requires

| Class | Examples | Requirement |
|---|---|---|
| **Cosmetic** | font size, colour, line width, spacing, legend position | Regenerate and re-inspect. No version bump needed, but update the date. |
| **Layout** | panel order, panel count, figure size, shared axes | Re-inspect every panel. Bump the version. Update the caption if panel letters changed. |
| **Data or method** | new data, new metric, changed axis limits, changed classification, new uncertainty band | **Stop and log the decision.** Bump the version, update the caption and the Results text, and record why in `PROJECT_STATUS.md`. |
| **Scientific interpretation** | changing what the figure claims | Treat as a research decision, not a design change. Discuss before drawing. |

### 3.4 Non-negotiable modification rules

- No manual editing of exported figures.
- No changing axis limits, data, classifications, or uncertainty bands to make
  a figure look better. That is data manipulation, not design.
- No `final`, `latest`, `new`, or `final_final` names. Use `v001`, `v002`.
- One figure, one script path. If two scripts write the same file, the figure
  is not reproducible.
- If a change is requested for one figure but applies to the manuscript,
  change the shared theme, then regenerate all figures and compare.

---

## 4. Publication-quality figure design

- Clean, minimal, professional scientific style.
- White background, no unnecessary decorative elements.
- Consistent typography, margins, spacing, line widths, and visual hierarchy
  across all figures in the manuscript.
- No unnecessary borders, shadows, gradients, 3D effects, or ornaments.
- Subtle panel separators only when they help the reader.
- Balanced whitespace; no overcrowding.
- Every element legible at the intended publication size.

---

## 5. Colour palette and accessibility

- Use perceptually uniform, colourblind-friendly palettes: Viridis, Cividis,
  Plasma, ColorBrewer, Okabe–Ito, or Tol.
- Never use rainbow or jet.
- Sequential palette for continuous variables; diverging for signed
  anomalies; qualitative for categories.
- Keep contrast sufficient against white.
- Do not rely on colour alone — add line type, shape, or pattern.
- Fix the variable-to-colour mapping once per project and reuse it. Example:
  observed = black, GR4J = blue, GR6J = orange, in every figure.
- Use the official palette for established classifications (for example the
  Beck et al. Köppen–Geiger colours) rather than inventing new ones.

---

## 6. Axes, lines, and graphical elements

- Clear axis titles with units in parentheses: `Precipitation (mm)`,
  `Temperature (°C)`, `SPEI (–)`.
- Mark dimensionless quantities with `(–)`.
- Appropriate decimal precision; do not print more digits than the data
  support.
- Axis limits scientifically justified and consistent across comparable
  panels.
- Readable tick intervals; no excessive gridlines.
- Subtle major gridlines only (about 0.3 pt, grey); no minor grid.
- Line widths: primary data 0.8–1.2 pt; reference lines 0.5–0.8 pt;
  uncertainty bands distinguishable but not overpowering.
- No truncated axes that exaggerate differences.
- Logarithmic scales only when justified and labelled.

---

## 7. Multi-panel figures

- Order panels to follow the scientific argument.
- Panel labels **a.)**, **b.)**, **c.)**, bold, 11 pt, upper-left.
- Consistent panel dimensions, alignment, and spacing.
- Shared axes where comparison is the point; do not repeat labels.
- One legend for the whole figure when panels share encodings.
- Each panel independently interpretable.
- Panel labels clear of plotted data and outside the axis tick area.
- Same spatial extent, projection, and scale for comparable maps.

---

## 8. Maps and geospatial visualisation

For hydrological, climatic, and remote-sensing maps:

- Use a projected CRS appropriate to the region; minimise distortion.
- Include a scale bar and north arrow when they aid interpretation.
- Show administrative boundaries, catchment boundaries, rivers, and reference
  features only when relevant.
- Keep extent and scale identical across comparable panels.
- Use appropriate ramps for continuous rasters.
- Legends must state units, class intervals, and missing values.
- Distinguish NoData from genuine low values.
- Avoid heavy basemaps and unnecessary annotations.
- Coordinate labels and graticules only when they help.
- Size locator maps and insets deliberately; inset text 7–8 pt.

---

## 9. Statistical and model-performance figures

For statistics, hydrological modelling, and machine learning:

- Clearly distinguish observed, simulated, predicted, and reference values.
- Show confidence, uncertainty, or prediction intervals where meaningful.
- Use reference lines: 1:1, zero, thresholds.
- Label metrics (NSE, KGE, RMSE, MAE, R², ρ) and sample size.
- Do not crowd many metrics into one panel; use a small metric table or a
  separate panel.
- Distinguish calibration, validation, and independent test periods visually
  **and** in the caption.
- Keep model–colour–shape mappings identical across figures.
- Never exaggerate small performance differences with truncated axes.
- State uncertainty and sample size.

---

## 10. Dimensions and export

- Design at final publication dimensions.
- Use the journal's column and page widths when available.
- General starting points:
  - single column: about 85–90 mm;
  - double column / full A4 text width: about 160–180 mm.
- Keep aspect ratios suited to the content.
- Raster export at least 300 dpi; 600 dpi for line-art-heavy raster figures.
- Prefer vector output for plots and diagrams.

**Preferred formats:** PDF (vector), SVG (editable), TIFF (high-resolution
raster), PNG (preview/web).

Do not use JPEG for plots containing fine lines, text, or sharp boundaries
unless the publisher requires it.

---

## 11. Reproducibility and technical quality control

- Every figure is generated by a script from documented inputs.
- No manual edits to exported figures.
- Plotting parameters live in one shared theme/configuration, not copied into
  each figure.
- Relative paths only; no machine-specific absolute paths inside scripts.
- Meaningful file names: `fig_03_spatial_distribution.pdf`.
- Embed or preserve fonts in vector files.
- Check for clipping, overlapping labels, missing legends, and wrong symbols.
- Inspect the exported file at actual print size before delivery.
- Record the figure's script, data, size, and status in `FIGURES.md`.

---

## 12. R implementation

```r
# ---- one shared theme, sourced by every figure script -----------------------
theme_publication <- function(font = "Roboto", base = 10) {
  ggplot2::theme_classic(base_size = base, base_family = font) +
    ggplot2::theme(
      text             = ggplot2::element_text(family = font, size = 9,
                                               colour = "black"),
      plot.title       = ggplot2::element_text(size = 10, hjust = 0,
                                               margin = ggplot2::margin(b = 3)),
      axis.title       = ggplot2::element_text(size = 10),
      axis.text        = ggplot2::element_text(size = 9),
      axis.ticks       = ggplot2::element_line(linewidth = 0.45),
      panel.grid.major.y = ggplot2::element_line(linewidth = 0.3,
                                                 colour = "grey88"),
      panel.grid.major.x = ggplot2::element_blank(),
      legend.title     = ggplot2::element_text(size = 9),
      legend.text      = ggplot2::element_text(size = 9),
      legend.key.size  = ggplot2::unit(3.5, "mm"),
      strip.background = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(size = 9),
      plot.tag         = ggplot2::element_text(size = 11, face = "bold"),
      plot.caption     = ggplot2::element_text(size = 8, hjust = 0),
      plot.margin      = ggplot2::margin(4, 6, 4, 4)
    )
}

# ---- final-size export in millimetres ---------------------------------------
save_fig <- function(p, name, width_mm = 160, height_mm = 100, dir = "04_figures/publication") {
  ggplot2::ggsave(file.path(dir, paste0(name, ".pdf")), p,
                  width = width_mm, height = height_mm, units = "mm",
                  device = grDevices::cairo_pdf, bg = "white")
  ggplot2::ggsave(file.path(dir, paste0(name, ".png")), p,
                  width = width_mm, height = height_mm, units = "mm",
                  dpi = 300, bg = "white")
}
```

Also:

- `ggplot2` for statistical plots; `sf`, `terra`, `tmap` for geospatial.
- `patchwork` or `cowplot` for multi-panel assembly.
- `showtext` + `sysfonts` to register Roboto on every device.
- `annotate(..., size = 9 / .pt)` for point-sized text.

---

## 13. Python implementation

```python
import matplotlib as mpl
import matplotlib.pyplot as plt

mpl.rcParams.update({
    "font.family": "Roboto",
    "font.size": 9,
    "axes.titlesize": 10,
    "axes.labelsize": 10,
    "xtick.labelsize": 9,
    "ytick.labelsize": 9,
    "legend.fontsize": 9,
    "legend.title_fontsize": 9,
    "figure.dpi": 150,
    "savefig.dpi": 300,
    "savefig.bbox": "tight",
    "pdf.fonttype": 42,      # embed TrueType fonts
    "ps.fonttype": 42,
})

# panel label
ax.text(0.02, 0.98, "a.)", transform=ax.transAxes,
        fontsize=11, fontweight="bold", va="top", ha="left")

# final-size figure: 160 x 100 mm
fig, axes = plt.subplots(1, 2, figsize=(160/25.4, 100/25.4))
fig.savefig("fig_03_model_performance.pdf")
fig.savefig("fig_03_model_performance.png", dpi=300)
```

Use Matplotlib, GeoPandas, Cartopy, and Contextily as appropriate, keeping
the same element sizes and palette rules.

---

## 14. Final publication checklist

Before delivering any figure, verify:

- [ ] Roboto is applied everywhere (or the Arial fallback is recorded).
- [ ] Axis titles are 9–10 pt.
- [ ] Tick labels are 8–9 pt.
- [ ] Legend text is 8–9 pt.
- [ ] Panel labels are 10–11 pt, bold, `a.)` style, clear of the data.
- [ ] Annotations are 8–9 pt; inset text is 7–8 pt.
- [ ] Map labels and colorbar labels are 8–9 pt.
- [ ] No text anywhere is below 7 pt.
- [ ] At most three main text sizes are used (panel 11 / axis 10 / rest 9;
      small insets may use 8).
- [ ] Palettes are colourblind-safe and mapped consistently.
- [ ] Axis labels carry units; `(–)` marks dimensionless quantities.
- [ ] Legends are clear, concise, and correctly placed.
- [ ] Nothing is clipped or overlapping.
- [ ] Multi-panel layouts are aligned.
- [ ] Maps use a sensible projection, scale, and NoData treatment.
- [ ] Uncertainty is shown where scientifically relevant.
- [ ] Figure dimensions match the target publication format.
- [ ] Vector or 300 dpi raster files are exported.
- [ ] The figure was inspected at 100 % / actual print size.
- [ ] The figure register row is updated (script, data, size, status).

---

## 15. Priority rule

Scientific accuracy and interpretability always take priority over visual
aesthetics.

Never modify data, statistical relationships, axis scales, spatial boundaries,
classifications, or uncertainty representations merely to improve appearance.

The objective is publication-ready scientific figures that are accurate,
reproducible, visually consistent, accessible, and suitable for peer-reviewed
journals in hydrology, water resources, remote sensing, climate science, and
environmental modelling.
