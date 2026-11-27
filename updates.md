 [CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md) | [HELP](./help.md) | [STATUS](./PROJECT_STATUS.md)

# Weekly Research Journal Update

> 24 November 2026 | Tuesday | Figure/caption/text sync + writing help docs
- Audited every figure caption and cross-reference in
  `03-writeup/Revision-1/latex-v2/manuscript.tex` against the rendered figures
  and the pipeline tables (T3–T9b); fixed all mismatches:
  - Figs 1–2 (new ggplot maps): captions and body text rewritten to the actual
    legends (Fig 2: red cross = 222 analysed, blue = 110 candidate-only — the
    old text inverted the legend).
  - Fig 6 (now the estimator + CART cross-check workflow, not the rpart tree):
    caption and §3.1 text rewritten; the stale "USID: 01439500 / dashed red
    line" description removed.
  - Figs 11–12 (now three panels MAR/LFI/MAMF): captions and Results text
    updated; added panel-level decomposition from T8 (LFI 2/17/22, slope 0.76,
    R2 = 0.50; MAMF 3/4/10, slope 1.33, R2 = 0.77).
  - Fig 7 caption rewritten (was garbled); Fig 3 caption now points to the
    isotonic/logistic + CART implementation; Fig 4 note added for the fixed
    snow constants CFR/CWH/SP that Table 2 does not list.
- Text–table fixes: "+2 °C between 16% and 37%" → 24–37% (T5b); MAR
  significance claims aligned with T9 (CFMAX not significant in Cfb; LFI
  recurring = beta, LP, k2); Table 6 ΔR² sentence now 0.06–0.09 (p < 0.01)
  for beta/LP/TT/k2 and 0.06 for PERC with MAXBAS/CFMAX not significant;
  "three to six parameters per indicator" scoped to MAR; "Table 7" →
  "Tables 7 and 7b"; MAXBAS added to the physiography lists in 5.1/5.2.
- Mechanics: removed the duplicated SPF paragraph (§3.1), renamed PBE →
  PBIAS in eq. (5), fixed the dangling sentence before Fig. 7, grammar pass
  (LHS/PET/calibration sentences), `$\\pm$` → `$\pm$` in the S3 caption,
  unified R2 → R$^2$ everywhere.
- Rebuilt `manuscript.pdf`: 50 pages, zero unresolved citations, zero
  overfull boxes; 3 cosmetic bibtex warnings (as before).
- Writing-session documentation: new `help.md` (simple-language summary,
  3–4 editor keypoints, "what to highlight", number cheat-sheet traceable to
  tables, figure/table map, terminology rules, reviewer-proofing limits,
  build commands) and `progress.md` (per-workstream status); filled
  `concept.md` (was an empty template); updated `readme.md`, `todo.md`.
- Git: committed and pushed as "Sync figure captions/text with rendered
  figures and tables; add writing-session help docs".

> 20 November 2026 | Friday | Project cleanup
- Removed the superseded code and outputs (moved to the temp trash folder, so
  recoverable for now):
  - `01-analysis/legacy-rmd/` — the old Step01–Step09 R Markdown chain (26 files).
  - `01-analysis/data/HBV Model Run/` — the old standalone HBV R scripts.
  - `02-outputs/legacy/` — 343 archived output files (205 MB).
  - `02-outputs/smoke/`, `02-outputs/smoke_attr/` and the smoke log.
  - `02-outputs/reference/CART/TSFT/` and the per-catchment CART PDFs under
    `CART/ORIG/` (823 unused figures); the MAR/LFI/MAMF `*_DP_DT.csv` aggregates
    and `Step05_BhvPsets_205.RData` are kept because stage 08 reads them.
  - `03-writeup/legacy/` — old manuscript versions, submitted PDF and the
    journal LaTeX template (29 MB).
- Project is now 864 files / 128 MB (from ~1.4 GB). The pipeline still resolves
  every input: catchment list, KG classifier, Caravan attributes, CART
  cross-check, tables and figures directories.
- Updated `readme.md`, `01-analysis/R/README.md` and `todo.md` to the new tree.

> 20 November 2026 | Friday | Revision 1 - production results in the manuscript
- Full 332-candidate production run completed (stages 02-10, zero failures):
  222 catchments pass calibration (KGE >= 0.5, |PBIAS| <= 25%, >= 50 sets).
- Applied the number and prose pass to the manuscript: Abstract, P34, P85, P86,
  P89, P95-P97, P100, P106, P107, P111, P112, P116, P117, P121-P124, P126,
  P128, P130, P132 and all figure captions.
  - 205 -> 222; 304 -> 332; removed 56%, 20/36/44%, 116/89, y = 0.235 + 0.654x.
  - MAR decomposition: 83 higher / 74 lower / 60 equal of 217 (38.2/34.1/27.6),
    slope 0.309, R2 = 0.14, binomial p = 0.52.
  - Split sample: 0.582 -> 0.574 forward, 0.593 -> 0.550 reverse; 69.8/65.3%
    still behavioural.
  - KG: 20.7% observed decadal transitions, 91.9% any scenario transition;
    12-panel delta-change map (16-58% class change).
- Added a Results paragraph on parametric uncertainty (MAR CV 5-11% vs LFI
  50-228%) to explain the LFI/MAMF identifiability.
- Figures: new F14 prevalence surface (manuscript Fig. 9), F4b now manuscript
  Fig. 8, F8b/F8/F9/F13/F10 map to Figs 10-14; SI figures S1-S10 appended in
  LaTeX.
