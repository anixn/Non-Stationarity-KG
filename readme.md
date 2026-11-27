 [CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md) | [HELP](./help.md) | [STATUS](./PROJECT_STATUS.md)

# CZIPEF — project structure

Revision 1 of HYDROL72949. The analysis lives in `01-analysis/R/`; nothing else
in the project is executable. Superseded code and outputs were removed on
20 Nov 2026 and 27 Nov 2026 (old multi-country data files, pandoc LaTeX build,
stale run logs), so the tree below is the complete working set.

The project follows the toolkit standards archived in
[`00_project-info/standards/`](00_project-info/standards/) (file/folder
management, scientific figure standard, project-status template); how they
map onto this tree is recorded in
[`00_project-info/project_structure.md`](00_project-info/project_structure.md).
Session-level status: [`PROJECT_STATUS.md`](PROJECT_STATUS.md).

```
├───📁 00_project-info        ← standards archive + structure map
├───📁 01-analysis
│   ├───📁 R                  ← revision pipeline (00_config … 10_figures, run_all.R)
│   └───📁 data               ← catchment list, KG class table + classifier
│
├───📁 02-outputs
│   ├───📁 revision           ← production products (run_all.R writes here)
│   │   ├───📁 figures        ← data figures (Roboto 10 pt standard; PDF + PNG 300 dpi)
│   │   └───📁 tables         ← T3–T9 auto-generated
│   └───📁 reference          ← two legacy files used for the CART cross-check
│
├───📁 03-writeup
│   ├───📁 Revision-1         ← manuscript (docx), tables, SI, responses, LaTeX build
│   │   └───📁 latex-v2       ← ★ current build: real BibTeX, prior-art update,
│   │                             figure-spec set, synced captions (manuscript.pdf, 50 pp)
│   ├───📁 prior-art          ← WOS search corpus + literature-gap notes
│   ├───📁 references         ← KG_Bibliography.bib
│   └───📝 …
│
├───📝 PROJECT_STATUS.md      ← standing status + session history (toolkit template)
├───📝 concept.md             ← research idea, filled and current
├───📝 readme.md              ← this file
├───📝 todo.md
├───📝 updates.md             ← dated work journal
├───📝 help.md                ← ★ writing-session help (keypoints, cheat-sheet, figure map)
└───📝 PROJECT_STATUS.md      ← session history incl. per-workstream status (toolkit template)
```

## Where to start

- **Project status (toolkit template):** [`PROJECT_STATUS.md`](PROJECT_STATUS.md)
- **Writing session:** [`help.md`](help.md) — simple-language summary, editor keypoints,
  number cheat-sheet, figure/table map, terminology rules.
- Pipeline manual: [`01-analysis/R/README.md`](01-analysis/R/README.md)
- Current LaTeX build: [`03-writeup/Revision-1/latex-v2/README.md`](03-writeup/Revision-1/latex-v2/README.md)
  (figures: [`latex-v2/figure-spec/FIGURES.md`](03-writeup/Revision-1/latex-v2/figure-spec/FIGURES.md))
- Manuscript edit log: [`03-writeup/Revision-1/Manuscript-Edit-List.md`](03-writeup/Revision-1/Manuscript-Edit-List.md)
- Response notes: [`03-writeup/Revision-1/Response-to-Reviewers-Notes.md`](03-writeup/Revision-1/Response-to-Reviewers-Notes.md)
- Indicator and KG-map decisions: [`03-writeup/Revision-1/Indicator-and-KG-Map-Decisions.md`](03-writeup/Revision-1/Indicator-and-KG-Map-Decisions.md)
- Prior-art gap analysis: [`03-writeup/prior-art/LITERATURE_GAP_UPDATE.md`](03-writeup/prior-art/LITERATURE_GAP_UPDATE.md)

## Run

```powershell
Rscript 01-analysis/R/run_all.R
```

Stages resume from disk, so re-running is cheap; set `TSFT_STAGES` to restrict
the run (for example `TSFT_STAGES=10` to redraw figures only).

## Housekeeping

- The production run writes only to `02-outputs/revision/`.
- `02-outputs/reference/` holds exactly two inputs for the CART cross-check
  (`CART/ORIG/MAR_DP_DT.csv` and `Step05_BhvPsets_205.RData`). If the
  cross-check is dropped, stage 08 skips it automatically and the folder can go.
- Project size is ~92 MB, down from ~1.4 GB before the revision.
