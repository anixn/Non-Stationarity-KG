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
| `04_figures/` | `02-outputs/revision/figures/` (working + manuscript copies in `03-writeup/Revision-1/latex-v2/`) |
| `05_documents/` | `03-writeup/` (manuscript, responses, SI) |
| `06_references/` | `03-writeup/references/` + `03-writeup/prior-art/` |
| `07_archive/` | `02-outputs/legacy/` (superseded runs) |

## Standing conventions (from the standards)

- Names: lowercase snake_case files, kebab-case custom folders, `YYYYMMDD`
  dates in filenames when useful, `v001`-style versions for deliverables.
- Data: raw inputs never modified; originals stay in
  `01-analysis/data/` and external datasets under `D:/OneDrive/Research/Datasets/`
  (documented in `01-analysis/R/00_config.R`, not copied into the repo).
- Scripts: numbered execution order, all paths from `00_config.R`, seeds
  recorded (`SEED <- 20251119`), outputs regenerable via `run_all.R`.
- Figures: follow `standards/scientific_figure_standard.md` — Roboto 10 pt,
  bold `a.)`/`b.)` panel labels where panels carry distinct content,
  colourblind-safe fixed palettes, units in parentheses, designed at 160 mm
  (A4, 2.5 cm margins), vector PDF + 300 dpi PNG, generated only from
  `10_figures.R`. Implemented centrally in `theme_publication()`; per-figure
  details in `03-writeup/Revision-1/latex-v2/figure-spec/TYPOGRAPHY_SPEC.md`.
- Status: `PROJECT_STATUS.md` at the repo root follows
  `standards/project_status_template.md`; update it at the end of every
  substantive session, newest session on top in the session history.
- Manuscript figures embedded in the LaTeX build are copies: after
  regenerating figures, copy `02-outputs/revision/figures/*.png` to
  `03-writeup/Revision-1/latex-v2/si/` (S1–S10) and to
  `03-writeup/Revision-1/latex-v2/media/media/` (image1/2 = FA/FB,
  image8–14 = F4b/F14/F8b/F8/F9/F13/F10), then rebuild the PDF
  (see `03-writeup/Revision-1/latex-v2/README.md`).
