# RUN SUMMARY

> **Purpose:** a newest-first log of every run, written in plain language, so
> the project's progress can be understood without reading code or logs.
>
> **Companion files:** `00_project-info/standards/working_file.md` §6 (the
> method), `PROJECT_STATUS.md` (project state), `FIGURES.md` (figure register).

**Project:** `202505_Non_Stationarity_KG` — Revision 1 of HYDROL72949
**Last updated:** 2026-11-28 08:56

---

## 2026-11-28 08:34 — Figures rebuilt to standard v2; manuscript figures consolidated

**Command run:**
`$env:TSFT_STAGES="10"; Rscript 01-analysis/R/run_all.R` then
`pdflatex … manuscript.tex` (×3) + `bibtex manuscript`
**Result:** Completed

### What ran

Rebuilt all 19 data figures with the v2 element-size table (axis 10 pt;
ticks, legends, strips, colorbars 9 pt; panel labels 11 pt bold), re-laid out
Fig. 7 as two panels, moved all publication figures into one folder, and
rebuilt the manuscript with vector-PDF includes.

### What changed

| File | Change |
|---|---|
| `01-analysis/R/10_figures.R` | `theme_publication()` moved from "10 pt everywhere" to the v2 size table; panel tags 11 pt bold |
| `02-outputs/revision/figures/*` | 19 data figures regenerated (PDF + PNG), 2026-11-28 |
| `02-outputs/revision/figures/fig3–7_*` | conceptual PDF/PNG moved here from `latex-v2/figures/` |
| `02-outputs/revision/figures/fig7_kg_parameter.*` | re-rendered as a two-panel figure, 160 × 134 mm (was 160 × 420 mm) |
| `03-writeup/Revision-1/latex-v2/manuscript.tex` | 24 includes repointed and switched from PNG to vector PDF; Figs. 3 and 7 re-laid out as two panels |
| `03-writeup/Revision-1/latex-v2/media/`, `si/` | removed — duplicate copies of the same 24 figures |
| `03-writeup/Revision-1/latex-v2/figure-spec/fig7_kg_parameter.{mmd,svg}` | source updated to the two-panel layout |
| `FIGURES.md` | new live register at the project root (14 main + 10 supplementary rows, one card per main figure) |
| `03-writeup/Revision-1/latex-v2/figure-spec/TYPOGRAPHY_SPEC.md` | rewritten to the v2 size table |
| `manuscript.pdf` | rebuilt: 50 pages, 7.1 MB |

### Key numbers

| Item | Value | Where |
|---|---|---|
| Data figures regenerated | 19 (FA, FB, F1–F14 incl. F4b, F8b, F10b) | `02-outputs/revision/figures/` |
| Main-text figures | 14 | `manuscript.tex` |
| Supplementary figures | 10 (S1–S10) | `manuscript.tex` |
| Figure includes now vector PDF | 24 of 24 | `manuscript.tex` |
| Manuscript length | 50 pages | `manuscript.pdf` |
| Float / missing-file warnings | 0 | `manuscript.log` |

### What it means

Every manuscript figure now prints at the sizes the standard specifies, the
smallest in-figure text is ≥ 8 pt, and the PDF embeds vector plots instead of
raster copies. No data, statistics, thresholds or interpretation changed. Figs. 3 and 7
are the only layout changes: both are now two panels that fit one page at a
readable size (Fig. 3: a scenarios/model, b indicators/map; Fig. 7:
a zone pooling, b scenario re-sampling).

### Checks performed

- [x] Script exited without error (stage 10, ~0.4 min)
- [x] All 19 figure files carry the 2026-11-28 timestamp
- [x] All 24 `\includegraphics` targets exist and resolve
- [x] No "Float too large", "not found" or undefined-reference warnings
- [x] Rebuilt pages inspected at 100 %: Figs. 1–14, 3, 7
- [x] Root `FIGURES.md` matches the files actually used by the manuscript

### Problems and warnings

- Stage 10 still emits the known `ggplot2` warnings about non-finite values
  removed from F1 and missing ribbon rows in F3; these predate this run and
  do not change the plotted samples.
- The two tall conceptual diagrams (Figs. 3 and 7) were re-laid out as two
  panels so they fit one page and all labels stay at or above 8 pt.
- The docx submission copy was not updated (only the LaTeX build was).

### Status now

Stage: Figures / Writing
Done: figures rebuilt to v2, single figure folder, vector manuscript build.
Not done: mirror the new figures/captions into the R1 docx if that is the
submission vehicle; journal bibliography style.

### Next action

Decide whether the docx or `latex-v2/manuscript.pdf` is the submission
vehicle; if docx, replace its embedded Figs. 1–14 and S1–S10 with the new
PDF/PNG exports.

---

## 2026-11-27 17:15 — Figures rebuilt to the project standard (v1)

**Command run:** `$env:TSFT_STAGES="10"; Rscript 01-analysis/R/run_all.R`
**Result:** Completed

### What ran

First pass at the project figure standard: central `theme_publication()`,
Roboto 10 pt, bold `a.)` panel labels, fixed colourblind-safe palettes,
160 mm design width, 19 data figures redrawn, LaTeX copies refreshed.

### Key numbers

| Item | Value | Where |
|---|---|---|
| Data figures regenerated | 19 | `02-outputs/revision/figures/` |
| Manuscript length | 50 pages | `manuscript.pdf` |

### What it means

Established one theme and one palette mapping for every figure. The "10 pt
everywhere" scheme used here was superseded on 2026-11-28 by the v2 element
table, so these figures were redrawn again.

### Problems and warnings

Facet-order, clipped-axis-title and tick-crowding issues were fixed during
the run. No statistical results changed.

### Status now

Stage: Figures
Done: consistent figure style.
Not done: element-size hierarchy (fixed 2026-11-28).

### Next action

Adopt the v2 element table when the new standards copy is available.
