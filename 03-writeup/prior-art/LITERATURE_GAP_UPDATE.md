# LITERATURE_GAP_UPDATE.md — prior-art synthesis and manuscript update plan

Source: 1,277 de-duplicated WOS Core Collection records (2026-11-24; see
`PRIOR_ART_SEARCH.md`). This file (a) states the verified gap, (b) lists the
key recent literature per theme with one-line relevance, and (c) maps every
manuscript change made in the LaTeX build (`03-writeup/Revision-1/latex-v2/`).

---

## 1. The gap, as verified against the 2026 literature

The manuscript claims: *no comprehensive framework explicitly links model
parameter non-stationarity to Köppen–Geiger climate-zone transitions under
future (delta-change) scenarios, and no vulnerability threshold framework
evaluates that linkage at large-sample scale*. The search confirms this with
three qualifications that the revised Introduction/Discussion must now
address explicitly:

1. **Climate-dependent parameter transferability is established, but stops
   short of zone-conditioned parameter pools.** Transferability studies show
   performance loss when the calibration and evaluation climates differ
   (Jahanshahi et al., 2022; Dakhlaoui et al., 2019; Coron et al., 2012;
   Merz et al., 2011), and the newest multi-catchment work extends this to
   ensemble averaging (Jahanshahi & Booij, 2026) and to hybrid
   process/deep-learning models (Bohl et al., 2026). None of these studies
   redefines the *pool of acceptable parameters* as a function of a climate
   classification, and none propagates the effect into a vulnerability
   threshold.
2. **Time-varying-parameter methods exist, but are temporal/statistical, not
   climate-classification-based.** The TVP literature is active (Wallner &
   Haberlandt, 2015; Meng et al., 2016; Zhang & Liu, 2021; Krapu & Borsuk,
   2022; Zhou et al., 2022; Liu et al., 2025 MOPEX Budyko; Lian et al.,
   2024; Zhang et al., 2024) — all estimate parameters as functions of time
   or hydrological state, without an interpretable external classifier, and
   mostly on few catchments. CZIPEF's distinct contribution is anchoring the
   evolution to KG classes, which keeps it interpretable and transferable.
3. **KG-zone change under climate change is now a mature mapping literature,
   disconnected from hydrological model parameterization.** CMIP6-based KG
   projections are global (Beck et al., 2023; Bayar et al., 2023; Song et
   al., 2025) and regional (Vasquez et al., 2025 Chile; Teixeira et al.,
   2026 Portugal; Wang et al., 2024 China; Dajuma et al., 2023 Africa) —
   these papers map where zones shift but do not ask what a zone shift does
   to model parameters or vulnerability thresholds.

**Gap statement to use in the manuscript:** parameter-evolution methods are
either purely temporal (TVP line) or purely spatial (regionalization line);
climate-zone studies map shifts but stop before the model; transferability
studies diagnose the problem but do not construct the counterfactual
framework. CZIPEF closes this triangle — and the results (72% of catchments
change threshold, but in *both* directions, weak pooled relation) quantify
for the first time how large the vulnerability error from ignoring this
link can be, per catchment, per indicator.

## 2. Key references added (WOS-verified, full metadata in `WOS_key_picks.bib`)

### A. Parameter non-stationarity / time-varying parameters
| Ref | Relevance |
|---|---|
| Wallner & Haberlandt (2015, Hydrol. Process.) | SOM-B framework: non-stationary parameters for flow indices/time scales — first large demonstration that fixed parameters are "unproven practice" |
| Meng et al. (2016, Water) | Real-time data assimilation traces temporal parameter change |
| Zhang & Liu (2021, HESS) | TVP by split-sample calibration + dynamic programming; decadal parameter drift |
| Krapu & Borsuk (2022, WRR) | Differentiable hydrology with time-varying parameters |
| Zhou et al. (2022, J. Hydrol.) | Diagnosing structural deficiencies via TVP — TVP as diagnostic, supports our drift evidence |
| Lian et al. (2024, Water) | Differentiable parameter learning for TVP in conceptual models |
| Zhang et al. (2024, J. Hydrol.) | Reusing TVPs from same-period previous years — forecasting angle |
| Liu et al. (2025, JHRS) | Time-varying Budyko parameters in US MOPEX — latest evidence that even monthly water-balance parameters move |

