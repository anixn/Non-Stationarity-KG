# Figure Spec Template

> Copy this file into a project as `FIGURES.md` (or into
> `05_documents/` / the manuscript `figure-spec/` folder). Keep **one register
> table** for the whole project, and **one card per figure** below it.
> Rules and sizes: `scientific_figure_standard.md`.

---

## 1. Figure register (one row per figure)

| Fig | File stem | Type | One-sentence message | Script | Size (mm) | Status |
|---|---|---|---|---|---|---|
| 1 | `fig_01_study_area` | map | Study catchments and climate zones | `02_scripts/06_generate_figures.R` | 160 × 120 | final v002 |
| 2 | `fig_02_framework` | conceptual | Five-stage analysis framework | `fig02_framework.mmd` | 160 × 90 | final v001 |
| 3 | | | | | | |

Status values: `draft` → `review` → `final`. Add a version (`v001`, `v002`)
when the figure changes after review.

---

## 2. Figure card

Copy the block below for each figure. Delete nothing that applies.

```markdown
### Fig. NN — short title

| Field | Value |
|---|---|
| File stem | `fig_NN_short_name` |
| One-sentence message | |
| Figure type | data / map / conceptual / photo / mixed |
| Manuscript location | Section X.Y, page N |
| Source script | `02_scripts/06_generate_figures.R` |
| Input data | `03_results/____.csv` |
| Number of panels | 1 / 2 / 3 / 4 |
| Panel content | a) … b) … c) … |
| x encoding | |
| y encoding | |
| Colour encoding | |
| Shape / line / facet encoding | |
| Statistics shown | metric(s), n, uncertainty, units |
| Annotations | panel labels, metric boxes, arrows |
| Design size | 160 × ___ mm |
| Export | PDF (vector) + PNG 300 dpi |
| Palette | viridis / Okabe–Ito / diverging / classification palette |
| Caption draft | |
| Status / version | draft v001 |
| Last checked | YYYY-MM-DD |
```

---

## 3. Worked example

```markdown
### Fig. 4 — Model performance at low flows

| Field | Value |
|---|---|
| File stem | `fig_04_model_performance` |
| One-sentence message | GR4J and GR6J differ most at low flows in semi-arid catchments. |
| Figure type | data |
| Manuscript location | Section 4.2, page 11 |
| Source script | `02_scripts/06_generate_figures.R` |
| Input data | `03_results/model_performance_summary.csv` (n = 192) |
| Number of panels | 3 |
| Panel content | a) calibration 1:1, b) validation 1:1, c) low-flow bias by aridity |
| x encoding | observed streamflow (mm/day); aridity index (–) in c |
| y encoding | simulated streamflow (mm/day); bias (%) in c |
| Colour encoding | model: GR4J `#0072B2`, GR6J `#D55E00` |
| Shape / line / facet encoding | dashed 1:1 line; shape = model in c |
| Statistics shown | median KGE per period; n = 192; 90 % band in c |
| Annotations | bold `a.)`, `b.)`, `c.)`; metric box in a and b |
| Design size | 160 × 110 mm |
| Export | PDF (vector) + PNG 300 dpi |
| Palette | Okabe–Ito, fixed model colours |
| Caption draft | Observed versus simulated daily streamflow for (a) calibration and (b) validation; (c) low-flow bias against aridity. |
| Status / version | review v002 |
| Last checked | 2026-11-28 |
```

---

## 4. Before marking a figure `final`

- [ ] Card complete, including data file and script.
- [ ] Script draws it from `03_results/`, not from typed numbers.
- [ ] Sizes follow the element table (axis 9–10, ticks 8–9, legend 8–9,
      panel label 10–11 bold, annotation 8–9, inset 7–8, map 8–9,
      colorbar 8–9).
- [ ] No text below 7 pt.
- [ ] At most three main text sizes (panel 11 / axis 10 / rest 9; inset 8).
- [ ] Designed at final width; inspected at 100 %.
- [ ] PDF vector + 300 dpi PNG exported.
- [ ] Register row updated with status and version.
- [ ] Caption matches the panels as drawn.
