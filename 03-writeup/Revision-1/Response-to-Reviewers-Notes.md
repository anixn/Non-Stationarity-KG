# Response-to-Reviewers — working notes

> Drafting notes, not the final letter. Every number below is from the Revision 1
> production run (`02-outputs/revision/`) with 332 candidate catchments, of which
> **222 passed calibration and form the analysed sample**.

---

## Reviewer #2

### 1. “Parameters depend on geophysical characteristics, not only climate”

**Response.** We agree and have added a formal attribution analysis. For each HBV
parameter we partition the variance explained by (i) climatic attributes (aridity,
P, PET, snow fraction, seasonality, moisture index) and (ii) physiographic
attributes (area, elevation, slope, forest/crop/urban fraction, soil water
content, soil organic carbon, silt, sand, karst, groundwater depth), using
adjusted-R² variance partitioning. We also test whether Köppen–Geiger zone adds
explanatory power after climate and physiography (nested linear models) and rank
all predictors with random forests.

**Result.** Climate explains the largest share for CFMAX (63%), k1 (45%), PERC
(34%), k0 (34%) and UZL (32%), and the smallest for MAXBAS (6%), SFCF (11%) and
TT (15%). Physiography explains more than climate for beta (39% vs 29%), k0 (47%
vs 34%), PERC (48% vs 34%), UZL (53% vs 32%) and MAXBAS (31% vs 6%). Adding
climate-zone membership to a physiography-only model adds ΔR² = 0.03–0.09, and
is significant for 6 of the 12 parameters (beta, k1, k2, LP, TT, PERC; p < 0.05).
We therefore describe CZIPEF as climate-informed, not climate-only, and say so in
the Results (P112), Discussion (P123) and the limitations.

**New material.** Methods §3.3; Fig. S6 (variance partitioning); Fig. S7 (RF
importance); Table 6. Script `05_parameter_controls.R`.

---

### 2. “Real-world validation is missing; only modelling experiments”

**Response.** We added the temporal validation that was missing: (i) a
differential split-sample test (calibrate 1981–1995, validate 1996–2010, and the
reverse); (ii) 10-year moving-window recalibration with a 5-year stride;
(iii) a parameter-drift analysis across windows. We also report the distribution
of KGE/NSE/PBIAS for every catchment.

**Result.** Forward split: median KGE 0.582 in calibration, 0.574 in validation
(ΔKGE = −0.026); reverse split: 0.593 → 0.550 (ΔKGE = −0.045). 69.8% (forward)
and 65.3% (reverse) of catchments remain behavioural (KGE ≥ 0.5) in validation.
Performance therefore degrades only modestly, but it does degrade, which is
consistent with mild parameter non-stationarity rather than with perfect
transferability.

**New material.** Methods §3.2 and §3.3; Fig. S1 (calibration performance);
Fig. S2 (split sample); Fig. S3 (parameter drift); Table 3, Table 4. Scripts
`02_calibrate.R`, `03_temporal_validation.R`.

---

### 3. “Unclear whether HBV was calibrated per catchment; report calibration”

**Response.** Calibration is fully specified: Latin hypercube with 10,000 samples
per catchment, 2-year warm-up, KGE ≥ 0.5 and |PBIAS| ≤ 25% as behavioural
criteria, the 200 best-ranked behavioural sets retained, catchments with fewer
than 50 sets excluded. 332 candidates were calibrated; 100% reached KGE ≥ 0.5,
the median behavioural KGE is 0.598, the median |PBIAS| is 5.28%, and 66.9% of
catchments produced at least 50 sets, leaving 222 analysed catchments.

**New material.** Methods §3.2; Fig. S1; Table 3.

**Note.** The old text said NSE/KGE > 0 and |PBIAS| < 25 while the code used 0.25;
we now state the actual criteria. NSE is reported (median 0.366; 19.3% of
catchments reach 0.5) but is not used for screening, because requiring NSE ≥ 0.5
discards structurally limited catchments. This is stated in the Methods.

---

### 4. “Criteria for detecting climate-zone change are not described”

**Response.** We give the full Köppen–Geiger algorithm (monthly P, Tmin, Tmax,
Tmean; A/B/C/D/E thresholds; second- and third-level criteria), the baseline
period, and the delta-change construction. Classes follow the Beck et al. (2023)
scheme and the maps use their delta-change logic: the observed 1981–2010 monthly
climatology is perturbed (P × ΔP, T + ΔT) and reclassified. This is not a
projection and not a raster comparison with Beck et al.; it is a controlled
experiment whose precipitation deltas can be replaced with CMIP6 values when
those are supplied. We separate **observed** decadal reclassification
(1981–1990, 1991–2000, 2001–2010) from the synthetic scenario matrix.

**Result.** 20.7% of catchments record at least one observed decadal transition.
In the synthetic matrix 91.9% of catchments leave their baseline class in at
least one of the 121 scenarios, and the median catchment visits three classes.
The 12-panel map (ΔP = −50%, 0, +50% × warming +1.5, +2, +3, +4 °C) shows class
changes in 16–30% of catchments at +1.5 °C and 50–58% at +4 °C.

**New material.** Methods §3.4; Fig. 8 (12-panel delta-change map); Figs S4–S5
(baseline and transition maps); Tables 5 and 5b. Script `04_kg_transitions.R`.

---

### 5. “Methodology is hard to follow”

**Response.** Section 3 is restructured to mirror the code: design, HBV +
calibration, behavioural sets, scenarios + KG, pooling + resampling, indicators +
vulnerability, threshold estimation, sensitivity. The old generic workflow
flowcharts are reduced to a compact framework diagram plus the HBV schematic, and
the estimator (isotonic crossing of the prevalence curve at 0.5; logistic model
on ΔP × ΔT) is now the method, with CART demoted to an independent cross-check.

