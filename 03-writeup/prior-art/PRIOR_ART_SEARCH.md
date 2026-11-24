# PRIOR_ART_SEARCH.md — Web of Science prior-art search protocol and log

**Project:** CZIPEF — Climate Zone-Informed Parameter Evolution Framework for
catchment vulnerability under model parameter non-stationarity
(`Deshmukh_2025_KG_R1`, revision 1)
**Date of search:** 2026-11-24
**Database:** Web of Science Core Collection (webofscience.com, institutional
IP access — Pandit Deendayal Petroleum University, entitlement confirmed in
session)
**Operator:** automated browser session; each query run as a Topic search
(all words in title/abstract/keywords), results exported as BibTeX
("Author, Title, Source" content, records 1–N), saved under
`03-writeup/prior-art/`.

---

## 1. Queries run (13 result sets, 1,277 unique records after de-duplication)

| # | Topic query string | Hits | Export file |
|---|---|---|---|
| Q1 | `non-stationary hydrological model parameters` | 167 | `wos_q01_nonstationary_parameters.bib` |
| Q2 | `("Köppen" OR "Koppen" OR "Koppen-Geiger") AND (hydrolog* OR "rainfall-runoff" OR streamflow) AND (model* OR classification)` | 73 | `wos_q02_koppen_model_73.bib` |
| Q3 | `("climate zone" OR "climate classification" OR "climate space") AND ("parameter regionalization" OR "parameter transfer" OR "model transferability") AND catchment` | 3 | (superseded by Q3b) |
| Q3b | `("parameter regionalization" OR "parameter transfer" OR "model transferability") AND (climate OR climatic) AND (catchment OR watershed)` | 96 | `wos_regionalization_96.bib` |
| Q4 | `("catchment vulnerability" OR "watershed vulnerability") AND "climate change" AND ("hydrological model" OR streamflow)` | 5 | `wos_vulnerability_5.bib` |
| Q5 | `"delta change" AND (streamflow OR runoff) AND (climate OR scenario*)` | 87 | `wos_delta_change_87.bib` |
| Q6 | `"low flow" AND (index OR indices OR indicator*) AND "climate change" AND vulnerability` | 23 | `wos_lowflow_23.bib` |
| Q7 | `HBV AND catchment AND "climate change" AND (calibration OR parameter*)` | 137 | `wos_hbv_137.bib` |
| Q8 | `"time-varying parameters" AND ("rainfall-runoff" OR "hydrological model")` | 25 | `wos_timevar_25.bib` |
| Q9 | `"CMIP6" AND (Koppen OR "climate classification") AND (shift OR transition OR scenario)` | 35 | `wos_cmip6_koppen_35.bib` |
| Q10 | `"parameter stationarity" OR "temporal transferability" OR "parameter transferability" AND "rainfall-runoff"` | 333 | `wos_stationarity_333.bib` |
| Q11 | `"catchment classification" AND (similarity OR "hydrological similarity") AND (climate OR aridity)` | 33 | `wos_catchclass_33.bib` |
| Q12 | `"climate elasticity" AND streamflow AND (change OR sensitivity)` | 120 | `wos_elasticity_120.bib` |
| Q13 | `("climate change" OR "climate scenarios") AND ("HBV" OR "GR4J" OR "HYMOD" OR "Sacramento") AND (uncertainty OR vulnerability)` | 308 | `wos_conceptual_impact_308.bib` |
| Q14 | `"model transferability" AND "climate" AND "hydrological model" AND (spatial OR temporal OR future)` | 4 | `wos_transfer_4.bib` |

Notes:
- Exports are BibTeX with full WOS metadata (authors, journal, volume,
  pages, DOI). All records merged and de-duplicated by WOS accession into
  `WOS_corpus_merged.bib` (1,277 unique records).
- A narrow variant of Q2 restricted to `"Koppen-Geiger" AND "hydrological
  model"` returned only 4 records — the broadened Q2 string above is the one
  retained.
- Q10's Boolean parse in WOS treats the final AND-bound phrase narrowly; the
  result set is a useful superset (all three concepts appear among the hits)
  and was retained.

## 2. Corpus profile

- **Year distribution:** 589/1,277 records (46%) are from 2022–2026;
  204 records are from 2026 and 112 from 2025 alone, i.e. the corpus is
  deliberately front-loaded with the latest literature (matches the goal of
  moving the manuscript's Introduction/Discussion to the current state of
  the art).
- **Top journals:** Journal of Hydrology (118), Hydrology and Earth System
  Sciences (77), Water (68), Water Resources Research (65), Hydrological
  Processes (36), Journal of Hydrology – Regional Studies (32), Remote
  Sensing (31), Hydrological Sciences Journal (28).
- **Thematic clustering** (title-keyword assignment, full report in
  `WOS_CLUSTER_REPORT.md`, flat list in `wos_corpus.csv`):

| Cluster | Records | 2022–2026 share |
|---|---|---|
| Parameter non-stationarity / time-varying parameters | 10 | 8/10 |
| Model transferability / stationarity assumption | 153 | 77/153 |
| Köppen / climate classification + hydrology | 35 | 23/35 |
| Regionalization / similarity / catchment classification | 72 | 34/72 |
| Climate-change impact + conceptual / lumped models | 68 | 25/68 |
| Vulnerability / resilience / risk frameworks | 24 | 8/24 |
| Delta-change / scenario experiments | 9 | 3/9 |
| Low-flow / drought indices under change | 18 | 6/18 |
| Uncertainty (behavioural / GLUE / Monte Carlo / sensitivity) | 11 | 3/11 |
| CMIP6 / projections / bias correction | 110 | 47/110 |
| Snow / energy / PET in hydrological response | 21 | 7/21 |

## 3. Tooling

- Browser-automated session against
  `https://www.webofscience.com/wos/woscc/basic-search` (Topic field), with
  the built-in BibTeX export dialog (records 1–1000 per export).
- Raw desktop downloads consolidated into
  `03-writeup/prior-art/wos_*.bib`; merged corpus `WOS_corpus_merged.bib`;
  parsing/clustering scripts `analyze_corpus.py`, `extract_picks.py`;
  curated key-record set `WOS_key_picks.bib` (36 records that feed the
  manuscript's updated Introduction and Discussion).
- **Search date staleness:** rerun the battery before submission if the
  manuscript is submitted more than ~3 months after 2026-11-24; the query
  strings above are copy-paste ready for the WOS advanced search box.

## 4. Prior-art conclusion (headline)

No prior study was found that (i) derives catchment-specific behavioural
parameter pools *conditioned on Köppen–Geiger climate classes*, (ii) drives
an explicit parameter-evolution experiment through delta-change KG
reclassification, and (iii) quantifies the resulting shift in vulnerability
thresholds (MAR, LFI, MAMF) against a stationary-parameter benchmark at
large-sample scale. Closest neighbours are the climate-dependent
transferability line (Jahanshahi et al., 2022, 2026; Dakhlaoui et al., 2019),
the time-varying-parameter line (Wallner & Haberlandt, 2015; Zhang & Liu,
2021; Krapu & Borsuk, 2022; Liu et al., 2025), and the KG-zone-change
mapping line (Beck et al., 2023; Bayar et al., 2023; Song et al., 2025) —
each of which covers at most two of the three elements. Details and the
per-cluster reading list: `LITERATURE_GAP_UPDATE.md`.
