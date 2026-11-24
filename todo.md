 [CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md)


# Todo List for Paper

📅 Updated: 24 November 2026

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
- [x] Analysed sample = 222 of 332 candidates; manuscript says so
- [x] KG delta-change map grid = ΔP −50%/0/+50% × ΔT +1.5/+2/+3/+4 °C
- [x] Manuscript also maintained in LaTeX (`03-writeup/Revision-1/latex-v2/`,
      current build with real BibTeX and the prior-art update)

## 🟢 Figure / caption / documentation sync — done 24 Nov 2026

- [x] Render the five conceptual figures from `latex-v2/figure-spec/*.mmd`
      (pele → flattened SVG → rsvg PDF/PNG) and wire into `manuscript.tex`
- [x] Audit every figure caption against the rendered figure; sync stale
      captions (Figs 1–2 legend direction, Fig 6 workflow vs tree, Fig 7
      garbled caption, Figs 11–12 three-panel layout, Fig 3/CART note,
      Fig 4 fixed CFR/CWH/SP constants)
- [x] Fix text–table mismatches: +2 °C class-change range (24–37%), Table 9
      significance claims (CFMAX not in Cfb; LFI recurring = beta/LP/k2),
      Table 6 ΔR² sentence with p-values, "three to six parameters" scoped
      to MAR, Table 7 → Tables 7/7b
- [x] Remove duplicated SPF paragraph; PBE → PBIAS in eq. (5); unify R²
      typography; fix `$\\pm$` bug in the S3 caption; grammar pass in
      §2, §3.1, §3.2
- [x] Rebuild `manuscript.pdf` (50 pp, zero unresolved citations)
- [x] Write `help.md` (writing-session doc: keypoints, cheat-sheet, figure
      map) and `progress.md`; fill `concept.md`; update `readme.md`,
      `todo.md`, `updates.md`

## 🔴 Submission preparation (next)

- [ ] Draft the cover letter from `help.md` §2 (3–4 editor keypoints)
- [ ] Switch bibliography from `apalike` to the target journal's style
- [ ] Final submission-format pass (line numbers, figures as vector PDF
      where the journal allows, highlight/declaration pages)
- [ ] Verify `verify_v2.py` output zero unresolved citations after any
      regeneration from `prior-art/build_v2.py`

## 🟢 Low Priority
- [ ] Add a supplementary table of all calibration metrics
- [ ] Add a robustness test with an alternative PET method (Hamon)
- [x] Delete `02-outputs/legacy/`, `02-outputs/smoke/`, the old `.Rmd` chain and
      the superseded CART PDFs (20 Nov 2026; project now 128 MB)