---

### 6. “How was ‘significantly underestimated’ reached? Did KG changes occur?”

**Response.** The claim is removed. The correct decomposition for MAR, on the 217
catchments where both frameworks give a threshold: CZIPEF gives a higher
precipitation threshold in 83 catchments (38.2%), a lower threshold in 74
(34.1%), and an identical threshold in 60 (27.6%). The median difference is zero
(binomial p = 0.52 for the direction; Wilcoxon p = 0.47), the regression slope is
0.309 (R² = 0.14) and the thresholds are not interchangeable. Stationarity
therefore does not bias vulnerability in a single direction; it changes it
catchment by catchment. For LFI (n = 41) the CZIPEF threshold is lower in 41.5%
and identical in 53.7% (binomial p = 7 × 10⁻⁴, Wilcoxon p = 0.012), and for MAMF
(n = 17) there is no detectable direction (p = 1.0).

**New material.** Results §4.4; Fig. 11 (scatter); Fig. 12 (difference map); Fig.
S10 (identifiability); Tables 7–8. Script `08_thresholds.R`.

**Indicator note.** MAR is the primary indicator; LFI and MAMF are reported on the
same four-class scale with an explicit direction (decrease for MAR and LFI,
increase for MAMF). Their thresholds are identifiable in only 25.7%/23.9% (LFI)
and 9.9%/11.7% (MAMF) of catchments, and their parametric uncertainty is much
larger (coefficient of variation 50–228% for LFI and 16–142% for MAMF against
5–11% for MAR), so a null LFI/MAMF result is visible rather than hidden.

---

### 7. “How was uncertainty quantified? Uncertainty ≠ sensitivity”

**Response.** We separate the two. **Sensitivity** is quantified with PRCC and
Sobol first/total-order indices, for MAR, LFI and MAMF in six representative
catchments (one per KG class; PRCC 2000 draws, Sobol 512-sample base matrix,
13,312 runs). **Uncertainty** is quantified as the 5–95% range and coefficient of
variation of the three indicators across the 200 retained behavioural sets.

**Result.** For MAR, beta, FC and LP are significant in every class; CFMAX, SFCF
and TT join them in Cfb, Dfa, Dfb and Dfc. Sobol agrees (first-order indices 0.64
for FC, 0.33 for beta, 0.12 for LP in BSk). MAMF is the most parameter-rich
indicator, and MAXBAS is significant only in Cfa. The MAR ensemble has a
coefficient of variation of 5–11%, against 16–142% for MAMF and 50–228% for LFI.

**New material.** Methods §3.7; Fig. 14 (sensitivity, MAR); Fig. S8 (LFI/MAMF);
Fig. S9 (uncertainty); Table 9; new Results paragraph after P117. Script
`09_sensitivity.R`.

---

### 8. “KDE — simplify and say why”

**Response.** The KDE is no longer the default. We use a Gaussian copula with
empirical marginals: each parameter keeps the pool’s marginal distribution, the
pool’s rank correlation is retained, and every draw is bounded by the parameter
ranges. Diagnostics over 1000 draws per class: zero out-of-range values, no
Kolmogorov–Smirnov rejection of the marginals at 5%, and a maximum change in
pairwise correlation of 0.08–0.14. The Methods text is reduced to three
sentences; equation 6 remains only because the rejected KDE is named.

**New material.** Methods §3.5; `pools/resample_diagnostics.csv`. Script
`06_pool_resample.R`.

---

### Minor comments

1. **Terminology.** “Model parameters” for the 12 HBV parameters; “behavioural
   parameter sets” only for accepted sets.
2. **P9 L53–56.** Top-down/bottom-up paragraph rewritten; repetition removed.
3. **“Fifty parameters.”** Now “200 behavioural parameter sets per catchment”,
   defined in §3.2.
4. **Eq. 6.** KDE equation retained only as the rejected alternative, with one
   sentence saying why it is not used.
5. **Unnecessary figures.** The generic workflow figures are reduced; every
   Results figure now carries a review-relevant message.
6. **Figure axes.** All figures rebuilt with explicit axis labels, units and
   colour legends (`10_figures.R`).

---

## Reviewer #4

**Response.** We added the temporal calibration experiment the reviewer asked for
(“catchment parameters update with 30 years of data”): 10-year moving-window
recalibration and a differential split-sample test. We also toned down the “new
paradigm” language to “a first step toward climate-zone-informed parameter
evolution”, added an explicit limitations paragraph (climate is not the only
control; synthetic scenarios; HBV structure; resampling caveats), and removed the
unsupported claims. The revised Results now separate what the data show (no
systematic direction; weak agreement between frameworks) from what the framework
is for (a physically constrained way to let parameters evolve).

**New material.** Figs S1–S3, S6–S7; Tables 3, 4, 6; limitations §5.3.

---

## Limitations paragraph (draft)

> Three limitations bound the interpretation. First, climate is not the only
> control on model parameters: physiography explains a substantial and partly
> independent fraction of the variance (Table 6), so CZIPEF should be read as a
> climate-informed refinement, not a complete parameter-evolution theory.
> Second, the scenario classes are generated by delta change applied to the
> historical climatology, not by CMIP6 projections; the observed decadal
> reclassification is reported separately and shows that actual transitions
> (20.7% of catchments) are rarer than the scenario matrix implies (91.9%).
> Third, the resampled sets are drawn from pools calibrated under historical
> conditions; we screen them for behavioural performance under the perturbed
> forcing, but we do not recalibrate under every scenario, which would be
> computationally prohibitive for 222 catchments × 121 scenarios.
