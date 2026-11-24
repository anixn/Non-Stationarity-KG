# Revision 1 — indicator and KG-map decisions

> Two author decisions are fixed here so the code, figures, tables and
> manuscript text cannot drift apart again.
>
> 1. **MAR is the primary vulnerability indicator, and LFI and MAMF are
>    reported alongside it** — all three are computed, thresholded and shown.
> 2. **The Köppen–Geiger map is a delta-change product built with the Beck
>    et al. (2023) class scheme**, not a direct copy or comparison of their
>    gridded future map.

---

## 1. Three flow indicators, MAR primary

### 1.1 Definitions and vulnerability direction

| Indicator | Definition | Unit | What counts as vulnerability | Role |
|-----------|------------|------|------------------------------|------|
| **MAR** | Mean annual runoff, mean of annual flow totals | mm yr⁻¹ | a **decrease** relative to the historical baseline | primary |
| **LFI** | Low-flow index, mean annual minimum / mean annual mean | – | a **decrease** (loss of low flow) | supplementary |
| **MAMF** | High-flow ratio, median annual maximum / median annual median | – | an **increase** (more peaked high flows) | supplementary |

The four vulnerability classes are identical for all three indicators:

| Class | Relative change | Meaning |
|-------|-----------------|---------|
| 0 | no change, or change in the non-vulnerable direction | no vulnerability |
| 1 | 0–25% in the vulnerable direction | moderate |
| 2 | 25–50% | severe |
| 3 | >50% | extreme |

The direction is stored once in `INDICATOR_META` (`00_config.R`) and applied by
`vuln_class()` (`01_functions.R`). No script hard-codes a sign, so the old
Step08 mistake (LFI and MAMF results written into `mar_thr`, fixed split signs)
cannot recur.

### 1.2 Why report all three

The reviewer objected that the paper demonstrated one indicator (MAR) and then
made general statements about “vulnerability”. Reporting LFI and MAMF turns
that into a robustness test:

- if the SPF–CZIPEF difference has the same sign for MAR, LFI and MAMF, the
  conclusion is not an artefact of the chosen indicator;
- if it does not, the paper says so and restricts the claim to MAR.

MAR remains the headline because it is the indicator the original framework was
built on and the one with the clearest management meaning (water availability).

### 1.3 What changed in the code

| File | Change |
|------|--------|
| `00_config.R` | `INDICATORS`, `PRIMARY_INDICATOR`, `INDICATOR_META`, `SENS_METRICS` |
| `01_functions.R` | `vuln_class(rel, direction)`, `vuln_class_matrix()`, `indicator_direction()`, `indicator_label()` |
| `07_scenarios.R` | classifies all three indicators against each indicator's baseline median; writes `mar_*`, `lfi_*`, `mamf_*`, `p3_*` |
| `08_thresholds.R` | thresholds and SPF–CZIPEF comparison for all three; `T7` reports n and % identifiable per indicator; `T8` keeps an explicit `n = 0` row instead of hiding non-identifiable indicators |
| `09_sensitivity.R` | PRCC and Sobol run on MAR, LFI and MAMF (not on mean/peak flow) |
| `10_figures.R` | `F8` and `F9` are faceted by indicator; `F10` is MAR; `F10b` is LFI + MAMF; `F12` shows threshold identifiability |

### 1.4 How to report it in the manuscript

Methods paragraph:

> Three flow indicators are evaluated on the same four-class vulnerability
> scale: mean annual runoff (MAR), the low-flow index (LFI) and the high-flow
> ratio (MAMF). A decrease is treated as the vulnerability for MAR and LFI; an
> increase is treated as the vulnerability for MAMF because it represents
> intensification of high flows. MAR is the primary indicator; LFI and MAMF are
> reported as a robustness check on whether the SPF–CZIPEF difference is
> indicator-specific.

Results paragraph:

> For MAR, the median ΔP threshold is [x] under SPF and [y] under CZIPEF
> (Table 7). LFI and MAMF thresholds are identifiable in [p]% and [q]% of
> catchments respectively; where they are identifiable, the direction of the
> SPF–CZIPEF difference is [agree/disagree] with MAR (Table 8, Fig. 12). The
> headline claim is therefore restricted to MAR and qualified accordingly.

Do **not** write “vulnerability is underestimated” from a single indicator.
Report the decomposition per indicator.

### 1.5 Known limitation to state

LFI and MAMF can be non-identifiable: in some catchments the class-3
prevalence curve never crosses 0.5 anywhere in the 11 × 11 scenario space, so
no threshold exists. That is a property of the indicator and the scenario
grid, not a bug. `T7_threshold_identifiability.csv` and `F12` report it
explicitly.

---

## 2. Beck et al. (2023) and the KG map

### 2.1 What the decision means

