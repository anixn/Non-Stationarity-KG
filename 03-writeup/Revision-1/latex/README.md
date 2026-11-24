# LaTeX build for Revision 1

Builds a compiling LaTeX manuscript from the revised docx, generated booktabs
tables from the pipeline outputs, and a supplementary section with the
diagnostic figures.

```powershell
$env:PATH = 'C:\Users\deshm\AppData\Roaming\TinyTeX\bin\windows;C:\Program Files\Pandoc;' + $env:PATH
powershell -File 03-writeup/Revision-1/latex/build_all.ps1
```

Output: `03-writeup/Revision-1/latex/build/manuscript.pdf` (57 pages, ~7 MB).

## What each file does

| File | Purpose |
|------|---------|
| `build_all.ps1` | runs the four steps below |
| `manuscript_pandoc.tex` | pandoc conversion of `Deshmukh_2025_KG_R1.docx` (do not edit) |
| `build_latex.py` | preamble, figure scaling, caption numbering, SI figures + tables appendix, writes `manuscript.tex` |
| `make_tables.R` | CSV tables from `02-outputs/revision/tables` -> booktabs `.tex` in `tables/` |
| `manuscript.tex` | the buildable source |
| `si/` | copies of the supplementary figure PNGs used by the appendix |
| `build/` | LaTeX working dir (safe to delete) |

## Notes

- Engine: **pdfLaTeX** (TinyTeX). The injected preamble maps the non-ASCII
  characters that survive the docx (ω, δ, ≥, ≤, −, U+2010, combining accents,
  ×) so the file compiles without missing-character warnings.
- Figures from the docx are re-scaled to `\linewidth`; pandoc otherwise keeps
  the Word size (6.27 in) and every figure overflows the text block.
- Captions already carry “Figure 8 …” in the docx text, so `build_latex.py`
  strips the leading number to avoid “Figure 8: Figure 8 …”. To do that it also
  disables section numbering (`secnumdepth 0`), because the headings already
  carry their manual numbers (“4. Results”, “5.1 …”).
- The appendix contains Supplementary Figures S1–S10 (calibration, split sample,
  drift, baseline KG, transitions, variance partition, RF importance, LFI/MAMF
  sensitivity, uncertainty, identifiability) and the result tables with explicit
  captions “Table 3 … Table 9”.
- The pandoc conversion keeps equations (OMML -> LaTeX) and extracts all
  figures to `media/`. Zotero citations come through as plain author–year text;
  switching to `\cite` + BibTeX is a deliberate manual step.
- `make_tables.R` only runs if `02-outputs/revision/tables` exists; it is
  skipped silently during a docx-only rebuild.
- The generated `.tex` tables keep the CSV column names verbatim so every
  number in the text is traceable to the pipeline output.
- Line spacing is 1.15. Add `\doublespacing` in `build_latex.py` if the journal
  wants double spacing.
- `Tables-R1.docx` (in `03-writeup/Revision-1/`) is the landscape Word version of
  Tables 3–9 for the Word submission; it is not part of the LaTeX chain.
