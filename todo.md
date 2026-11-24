 [CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md)


# Todo List for Paper

📅 Updated: 19 November 2026

## 🔴 Revision 1 — high priority (reviewer-driven)

- [x] Read and map Reviewer #2 and Reviewer #4 comments
      (`03-writeup/Revision-1/Diagnosis-and-Rework-Plan.md`)
- [x] Rebuild the analysis as a modular R pipeline (`01-analysis/R/`)
- [x] Fix result-changing code bugs (PET units, routing, KDE, thresholds,
      dimnames, column labels, SAF, CART parsing)
- [x] Add temporal validation (split-sample + moving windows)
- [x] Add climate-vs-physiography attribution
- [x] Add observed decadal Köppen–Geiger transitions
- [x] Replace the CART threshold with isotonic/logistic estimators + bootstrap
- [x] Separate sensitivity (PRCC/Sobol) from uncertainty (ensemble spread)
- [x] Add calibration diagnostics table and figure
- [x] Draft response-to-reviewers notes
- [x] Clean and reorganise the project (legacy archived, ~1 GB of superseded
      simulation dumps removed, production/smoke/reference separated)
- [x] Make MAR primary and report LFI and MAMF alongside it, with one
      direction-aware classifier (`vuln_class`) for all three
- [x] Build the KG map with the Beck et al. (2023) class scheme and delta-change
      logic; add the +1.5/+2/+3/+4 °C maps and the official palette
- [x] Run the full pipeline on all 332 candidate catchments (production run,
      19-20 Nov 2026, `02-outputs/revision_run.log`); 222 pass calibration
- [x] Apply the first manuscript text pass (Methods: period, PET units,
      calibration criteria, class boundaries, three indicators, copula,
      CART-as-cross-check, fallback rule, conclusions)
- [x] Fill the number placeholders in the manuscript from the production run
      (`03-writeup/Revision-1/Manuscript-Edit-List.md`, section B)
- [x] Rewrite Results paragraphs P107/P111/P112/P123/P124/P126/P128 from the
      new tables and figures
- [x] Regenerate all figures and tables from the full run
- [x] Update manuscript numbers (222 analysed of 332; MAR 38/34/28 decomposition)
- [x] Rewrite Methods §3.1–3.8 to mirror the code
- [x] Add limitations paragraph (climate is not the only control; synthetic scenarios)
- [x] Replace “new paradigm” with “first step”
- [x] Final terminology pass (“model parameters” vs “behavioural parameter sets”)

## 🟡 Revision 1 — decisions taken

- [x] Routing stays enabled; MAXBAS is identifiable because the routing bug is fixed
- [x] MAR is primary; LFI and MAMF are reported alongside it
      (`03-writeup/Revision-1/Indicator-and-KG-Map-Decisions.md`)
- [x] Beck et al. (2023) classes are used as a delta-change scheme for the KG
      map; no raster comparison is claimed
- [x] Analysed sample = whatever passes calibration (~300); manuscript says so
- [x] KG delta-change map grid = ΔP −50%/0/+50% × ΔT +1.5/+2/+3/+4 °C
- [x] Manuscript also maintained in LaTeX (`03-writeup/Revision-1/latex/`)

## 🟢 Low Priority
- [ ] Add a supplementary table of all calibration metrics
- [ ] Add a robustness test with an alternative PET method
- [x] Delete `02-outputs/legacy/`, `02-outputs/smoke/`, the old `.Rmd` chain and
      the superseded CART PDFs (20 Nov 2026; project now 128 MB)
