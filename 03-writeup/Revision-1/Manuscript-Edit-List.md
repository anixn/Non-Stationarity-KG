# Manuscript edit list — `Deshmukh_2025_KG_R1.docx`

> Paragraph numbers are `python-docx` indices in the Revision 1 file.
> Structural checks after the last edit: 233 paragraphs, 8 tables, 288
> `fldChar` elements (96 citation fields, unchanged from the pre-edit file) and
> 49 equation objects.
>
> Status: **A applied** (19 Nov 2026) · **B applied** (20 Nov 2026) ·
> **C applied** (20 Nov 2026) · **D checked**
>
> LaTeX build: `03-writeup/Revision-1/latex-v2/manuscript.tex` (pdflatex +
> bibtex; see `latex-v2/README.md`). Note: the 20 Nov 2026 pandoc build
> (`latex/build_all.ps1`, 57 pp) described below was superseded and removed
> on 27 Nov 2026 — `latex-v2` is the current build (50 pp).

---

## A. Applied to the docx (structural edits, 19 Nov)

| # | Paragraph | Change |
|---|-----------|--------|
| 1 | P29, P34 | Data period 1980 → **1981–2010** |
| 2 | P34 | “304 catchments” → “**candidate** catchments”; the analysed sample is defined by the calibration and climate-zone requirements |
| 3 | P20 | Beck et al. (2023) supplies the class definitions **and the delta-change logic**; the maps are a controlled delta-change experiment, not a CMIP6 projection and not a raster comparison |
| 4 | P53 | Added the **0.408 MJ m⁻² d⁻¹** latent-heat conversion; PET is recomputed for every perturbed scenario |
| 5 | P50 | “a minimum of fifty” → “the **200 best-ranked** behavioural parameter sets per catchment” |
| 6 | P63 | **10,000 LHS sets, KGE ≥ 0.5, \|PBIAS\| ≤ 25%, NSE reported but not used to screen, 200 sets retained, catchments with < 50 excluded**; calibration 1981–2010 with two-year warm-up; split-sample and moving-window validation |
| 7 | P64 | Class boundaries (Class 1 ≤ 25%, Class 2 25–50%, Class 3 > 50%); **LFI** and **MAMF** with their vulnerability directions; MAR as the primary indicator |
| 8 | P65 | “CART is the estimator” → **isotonic + logistic prevalence estimators**, CART only as an independent cross-check |
| 9 | P66 | CART paragraph now explicitly a cross-check |
| 10 | P80 | “304 catchments / fifty sets” → “analysed catchments / retained behavioural sets” |
| 11 | P81 | KDE-as-resampler → **Gaussian copula** (empirical marginals, rank correlation, bounded) |
| 12 | P83 | copula resampling and **isotonic/logistic thresholds per catchment, framework and indicator** |
| 13 | P86 | observed decadal reclassification; **fallback flag** rule instead of the ET “>10% exclusion” |
| 14 | P130 | removed “first framework / death of stationarity / sets a new standard”; reframed as a transparent first step |
| 15 | P131 | KDE claim replaced by the copula-based resampler |

---

## B. Production numbers applied (20 Nov)

All numbers below come from `02-outputs/revision/tables/`. Catchment counts:
**332 candidate → 222 analysed** (KGE ≥ 0.5, |PBIAS| ≤ 25%, ≥ 50 behavioural
sets).

| Paragraph | Content now in the manuscript | Source |
|-----------|-------------------------------|--------|
| P6 (Abstract) | 332 → 222; 72% of 217 catchments change threshold (38% higher, 34% lower, 28% identical); slope 0.31, R² = 0.14; temperature threshold identifiable in < 7%; supplementary indicators 10–26% | T8, T7 |
| P34 | 332 candidate catchments; 222 analysed (Section 4.1) | T3 |
| P63 | calibration criteria and 10,000 LHS sets | config |
| P85 | 121 (ΔP × ΔT) combinations; Table 5b shares at +1.5/+2/+3/+4 °C: 30/37/53/58% at ΔP −50%, 16/24/43/50% at ΔP 0, 19/26/45/51% at ΔP +50% | T5b |
| P86 | 21% with ≥ 1 observed decadal transition; 92% with any scenario transition; median 3 classes visited; fallback classes Af, Am, Aw, BSh, BWh, BWk; 222 of 332 retained | T5 |
| P89 | catchment 06614800: 25/121 cells (21%) with P(C3) ≥ 0.5 under SPF vs 43/121 (36%) under CZIPEF; thresholds 0.67 vs 0.70; ΔT threshold 3.9 °C | scenarios, T7 |
| P95 | thresholds 0.52–0.99, median 0.75 (IQR 0.71–0.79); 14 catchments ≥ 0.9 under SPF vs 1 under CZIPEF | T7 |
| P96 | threshold–aridity r = −0.02; threshold–snow fraction r = −0.27; class medians Dfa 0.83, Csa 0.80, Csb 0.65, Dsc 0.62 | threshold CSV + Caravan attributes |
| P100 | y = 0.505 + 0.309x, R² = 0.14, n = 217, p < 0.001; 38% above / 34% below the 1:1 line | T8 |
| P106 | 83 higher (38%), 74 lower (34%), 60 identical (28%); LFI/MAMF paired thresholds for 41 and 17 catchments | T8 |
| P111 | median FC 112 (Csb) / 150 (Cfa) / 207 (Dfa, Dfb) / 223 mm (Dfc); median CFMAX 1.75 vs 4.44; copula diagnostics | pool_summary, resample_diagnostics |
| P112 | variance partitioning (CFMAX 63%, k1 45%, PERC 34%, k0 34%, UZL 32%; MAXBAS 6%); ΔR² 0.03–0.09 | T6 |
| P116 | PRCC 2000 draws; Sobol 512-sample base matrix (13,312 runs) | config |
| P117 | β, FC, LP significant for MAR in every class; Sobol 0.64/0.33/0.12 for FC/β/LP; MAXBAS only in Cfa; FC PRCC −0.93…−0.62 (MAR), −0.45…−0.06 (MAMF), −0.03…+0.43 (LFI) | T9, prcc CSVs |
| P121, P128, P130 | 157 of 217 change (72%), 83 higher / 74 lower / 60 equal; no consistent direction | T8 |
| P132 | Sobol/PRCC summary by class | T9 |
| Captions | Figs 8–14 renumbered to the regenerated figures | `10_figures.R` |

