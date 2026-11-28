# Project structure map (kept up to date)

> This file is the standing record of how this project maps onto the generic
> research standard in `standards/`. Read it at the start of every session,
> together with `../readme.md` and `../PROJECT_STATUS.md`.

## Why the folders differ from the generic template

The generic standard defines `00_project-info/ … 07_archive/`. This project
predates it and already uses a numbered, working structure that the pipeline
paths (`01-analysis/R/00_config.R`) depend on. Per the standard's own rule
("preserve an existing logical structure rather than reorganizing it
unnecessarily"), the existing tree is kept and the generic roles are mapped
onto it:

| Generic standard folder | This project |
|---|---|
| `00_project-info/` | `00_project-info/` (this file + `standards/`) |
| `01_data/` | `01-analysis/data/` (catchment lists, attributes, KG classifier, bibliography) |
| `02_scripts/` | `01-analysis/R/` (00_config … 10_figures, run_all.R) |
| `03_results/` | `02-outputs/revision/` (production products, incl. `tables/`) |
| `04_figures/` | `02-outputs/revision/figures/` (single publication folder; PDF + PNG) |
| `05_documents/` | `03-writeup/` (manuscript, responses, SI) |
| `06_references/` | `03-writeup/Revision-1/KG_Bibliography.bib` + `03-writeup/prior-art/` |
| `07_archive/` | `02-outputs/legacy/` (superseded runs) |

## Standing conventions (from the standards)

- Names: lowercase snake_case files, kebab-case custom folders, `YYYYMMDD`
  dates in filenames when useful, `v001`-style versions for deliverables.
- Data: raw inputs never modified; originals stay in
  `01-analysis/data/` and external datasets under `D:/OneDrive/Research/Datasets/`
  (documented in `01-analysis/R/00_config.R`, not copied into the repo).
- Scripts: numbered execution order, all paths from `00_config.R`, seeds
  recorded (`SEED <- 20251119`), outputs regenerable via `run_all.R`.
- Figures: follow `standards/scientific_figure_standard.md` v2 — axis titles
  10 pt; ticks, legends, strips and colorbars 9 pt; panel labels 11 pt bold
  (`a.)`); annotations 9 pt; colourblind-safe fixed palettes; units in
  parentheses; designed at 160 mm (A4, 2.5 cm margins); vector PDF + 300 dpi
  PNG; generated only from `10_figures.R` (data) or the `.mmd` sources
  (conceptual). Implemented centrally in `theme_publication()`; rules in
  `03-writeup/Revision-1/latex-v2/figure-spec/TYPOGRAPHY_SPEC.md`.
- Figure register: the live register is the repo-root `FIGURES.md` (one row
  per main and supplementary figure + one eight-line card per main figure).
- Status: `PROJECT_STATUS.md` at the repo root follows
  `standards/project_status_template.md`; update it at the end of every
  substantive session, newest session on top in the session history.
- Manuscript figures: `manuscript.tex` includes the PDFs in
  `02-outputs/revision/figures/` directly (main Figs. 1–14 and SI S1–S10).
  There are no per-build figure copies; the old `latex-v2/media/media/` and
  `latex-v2/si/` folders were removed on 2026-11-28. The conceptual `.mmd`
  and `.svg` sources stay in `latex-v2/figure-spec/`.
