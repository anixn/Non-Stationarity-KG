[CONCEPT](./concept.md) | [README](./readme.md) | [TODO](./todo.md) | [UPDATE](./updates.md) | [HELP](./help.md) | [PROGRESS](./progress.md)

# Progress — CZIPEF Revision 1

> 📅 Last updated: 24 November 2026 (Tuesday)
> Status snapshot across the project's workstreams. Detailed daily log: `updates.md`.

## Overall status: **manuscript analysis-complete, text-complete, figure-caption-synced; ready for submission polish**

| Workstream | Status | Notes |
|---|---|---|
| Analysis pipeline (`01-analysis/R`) | ✅ Complete | Production run 19–20 Nov 2026, zero failures; 222/332 pass |
| Results & tables (`02-outputs/revision`) | ✅ Complete | Tables 3–9b auto-generated (`make_tables.R`) |
| Figures (data, ggplot2) | ✅ Complete | Figs 1–2, 8–14 + S1–S10 from `10_figures.R` |
| Figures (conceptual, Mermaid) | ✅ Complete | Figs 3–7 rendered pele→SVG→PDF/PNG, wired into LaTeX |
| Prior-art update (2022–2026) | ✅ Complete | WOS search (1,277 records); 34 added refs; three-way gap verified |
| Manuscript text (docx + LaTeX v2) | ✅ Complete | All numbers filled; Methods mirror code; limitations stated |
| Figure/caption/text consistency audit | ✅ Complete | 24 Nov 2026 — captions, legends and text–table mismatches fixed |
| PDF build (`latex-v2/manuscript.pdf`) | ✅ Complete | 50 pp; zero unresolved citations; 3 cosmetic bibtex warnings |
| Response to reviewers | ✅ Notes complete | Numbers filled in `Response-to-Reviewers-Notes.md` |
| Journal-style bibliography | 🟡 Pending | Currently `apalike`; switch at submission |
| PET robustness test | 🟡 Pending | Hamon alternative (low priority, flagged in todo) |
| Cover letter final draft | 🟡 Pending | Keypoints ready in `help.md` §2 |

## Milestones

- **19 Nov 2026** — first manuscript text pass; Methods rewritten to mirror code.
- **20 Nov 2026** — production run complete (222 catchments); numbers filled; project cleaned 1.4 GB → 128 MB.
- **21 Nov 2026 (approx.)** — WOS prior-art corpus; latex-v2 rebuilt with real BibTeX (152 entries) and 2022–2026 literature.
- **24 Nov 2026** — figure-spec set rendered and audited: captions/text synced to re-rendered figures (Figs 1–2, 6, 7, 11, 12), text–table mismatches fixed (+2 °C class-change range, Table 9 significance claims, Table 6 ΔR² sentence), duplicate SPF paragraph removed, PBE→PBIAS, R² typography unified; PDF rebuilt (50 pp).

## Next actions (top 3)

1. Switch bibliography to the target journal's style and final-format the LaTeX.
2. Draft the cover letter from `help.md` §2 (3–4 editor keypoints).
3. Optional: Hamon-PET robustness run before resubmission.