Removed stale numbers: “205”, “304”, “116 / 89”, “56%”, “20% / 36% / 44%”,
“y = 0.235 + 0.654x”, “R² = 0.58”, “24 / 45 out of 121”.

---

## C. Prose pass applied

- **P65/P66** — the estimator (isotonic crossing at 0.5 on the marginal
  prevalence curve, logistic model on ΔP × ΔT) is the method; CART is an
  independent cross-check illustrated in Fig. 6.
- **P81** — KDE kept only as the rejected alternative (equation 6 still defines
  it); the copula is the resampler.
- **P107, P111, P112** — rewritten from F13, `pool_summary.csv`,
  `resample_diagnostics.csv`, T6.
- **P116, P117** — rewritten from T9 and the PRCC/Sobol files; “significant” now
  refers to the PRCC screening rule with the numbers given.
- **P122, P123, P124, P126, P128** — the “systematic shift”, “strong climate
  dependency” and “majority of catchments” claims were replaced by the measured
  direction and magnitude.
- **P119** — “offer insightful insights” removed.

---

## D. Consistency checks

- [x] Every Results sentence about vulnerability names the indicator.
- [x] “1981–2010” everywhere; no “1980”.
- [x] One catchment count (332 candidate / 222 analysed) in Abstract, Methods,
      Results and tables.
- [x] No claim of raster comparison with Beck et al. (2023).
- [x] The delta-change KG map is never called a projection.
- [x] CART appears only as a cross-check.
- [x] KDE appears only as the rejected alternative, not as the method.
- [x] Manuscript figure numbers 1–14 map to files in
      `02-outputs/revision/figures/` as listed below.
- [x] LaTeX PDF compiles with no missing characters (57 pages).

### Figure map (manuscript → file)

| Fig. | File | Content |
|------|------|---------|
| 1 | `FA_analysed_catchments.png` | analysed catchments |
| 2 | `FB_selection_map.png` | 332 candidates vs analysed |
| 3 | docx image 3 | bottom-up framework workflow (static) |
| 4 | docx image 4 | HBV flowchart (static) |
| 5 | docx image 5 | Monte-Carlo calibration workflow (static) |
| 6 | docx image 6 | CART cross-check example (static) |
| 7 | docx image 7 | KG–parameter framework flowchart (static) |
| 8 | `F4b_kg_delta_change_map.png` | 12-panel delta-change KG map |
| 9 | `F14_prevalence_surface.png` | P(C3) surface, catchment 06614800 |
| 10 | `F8b_threshold_map.png` | SPF vs CZIPEF threshold maps for MAR |
| 11 | `F8_threshold_scatter.png` | SPF vs CZIPEF scatter (n = 217) |
| 12 | `F9_threshold_difference_map.png` | direction of the threshold difference |
| 13 | `F13_parameter_cdf.png` | parameter CDFs by class |
| 14 | `F10_sensitivity.png` | PRCC/Sobol for MAR |

Supplementary figures S1–S10 are appended to the LaTeX build from
`02-outputs/revision/figures/` (calibration, split sample, drift, baseline KG,
transitions, variance partition, RF importance, LFI/MAMF sensitivity,
uncertainty, identifiability).

### Tables

`03-writeup/Revision-1/Tables-R1.docx` holds Tables 3–9 (landscape, 7.5 pt) for
the Word submission. The LaTeX build includes the same tables as
`tables/T3…T9.tex` with explicit `Table 3 … Table 9` captions.
`T8_threshold_decomposition.csv` is transposed in the Word file so that it fits
the page; the LaTeX version keeps the CSV orientation.

### Known limitations stated in the text

- Six catchments represent the sensitivity analysis, so Table 9 is a
  class-level summary (P117).
- LFI and MAMF thresholds are identifiable in 10–26% of catchments; the main
  conclusion rests on MAR (Abstract, P130).
- Climate-zone pools capture only part of the parameter variation (P112).
- `vegan::varpart` unique fractions can be negative and are clamped at zero, so
  Table 6 shares do not always sum to 100% (unexplained fraction is reported).