### B. Climate-dependent transferability / calibration robustness
| Ref | Relevance |
|---|---|
| Jahanshahi et al. (2022, Hydrol. Sci. J.) | Model transferability depends on climate conditions (Iran) — direct conceptual neighbour |
| Jahanshahi & Booij (2026, J. Hydrol.) | Multi-catchment transferability + ensemble averaging, contrasting hydroclimatic conditions — most recent |
| Dakhlaoui et al. (2019, J. Hydrol.) | Bootstrap differential split-sample test under past/future variability — validates our moving-window design |
| Duethmann et al. (2020, HESS) | Why conceptual models fail to predict discharge changes under climate change |
| Bohl et al. (2026, HESS) | Hybrid models generalize better to warmer climates than process-based or purely data-driven models |
| Vormoor et al. (2018, Hydrol. Sci. J.) | HBV "crash testing" under contrasting flood seasonality |
| Seibert & Bergström (2022, HESS) | Half a century with HBV — model lineage framing |
| Anderson et al. (2025, Earth's Future) | Stationarity assumptions in streamflow sensitivity may bias future projections |

### C. Köppen–Geiger zone change under climate change
| Ref | Relevance |
|---|---|
| Beck et al. (2023, Sci. Data) | 1-km KG maps 1901–2099 — already cited; supplies class definitions and delta-change logic |
| Bayar et al. (2023, Earth's Future) | CMIP6 ESMs project greater acceleration of climate-zone change |
| Song et al. (2025, Earth's Future) | CMIP6 GCMs project future KG zones globally — already cited, now complemented |
| Vasquez et al. (2025, Environ. Res. Lett.) | Robust spatial changes in climate classes, bias-corrected CMIP6 (Chile) |
| Teixeira et al. (2026, Earth Syst. Environ.) | Climate classification shifts for future climate (Portugal) |
| Wang et al. (2024, Int. J. Climatol.) | KG-zone shifts over China under CMIP6 |

### D. PET / evapotranspiration formulation (CZIPEF vs SPF issue)
| Ref | Relevance |
|---|---|
| Pimentel et al. (2023, WRR) | Which PET formula to use in hydrological modelling worldwide — supports the PET-sensitivity discussion (SPF vs CZIPEF) |
| Almorox et al. (2015, J. Hydrol.) | Performance ranking of temperature-based PET by Köppen class — direct precedent for climate-conditional PET choice |
| Malamos et al. (2025, J. Hydrol.) | Global reference-ET clustering vs KG classification |

### E. Low flows and non-stationary frequency analysis
| Ref | Relevance |
|---|---|
| Fitriana et al. (2026, HESS) | Non-stationary low-flow frequency with copula-based dependence — supports the copula resampler framing |
| Jahanshahi et al. (2022, J. Hydrol.) | Controls on catchment hydrological similarity via model transferability |

### F. Reference corrections (cited in docx, resolved now)
| Manuscript token | Resolved reference |
|---|---|
| (Khan et al., 2020) — bias nonstationarity | **Hui, Y., Xu, Y., Chen, J., Xu, C.-Y., Chen, H. (2020)**, Hydrology Research 51(5), 925–941, doi:10.2166/nh.2020.254 |
| (Shen et al., 2022) — split-sample/moving-window transferability testing | **Coron et al. (2012)** + **Dakhlaoui et al. (2019)** (correct method lineage) |
| (Vormoor et al., 2021) | **Vormoor et al. (2018)**, Hydrol. Sci. J. 63(7), 991–1007 (HBV crash testing) — year corrected |
| (Son & Tague, 2019) | **Son, K. & Tague, C. (2019)**, Ecohydrology 12(1), e2053, doi:10.1002/eco.2053 |
| (Calvin et al., 2023) | IPCC AR6 Synthesis Report (Calvin et al., 2023) |
| Garcia-Aristizabal et al. (2015) | Natural Hazards 75(1), 289–320, doi:10.1007/s11069-014-1324-z |

## 3. Where each addition goes in the manuscript

| Section | Change |
|---|---|
| 1. Introduction (KG paragraph) | New "state of the art 2022–2026" paragraph: TVP line (A), transferability line (B), KG-mapping line (C), each contrasted with CZIPEF |
| 1. Introduction (gap paragraph) | Rewritten as the three-way gap (§1 above) with explicit citations |
| 3. Methodology (validation) | Citation for the split-sample/moving-window protocol corrected to Coron (2012) + Dakhlaoui (2019) |
| 5.1 Discussion | Added: comparison against transferability findings (Jahanshahi 2022/2026, Bohl 2026, Duethmann 2020, Anderson 2025) — CZIPEF's weak pooled relation is *consistent with* their finding that climate contrast degrades transferability, and extends it from performance to vulnerability thresholds |
| 5.2 Discussion | Added: TVP literature contrast (Krapu & Borsuk 2022, Liu 2025, Zhou 2022) — CZIPEF provides the interpretable, classification-anchored alternative |
| 5.3 Discussion | Added: PET-formulation sensitivity (Pimentel 2023, Almorox 2015) and KG-shift projections (Song 2025, Bayar 2023, Vasquez 2025) as operational implications; low-flow copula precedent (Fitriana 2026) |
| References | ~30 new entries (WOS export metadata) + 6 corrections above; converted from Zotero text to natbib keys |

## 4. What was checked and NOT claimed

- The KG delta-change maps are a controlled experiment, **not** a CMIP6
  projection — framing kept (Beck et al. 2023 supplies class definitions
  and delta-change logic).
- No raster comparison with Beck et al. (2023) is claimed.
- The "first framework / death of stationarity" language stays removed;
  the contribution is positioned relative to the three literature lines.