Beck et al. (2023) provide present-day and future Köppen–Geiger maps built with
a delta-change method: observed climatology is perturbed and reclassified with
their class scheme. The revision uses **the same logic and the same class
scheme**, not a pixel-by-pixel comparison with their raster.

This matters because the old manuscript implied that the future KG classes were
projections. They are not CMIP6 projections; they are delta-change experiments
on the observed 1981–2010 climatology.

### 2.2 How the map is built

1. Compute monthly climatology for 1981–2010 from the catchment forcing
   (P, Tmin, Tmax, Tmean).
2. Apply a delta change: `P × dp`, `T + dt`.
3. Reclassify with `kg_class_all.R` (the Beck et al. 2023 scheme).
4. Draw with the official Beck et al. (2023) RGB palette in `KG Classes.csv`.

Reference levels are in `KG_MAP_LEVELS` (`00_config.R`). The precipitation
multipliers are the **same deltas as the vulnerability analysis, ΔP from −50%
to +50%** (dp = 0.5, 1.0, 1.5), crossed with four warming levels:

| ΔP | ΔT |
|----|----|
| 0.5 (−50%) | +1.5, +2, +3, +4 °C |
| 1.0 (no change) | +1.5, +2, +3, +4 °C |
| 1.5 (+50%) | +1.5, +2, +3, +4 °C |

That is 12 panels (Fig. 4b, arranged as ΔP rows × ΔT columns). The map
therefore shows both the warming effect and the drying/wettening effect of the
study's scenario range. If catchment-specific CMIP6/Beck precipitation deltas
become available, replace the `dp` column; the map then becomes directly
comparable with Beck et al. (2023) at the same warming level.

Outputs:

- `02-outputs/revision/kg/kg_map_levels.csv` — one row per catchment × level
  (3 ΔP × 4 ΔT), with baseline class, future class, `changed`.
- `02-outputs/revision/kg/kg_map_summary.csv` — number and percentage of
  catchments changing class at each (ΔP, ΔT) combination.
- `02-outputs/revision/tables/T5b_kg_map_transitions.csv` — manuscript table.
- `F4_kg_baseline_map` — baseline map with the Beck palette.
- `F4b_kg_delta_change_map` — 12-panel delta-change map (ΔP × ΔT).

### 2.3 What changed in the code

| File | Change |
|------|--------|
| `00_config.R` | `KG_MAP_LEVELS`, `KG_BASELINE_LABEL` |
| `01_functions.R` | `kg_palette()` parses the official RGB values |
| `04_kg_transitions.R` | new delta-change map block, resumable, writes `kg_map_levels.csv` and `kg_map_summary.csv` |
| `10_figures.R` | `F4` uses the Beck palette; new `F4b` |

### 2.4 How to report it in the manuscript

Methods paragraph:

> Köppen–Geiger classes follow the Beck et al. (2023) scheme. Baseline classes
> are computed from the 1981–2010 monthly climatology of each catchment.
> Future classes are produced with the same delta-change logic used to build the
> Beck et al. (2023) maps: precipitation is multiplied by a factor and
> temperature is shifted by a warming level, and the perturbed climatology is
> reclassified. The delta-change grid uses the same precipitation
> perturbations as the vulnerability analysis, ΔP from −50% to +50%,
> crossed with warming of +1.5, +2, +3 and +4 °C. This is a controlled
> delta-change experiment, not a CMIP6 projection; the observed decadal
> reclassification (1981–1990, 1991–2000, 2001–2010) is reported separately so
> that real and synthetic transitions are not conflated.

Results paragraph:

> Under a ×0.5 precipitation change (ΔP = −50%) the number of catchments that
> change class at +2 °C and +4 °C is [n] and [m] (Table 5b, Fig. 4b); under the
> wettest change (ΔP = +50%) it is [k]. The dominant transitions are [list].
> These counts come from one delta per panel rather than the full 121-scenario
> grid, so they are smaller than the "any of 121 scenarios" count reported
> earlier.

### 2.5 What not to claim

- Do not call the delta-change classes “projected” or “CMIP6”.
- Do not claim agreement with Beck et al. (2023) unless their gridded deltas
  have actually been substituted into `KG_MAP_LEVELS$dp`.
- Do not say “no catchment preserved its historical zone across all 121
  scenarios” without also giving the delta-change result; the 121-scenario
  statement is trivially true because the grid includes extreme drying.

---

## 3. Consistency checklist before submission

- [ ] `INDICATOR_META` direction matches the Methods table.
- [ ] Every Results sentence about vulnerability names the indicator.
- [ ] Table 7 reports n and % identifiable, not only the median threshold.
- [ ] Table 8 reports the decomposition per indicator, including `n = 0`.
- [ ] Fig. 8 and Fig. 9 show all three indicator panels.
- [ ] Fig. 4b is described as delta change, not projection.
- [ ] `KG_MAP_LEVELS$dp` is either 1.0 (temperature-only) or replaced with
      documented CMIP6/Beck deltas; the text states which.
