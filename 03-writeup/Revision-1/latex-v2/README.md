# latex-v2 — literature-updated LaTeX build (R2)

> Writing session: use the repo-root [`../../../help.md`](../../../help.md) —
> simple-language summary, editor keypoints, number cheat-sheet, figure map.

Rebuilt manuscript with (1) the full R1 docx content preserved, (2) real
BibTeX citations (`natbib` + `references.bib`, 152 entries), (3) the
2022–2026 prior-art update in Introduction and Discussion, and (4) a
sharpened three-way gap statement verified against a Web of Science search
(1,277 records, `../../prior-art/PRIOR_ART_SEARCH.md`).

## Build

```powershell
# from the repository root D:\Research\202505_Non_Stationarity_KG
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
# bibtex must run with latex-v2 as working directory (paths in the tex are repo-relative)
cd 03-writeup/Revision-1/latex-v2; bibtex manuscript; cd ..\..\..
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
pdflatex -interaction=nonstopmode -output-directory=03-writeup/Revision-1/latex-v2 03-writeup/Revision-1/latex-v2/manuscript.tex
```

Output: `manuscript.pdf` (50 pages, 2026-11-28). All citations resolve;
bibtex warnings are cosmetic (three entries have no `journal` field: IPCC report, rpart
manual, Wilby & Dessai chapter).

## Files

| File | Purpose |
|---|---|
| `manuscript.tex` | buildable source (do not hand-edit citations; regenerate with `../../prior-art/build_v2.py` after changing the blocks there) |
| `references.bib` | `KG_Bibliography` (deduped) + 34 WOS-verified 2022–2026 additions + 7 verified corrections |
| `tables/` | booktabs tables generated from `02-outputs/revision/tables/` |
| `figure-spec/` | conceptual `.mmd` + `.svg` sources and `TYPOGRAPHY_SPEC.md`; the live register is the repo-root `FIGURES.md` |

All 24 figure includes read the vector PDFs directly from
`02-outputs/revision/figures/` (main Figs. 1–14 and SI Figs. S1–S10). The
old `media/media/` and `si/` copies were removed on 2026-11-28 so there is
one figure source, not three.

## What changed vs the earlier pandoc build (`../latex/manuscript.tex`, removed 27 Nov 2026)

- **Citations:** all 96 Zotero author–year text citations converted to
  `\citep`/`\citet` (105 + 9); the plain-text References list is replaced by
  BibTeX. Zero unresolved citations remain (checked by `verify_v2.py`).
- **Reference corrections** (documented in
  `../../prior-art/LITERATURE_GAP_UPDATE.md`):
  - (Khan et al., 2020) → Hui et al. (2020), *Hydrology Research* 51(5),
    doi:10.2166/nh.2020.254 — correct source for bias nonstationarity.
  - (Shen et al., 2022) → Coron et al. (2012) + Dakhlaoui et al. (2019) —
    correct method lineage for split-sample/moving-window transferability.
  - (Vormoor et al., 2021) → Vormoor et al. (2018), *HSJ* 63(7) — HBV crash
    testing; year corrected.
  - (Singh et al., 2014) → Singh and Kumar (2015), *GRL* 42(22).
  - (Breiman et al., 1984) → bib year set to the original 1984 edition.
  - (Melsen & Guse, 2021a/2021b) → single entry `melsen2021climate` (the two
    keys in the R1 bib were the same paper).
- **Introduction:** new 2022–2026 state-of-the-art paragraph (time-varying
  parameters, climate-dependent transferability, KG-zone-change mapping)
  and a rewritten three-way gap paragraph.
- **Discussion:** new comparison paragraphs in 5.1 (transferability),
  5.2 (TVP vs zone-conditioned pools) and 5.3 (KG projections, PET
  formulation, copula-based low-flow analysis).
- **Preamble:** natbib + geometry; everything else preserved (manual
  section numbers, unnumbered tables, equation mapping, figure scaling).

## Status

- All figures rebuilt to the v2 element table on 2026-11-28 (axis 10 pt,
  ticks/legends 9 pt, panel labels 11 pt bold); Fig. 7 re-laid out as two
  panels so it fits one page at 160 × 134 mm.
- All 24 figure includes are vector PDFs read from
  `02-outputs/revision/figures/`; no duplicate copies in the LaTeX tree.
- Next: optional switch from `apalike` to a journal-specific style at
  submission; the old Journal of Hydrology submission
  (`HYDROL72949.pdf`, 64 pp) and the original Springer LaTeX
  (`D:\OneDrive\Desktop\Manuscripts\202505_Non_Stationarity_KG\03-writeup\manuscript-01\Deshmukh_2025_KG.tex`,
  `sn-jnl` Water Resources Management template, with real `\cite` keys in
  `Bibliography.bib`) are available as templates for the next target
  journal.