- Built `03-writeup/Revision-1/Tables-R1.docx` (Tables 3-9, landscape).
- LaTeX: `build_all.ps1` now scales figures to the line width, strips duplicated
  caption numbers, disables duplicate section numbering, maps U+2264 and appends
  the SI figures and tables. `build/manuscript.pdf`: 57 pages, no missing
  characters.
- Updated `Manuscript-Edit-List.md` (A/B/C/D complete, figure map, table notes)
  and `Response-to-Reviewers-Notes.md` (all numbers filled).

> 19 November 2026 | Thursday | Revision 1 - manuscript text pass
- Applied the first text pass to `03-writeup/Revision-1/Deshmukh_2025_KG_R1.docx`
  (24 sentence-level edits; 233 paragraphs, 8 tables, 576 citation fields and
  55 equations preserved):
  - 1981–2010 everywhere; “304 candidate” vs the analysed sample.
  - Beck et al. (2023) described as a class scheme plus delta-change logic.
  - 0.408 MJ m⁻² d⁻¹ PET conversion stated.
  - Calibration now described as 10,000 LHS, KGE ≥ 0.5, |PBIAS| ≤ 25%,
    NSE reported but not used to screen, 200 sets retained, < 50 excluded.
  - Class boundaries corrected; LFI and MAMF added with their directions and
    MAR marked primary.
  - CART demoted to a cross-check; isotonic/logistic estimator described.
  - KDE replaced by the Gaussian copula resampler in Methods, P81 and P83.
  - Fallback rule replaced the old “ET > 10%” exclusion rule.
  - “first framework”, “death of stationarity” and “sets a new standard”
    removed from the conclusions.
- Decisions confirmed by the author:
  - the analysed sample is whatever passes calibration (expected ~300, not the
    legacy 205) and the manuscript says so;
  - the KG delta-change map uses the study's own ΔP range, −50% to +50%
    (dp = 0.5, 1.0, 1.5) × +1.5/+2/+3/+4 °C, i.e. 12 panels; the KG-map stage
    is re-run with this grid after the production run;
  - the manuscript is built with LaTeX as well as the docx.
- Set up the LaTeX build (`03-writeup/Revision-1/latex/`): pandoc docx→tex,
  preamble injection, booktabs tables from the pipeline CSVs (`make_tables.R`)
  and a compiling PDF via latexmk; see `latex/README.md`.
- Wrote `03-writeup/Revision-1/Manuscript-Edit-List.md`: what was applied, which
  numbers are still placeholders, and which Results paragraphs need rewriting.
- Validated stages 02–06 on a 60-catchment subset (separate
  `02-outputs/smoke_attr/`), including split-sample validation, moving-window
  drift, variance partitioning, nested models and random-forest importance.
- Started the full 205-catchment production run into `02-outputs/revision/`
  (log: `02-outputs/revision_run.log`).

> 19 November 2026 | Thursday | Revision 1 — cleanup and indicator decisions
- Reorganised the project: legacy R Markdown archived under
  `01-analysis/legacy-rmd/`; superseded outputs split into `02-outputs/legacy/`
  and `02-outputs/reference/`; production products isolated in
  `02-outputs/revision/`; smoke tests now go to `02-outputs/smoke/`.
- Removed ~1 GB of obsolete per-catchment simulation dumps and old figures.
- Fixed the author decisions:
  - MAR is the primary indicator; LFI and MAMF are computed, thresholded and
    reported alongside it with one direction-aware classifier.
  - The KG map uses the Beck et al. (2023) class scheme and delta-change logic
    (+1.5/+2/+3/+4 °C, official RGB palette), not a raster comparison.
- Added `Indicator-and-KG-Map-Decisions.md` and updated the pipeline README.
- Smoke-tested stages 02, 04, 06, 07, 08, 09, 10 on three catchments: all
  three indicators appear in T7/T8, the delta-change KG map runs, and the new
  F4b/F8/F9/F10b/F12 figures render.

> 19 November 2026 | Thursday | Revision 1
- Read the rejection report (`Review/cmt_ACLI.md`) and mapped every comment to an action.
- Diagnosed the current pipeline. Result-changing bugs found:
  - Hargreaves PET missing the 0.408 conversion (PET ≈ 2.45× too high).
  - HBV routing used MATLAB `end`, so routing was disabled and MAXBAS was inert.
  - KDE reset the RNG per parameter, produced out-of-range values, and ignored correlations.
  - CART thresholds were parsed from text and the node weights were misaligned.
  - Step03 dimnames were overwritten; Step04 saved KGE under the NSE header.
- Built a clean modular pipeline in `01-analysis/R/` (stages 00–10) and documented it.
- Added the missing analyses: split-sample/moving-window validation, climate-vs-physiography
  attribution, observed KG transitions, robust thresholds, and separated sensitivity/uncertainty.
- Smoke-tested the full chain on 3 catchments (calibration → KG → pools → scenarios →
  thresholds → sensitivity → figures). The full 205-catchment run is next.

> 04 April 2025 | Friday | Week 14 |
- Analysis is started. 4 classifiers as selected and Water area is defined.
- All the analysis figures are prepared and hypothesis are tested.

> 19 April 2025 | Saturday | Week 16
- Put all the data in the word document.
- Arranging the content and final writeup.
- Making the pieces in order.

