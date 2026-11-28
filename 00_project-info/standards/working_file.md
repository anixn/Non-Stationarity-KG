# WORKING FILE — Project Structure, Figure Production, and Run Reporting

> **What this file is for:** the single practical guide to how a research
> project is organised, how it is run, how figures are made, and what must be
> reported after every run. It is written for a researcher, not a software
> developer. No prior programming knowledge is assumed.

**Version:** 1.0 — 2026-11-28
**Applies to:** all computational research projects (hydrology, climate,
drought, low-flow, remote sensing, modelling, machine learning).
**Read this first, then the companion standards.**

---

## 1. The toolkit — six documents, one job each

| File | One job | Read it when |
|---|---|---|
| `working_file.md` (this file) | How a project is structured, run, and reported | Start of every project and every session |
| `research_file_and_folder_standard.md` | Where every file and folder belongs; naming rules | Creating or moving any file |
| `scientific_figure_standard.md` | Font sizes, colours, export, and how to describe/modify a figure | Before drawing or changing a figure |
| `figure_spec_template.md` | A one-page card describing one figure | For every new figure |
| `project_status_template.md` | The plain-language status and session history | End of every working session |
| `run_summary_template.md` | The short "what happened in this run" report | After every run |

### 1.1 Where these files live

**All seven files live in `00_project-info/standards/`.** That is the frozen
reference copy: read it, do not edit it.

Six of them are used two ways: a blank reference in `standards/`, and a live
working file at the project root that you fill in and update.

| Template / reference in `standards/` | Live file at project root |
|---|---|
| `project_status_template.md` | `PROJECT_STATUS.md` |
| `run_summary_template.md` | `RUN_SUMMARY.md` |
| `figure_spec_template.md` | `FIGURES.md` |

The other three are reference only — they are never filled in per project:

- `working_file.md`
- `research_file_and_folder_standard.md`
- `scientific_figure_standard.md`

`README.md` in `standards/` is the index of the standards folder. The
**project's own** `README.md` is a different file, at the project root, and is
written from scratch for that project.

```text
project-name/
├── 00_project-info/
│   └── standards/                 ← the 7 files, frozen reference
│       ├── README.md
│       ├── working_file.md
│       ├── research_file_and_folder_standard.md
│       ├── scientific_figure_standard.md
│       ├── figure_spec_template.md
│       ├── run_summary_template.md
│       └── project_status_template.md
├── README.md                      ← this project's own readme
├── PROJECT_STATUS.md              ← live, filled from template
├── RUN_SUMMARY.md                 ← live, appended after every run
└── FIGURES.md                     ← live, one row per figure
```

Rules:

- One copy of the standards per project. Do not also keep a loose copy at the
  root or in `05_documents/`.
- Never edit the copy in `standards/`. If a standard improves, copy the new
  version in and note the date in `PROJECT_STATUS.md`.
- The live files at the root are the ones you and the assistant update.

**The rule that ties them together:** a project that cannot be re-run from its
own folders is not finished, and a run that has no written summary did not
happen.

---

## 2. The standard project structure

### 2.1 The tree

```text
project-name/
├── 00_project-info/          ← this toolkit, research question, decisions
│   ├── standards/            ← copies of the toolkit files (frozen at project start)
│   ├── project_structure.md  ← how this project maps to the standard
│   └── data_inventory.md     ← every dataset: source, period, units, licence
├── 01_data/
│   ├── raw/                  ← originals. Never edited, never overwritten.
│   ├── processed/            ← cleaned and derived data (regenerable)
│   └── external/             ← boundaries, shapefiles, third-party layers
├── 02_scripts/               ← numbered analysis scripts (01_, 02_, …)
├── 03_results/               ← model output, metrics, tables (not figures)
├── 04_figures/
│   ├── working/              ← drafts, experiments
│   └── publication/          ← final PDF + PNG, named fig_NN_*
├── 05_documents/             ← manuscript, reports, presentations, SI
├── 06_references/            ← bibliography, literature notes
├── 07_archive/               ← superseded runs and old versions
├── README.md                 ← what the project is and how to run it
├── PROJECT_STATUS.md         ← plain-language status and session history
├── RUN_SUMMARY.md            ← newest-first log of every run
├── FIGURES.md                ← figure register: one row per figure
└── .gitignore
```

### 2.2 What belongs in each folder

| Folder | Put here | Never put here |
|---|---|---|
| `00_project-info/` | research question, objectives, methods notes, decisions, data inventory, standards copies | data, code, outputs |
| `01_data/raw/` | untouched downloads and field data | cleaned data, edited copies |
| `01_data/processed/` | cleaned, joined, gap-filled, unit-corrected data | the only copy of anything irreplaceable |
| `01_data/external/` | shapefiles, DEM, boundaries, licensed layers | project-generated results |
| `02_scripts/` | analysis and figure scripts | data, outputs, Word files |
| `03_results/` | CSV/XLSX metrics, model output, summary tables | figures, manuscripts |
| `04_figures/` | figures only, one file per format | data, scripts, old manuscripts |
| `05_documents/` | manuscript, reports, slides, response letters, SI | code, raw data |
| `06_references/` | `.bib`, PDFs where allowed, literature notes | data, results |
| `07_archive/` | superseded runs, withdrawn figures, old versions | anything still in active use |

### 2.3 Minimum viable project

If a project is small, this is the smallest acceptable structure:

```text
project-name/
├── 00_project-info/
├── 01_data/raw/
├── 02_scripts/
├── 03_results/
├── 04_figures/
├── 05_documents/
├── README.md
├── PROJECT_STATUS.md
├── RUN_SUMMARY.md
└── FIGURES.md
```

Do not create empty folders "for later". Add a folder when the first real file
needs it.

### 2.4 Existing projects keep their structure

If a project already has a working layout (for example `01-analysis/`,
`02-outputs/`, `03-writeup/`), **keep it**. Write the mapping in
`00_project-info/project_structure.md` instead of moving files:

| Standard folder | Existing project folder |
|---|---|
| `01_data/` | `01-analysis/data/` |
| `02_scripts/` | `01-analysis/R/` |
| `03_results/` | `02-outputs/revision/` |
| `04_figures/` | `02-outputs/revision/figures/` |
| `05_documents/` | `03-writeup/` |
| `07_archive/` | `02-outputs/legacy/` |

Never reorganise a working project just to match the template. Moving files
breaks paths and wastes a day.

---

## 3. File and folder specification

### 3.1 Naming at a glance

| Thing | Rule | Good | Bad |
|---|---|---|---|
| Folder (custom) | lowercase kebab-case | `low-flow-analysis/` | `Low Flow Analysis/` |
| Folder (standard) | numbered, underscore | `02_scripts/` | `scripts_new/` |
| Script | numbered snake_case if order matters | `03_calculate_indices.R` | `script final.R` |
| Data file | snake_case + period | `precipitation_daily_2010_2020.csv` | `data.csv` |
| Result table | `table_NN_description.csv` | `table_02_model_performance.csv` | `results2.xlsx` |
| Figure | `fig_NN_description.ext` | `fig_04_model_performance.pdf` | `Figure4_new.png` |
| Date in a name | `YYYYMMDD` | `20261128_meeting_notes.md` | `28-11-26 notes.md` |
| Version | zero-padded `v001` | `manuscript_v002.docx` | `manuscript_final_final.docx` |

Rules:

- No spaces in file and folder names. Use `_` inside file names, `-` in
  folder names.
- Lowercase extensions: `.R`, `.py`, `.csv`, `.tif`, `.nc`, `.gpkg`, `.md`,
  `.pdf`, `.svg`, `.png`, `.docx`.
- Never use `final`, `latest`, `new`, `test`, `copy`, `old`, `v2final`.
- One file, one purpose. No `misc.R` or `temp.csv` in a final project.

### 3.2 The script header — mandatory

Every analysis script starts with this block. It takes two minutes and saves
hours:

```r
# =============================================================================
# 03_calculate_indices.R
#
# Purpose:    Compute SPI-3, SPI-12, SSI-3 and SSI-12 for every catchment.
# Input:      01_data/processed/precip_monthly.csv
#             01_data/processed/streamflow_monthly.csv
# Output:     03_results/indices/catchment_indices.csv
# Method:     Gamma distribution, zero-adjusted, 12-month accumulation.
# Parameters: calibration 1981-2010; scale = 3, 12.
# Requires:   R 4.4, SPEI 1.8, data.table 1.15
# Author/date: A. Deshmukh, 2026-11-28
# =============================================================================
```

### 3.3 One configuration file

Paths, periods, thresholds, seeds, and parameter values live in **one** file
(for example `00_config.R` or `R/config.R`). No script hard-codes a path or a
threshold. When a number changes, it changes in one place and the change is
visible in one diff.

Record in that file:

- project root and input/output folders;
- analysis periods (calibration, validation, test);
- random seeds;
- thresholds and acceptance criteria;
- package versions or environment file.

### 3.4 Data rules

- Raw data is read-only. Corrections go to `processed/`.
- Every dataset has a row in `00_project-info/data_inventory.md`: name,
  provider, DOI/URL, access date, period, resolution, units, CRS, licence,
  known gaps.
- Large data does not go into Git. Record how to obtain it.
- Never overwrite a processed file silently. Regenerate it from the script.

### 3.5 Results and figures

- `03_results/` holds numbers (CSV, XLSX, JSON). `04_figures/` holds pictures.
  Do not mix them.
- Every figure file has a row in `FIGURES.md`.
- Every table file is named `table_NN_*` and generated by a script, not typed
  by hand.
- If a table is typed by hand, its source must be written next to it.

---

## 4. The project workflow — eight stages

Every project, regardless of topic, moves through the same eight stages. Each
stage has an input, a script, an output, and a check. A stage is only complete
when the check passes.

| # | Stage | Input | Output | Check ("gate") |
|---|---|---|---|---|
| 1 | **Define** | idea, literature | research question, objectives, hypotheses in `00_project-info/` | Question is answerable with available data |
| 2 | **Acquire** | data sources | `01_data/raw/` + data inventory | Files open; period, units, CRS match the source |
| 3 | **Prepare** | raw data | `01_data/processed/` | Row counts, date range, missing values, units documented |
| 4 | **Analyse / model** | processed data | `03_results/` | Script runs end-to-end; outputs written |
| 5 | **Validate** | results + independent data | validation tables | Test data never used in fitting; metrics reproducible |
| 6 | **Visualise** | results tables | `04_figures/` + `FIGURES.md` | Figure standard checklist passes at 100 % |
| 7 | **Write** | results, figures | `05_documents/` | Every number in the text traces to a table |
| 8 | **Archive** | finished project | `07_archive/` + final status | README, status, scripts, and data inventory current |

Two rules that prevent most reproducibility failures:

1. **Never fit on data you later score on.** Write the split once in the config
   file and read it everywhere.
2. **Never let a stage read from a later stage.** Stage 6 reads stage 4/5
   outputs; it never recomputes them.

---

## 5. How figures are created — end to end

### 5.1 The pipeline

```text
 results table  →  figure spec card  →  plotting script  →  shared theme
        │                  │                    │                │
        └── documented ────┴── one message ─────┴── final size ──┘
                                                   │
                              PDF (vector) + PNG 300 dpi
                                                   │
                                     inspect at 100 %  →  FIGURES.md
                                                   │
                                          embed in manuscript
```

### 5.2 The eight steps

1. **Confirm the data.** The figure reads a result table, never raw data and
   never numbers typed into the script.
2. **Write the figure spec card.** One sentence for the message, panels, encodings,
   size, export, script. Use `figure_spec_template.md`. This is the "figure
   description" that makes the figure understandable later.
3. **Draw in the figure script.** One script (for example
   `02_scripts/06_generate_figures.R`) draws all manuscript data figures.
   Conceptual diagrams are separate source files (Mermaid/SVG).
4. **Use the shared theme.** Font, sizes, colours, gridlines, and margins come
   from one `theme_publication()` function. A figure never defines its own
   fonts.
5. **Design at final size.** 160 mm for an A4 page with 2.5 cm margins, or the
   journal's column width. Sizes in the standard are then true printed sizes.
6. **Export both formats.** Vector PDF for the manuscript, 300 dpi PNG for
   review and Word. Same file stem, same content.
7. **Inspect at 100 %.** Check clipping, overlaps, panel labels, legend, units,
   and that nothing changed outside the requested edit.
8. **Register it.** Add or update the row in `FIGURES.md`: number, file, type,
   message, script, size, status/version. Then update the manuscript and the
   status file.

### 5.3 Re-running only the figures

Most projects can redraw figures without rerunning the analysis:

```powershell
# CZIPEF / 202505_Non_Stationarity_KG style
$env:TSFT_STAGES="10"; Rscript 01-analysis/R/run_all.R

# queuing-lowflow-hydrology style
Rscript R/figures_paper01.R

# CMIP6_IND_GR4J style (R Markdown modules)
# knit only the figure module, e.g. in RStudio:
rmarkdown::render("FIG_10_figures.Rmd")
```

A figure script that needs the whole model re-run to change a font is too
coupled. Read the saved result table instead.

### 5.4 The figure-only loop for a change request

This is the loop to use whenever you say "change this in the figure":

1. Name the figure, panel, and element.
2. Classify: cosmetic / layout / data / scientific (see the figure standard §3.3).
3. Change it in the script, not in the exported file.
4. Re-run the figure script only.
5. Compare old and new at 100 %.
6. Run the figure checklist.
7. Update `FIGURES.md` and `RUN_SUMMARY.md`.

### 5.5 The figure register (`FIGURES.md`)

Minimum columns:

| Fig | File | Type | Message | Script | Size (mm) | Status |
|---|---|---|---|---|---|---|
| 1 | `fig_01_study_area` | map | Where the catchments are | `06_generate_figures.R` | 160 × 120 | final v002 |
| 2 | `fig_02_framework` | conceptual | Five-stage method | `fig02_framework.mmd` | 160 × 90 | final v001 |

Why it matters: six months later, the register is the only thing that says
which script and which data produced Figure 4.

---

## 6. After every run — the run summary

### 6.1 Why this exists

A run produces files, logs, and numbers. None of that tells you, in plain
language, what happened or whether the project moved forward. The run summary
does. It is written for **you**, not for the computer.

### 6.2 The five questions every run summary answers

1. **What did I ask to run?** — the exact command or module.
2. **Did it finish?** — completed, partly completed, or failed.
3. **What changed?** — files created or modified, and where.
4. **What do the numbers say?** — the two or three key results, with units.
5. **What now?** — the project status and the single next action.

### 6.3 The template

Copy this block into `RUN_SUMMARY.md` after every run. Newest entry at the
top. The table rows below show the shape of an entry; the numbers are
illustrative.

```markdown
## YYYY-MM-DD HH:MM — Short title

**Command run:** `Rscript 02_scripts/05_model_validation.R`
**Result:** Completed / Partly completed / Failed

### What ran
One or two sentences in plain language.

### What changed
| File | Change |
|---|---|
| `03_results/model_performance_summary.csv` | Rewritten, 192 rows |
| `04_figures/publication/fig_04_model_performance.pdf` | Redrawn |

### Key numbers
| Item | Value | Where |
|---|---|---|
| Median KGE, calibration | 0.80 | Table T3 |
| Median KGE, validation | 0.54 | Table T3 |
| Catchments scored | 192 of 222 | `03_results/coverage.csv` |

### What it means
Two to four sentences. What this changes for the study, and what it does not.

### Checks performed
- [ ] Script exited without error
- [ ] Output files exist with today's timestamp
- [ ] Row and catchment counts match expectations
- [ ] No "Error" in the log
- [ ] Figure opens and passes the checklist

### Problems and warnings
Anything skipped, any warning, any unresolved issue. State honestly if a check
was not performed.

### Status now
Stage: Analysis / Validation / Figures / Writing
Done: …
Not done: …

### Next action
One concrete step.
```

### 6.4 The one-line receipt

For quick work and chat replies, the same information in one line:

```text
Run 2026-11-28 14:05: validation → completed; 192/222 catchments, median KGE
0.80 calibration / 0.54 validation; figure 4 redrawn; next: SI table S3.
```

### 6.5 Where the summary goes

| Place | Content | Update when |
|---|---|---|
| `RUN_SUMMARY.md` | Every run, newest first, technical detail | After every run |
| `PROJECT_STATUS.md` | Session history + current project state, plain language | End of every session |
| `FIGURES.md` | Figure rows | Whenever a figure is created or changed |

`RUN_SUMMARY.md` is the detailed log. `PROJECT_STATUS.md` is the readable
state of the project. Do not duplicate whole logs into the status file.

### 6.6 How to tell a run actually worked

Before writing "completed", check all five:

1. The script's last line says it finished, and the exit status is 0.
2. The expected output files exist and carry today's timestamp.
3. Row counts and date ranges are plausible (not 0, not double).
4. The log contains no `Error` and no silent `Warning` you cannot explain.
5. At least one number in the summary was read from an output file, not from
   memory.

A script that ran is not the same as a result that is scientifically valid.
Say which one you have.

### 6.7 Rules for the assistant (OpenCode) after every run

- Report the exact command and the actual result.
- List files created and modified with full paths.
- Quote real numbers read from the outputs. Never estimate or invent.
- State what is **not** done.
- Distinguish: attempted / executed / validated.
- If a run failed, give the failing line and the likely cause, not a summary
  of intentions.
- End with one next action.

---

## 7. How your three projects work

The same pattern appears in all three, with different names.

### 7.1 `202505_Non_Stationarity_KG` — revision pipeline

| Element | Where |
|---|---|
| Entry point | `Rscript 01-analysis/R/run_all.R` |
| Config | `01-analysis/R/00_config.R` (bounds, periods, seeds, output root) |
| Stages | `00_config` → `10_figures`, each numbered script one stage |
| Selective run | `$env:TSFT_STAGES="10"` (figures only); `TSFT_NCATCH` for a smoke test |
| Outputs | `02-outputs/revision/{calibration,validation,kg,attribution,pools,scenarios,thresholds,sensitivity,figures,tables}` |
| Figures | `01-analysis/R/10_figures.R` → `02-outputs/revision/figures/` (PDF + PNG) |
| Figure register | `03-writeup/Revision-1/latex-v2/figure-spec/FIGURES.md` |
| Manuscript | `03-writeup/Revision-1/latex-v2/manuscript.tex` |
| Status | `PROJECT_STATUS.md`; writing aid in `help.md`; journal in `updates.md` |
| Lesson | Stage numbering + "resume from disk" makes re-runs cheap and safe. |

**Workflow in one line:** configure once → run stages in order → stages resume
from saved outputs → stage 10 rebuilds figures → copy into the LaTeX build →
update status.

### 7.2 `CMIP6_IND_GR4J` — hypothesis-driven module programme

| Element | Where |
|---|---|
| Entry point | No single `run_all`; each hypothesis has a module family |
| Modules | `QED_*` forcing, `HYD_*` GR4J, `LOWFLOW_*` metrics, `GR6J_*` structure, `PROP_*` propagation, `DECOMP_*` ANOVA, `BENCH_*` benchmark |
| Order | Fixed by the phase map in `AGENTS.md` (phase 1 → 5b) |
| Outputs | `data_processed/`, with `data_processed/logs/<module>_exclusions.csv` |
| Figures | Not yet a dedicated module — add `FIG_00_spec.md` + `FIG_10_figures.R` + `FIGURES.md` |
| Manuscript | `manuscript/paper.md`, `NOVELTY_AND_ANOVA_SPEC.md` |
| Status / log | `manuscript/AGENT_LOG.md`, `AGENTS.md` guardrails |
| Lesson | Hypothesis register + phase map + exclusion logs keep a long project auditable. |

**Workflow in one line:** pick the phase → run its module in numbered order →
write the exclusion log → record the outcome against the hypothesis (pass,
fail, negative) → only then move to the next phase.

**Gap to close in this project:** it has excellent scientific guardrails but no
single figure register and no run-summary file. Add both, using this toolkit.

### 7.3 `queuing-lowflow-hydrology` — paper package

| Element | Where |
|---|---|
| Entry point | Ordered chain in `README.md` §Run |
| Chain | `R/verify.R` → `study_p1.R` → `p1_panel.R` → `paired_analysis_p1.R` → `revision_p1.R` → `p1_sensitivity.R` |
| Config | `R/config.R` (paths, seeds, all parameters) |
| Outputs | `paper01/output/*.csv` + `.json` sidecars; `paper01/tables/` |
| Figures | `R/figures_paper01.R` → `paper01/figures/Fig01…Fig07` (PDF + PNG) |
| Paper package | `paper01/README.md`, `figure_table_captions.md`, `STUDY.Rmd`, `MANUSCRIPT_Paper01.Rmd` |
| Decision record | `PIVOT.md` (what changed and why) |
| Lesson | CSV + JSON sidecar per result, a verification battery, and a paper
  folder that mirrors the manuscript make the paper self-contained. |

**Workflow in one line:** verify → run the study → run the panel and
sensitivities → run figures and tables → render the paper → record the gate
result in `PIVOT.md`.

### 7.4 The common pattern

All three projects, stripped to essentials:

```text
one config  →  one entry point  →  one output root  →  one figure script
     →  one figure register  →  one status file  →  one run summary
```

If a new project has those seven things, it is reproducible and understandable.
If it is missing one, that is the first thing to fix.

---

## 8. Session checklist

### At the start of every session

- [ ] Read `README.md`, `PROJECT_STATUS.md`, and the last three entries of
  `RUN_SUMMARY.md`.
- [ ] Check the pending tasks table in `PROJECT_STATUS.md`.
- [ ] Inspect the actual files before assuming their state.
- [ ] Confirm which stage is next and what its input is.

### At the end of every session

- [ ] Analysis outputs regenerated and checked.
- [ ] Figures regenerated, inspected at 100 %, register updated.
- [ ] `RUN_SUMMARY.md` entry added.
- [ ] `PROJECT_STATUS.md` session entry added and stage table updated.
- [ ] `README.md` updated if navigation, commands, or dependencies changed.
- [ ] Honest list of what remains incomplete.

---

## 9. Starting a new project

```powershell
$P = "D:\Research\202612_New_Project"
New-Item -ItemType Directory -Force -Path `
  "$P\00_project-info\standards", `
  "$P\01_data\raw", "$P\01_data\processed", "$P\01_data\external", `
  "$P\02_scripts", "$P\03_results", `
  "$P\04_figures\working", "$P\04_figures\publication", `
  "$P\05_documents", "$P\06_references", "$P\07_archive" | Out-Null

# freeze the standards at project start (all 7 files)
Copy-Item "D:\OneDrive\Desktop\toolkit\*.md" "$P\00_project-info\standards\"

# create the three live files at the project root
Copy-Item "$P\00_project-info\standards\project_status_template.md" "$P\PROJECT_STATUS.md"
Copy-Item "$P\00_project-info\standards\run_summary_template.md"    "$P\RUN_SUMMARY.md"
Copy-Item "$P\00_project-info\standards\figure_spec_template.md"    "$P\FIGURES.md"
```

Then, in order:

1. Write the project's own `README.md` (title, question, data, structure, run
   order, software). This is not the toolkit README.
2. Fill section 1 of `PROJECT_STATUS.md`.
3. Set the project name and date at the top of `RUN_SUMMARY.md`.
4. Delete the example row in `FIGURES.md`, keeping the header.
5. Write `00_project-info/data_inventory.md`.
6. Write `02_scripts/00_config.R` (paths, periods, seeds).
7. Only then write the first analysis script.

---

## 10. Plain-language glossary

| Term | Meaning |
|---|---|
| **Entry point** | The one command you run to start the project |
| **Config file** | The single file holding paths, dates, thresholds, and seeds |
| **Stage / module** | One numbered step with its own input and output |
| **Gate** | A check that must pass before the next stage |
| **Raw data** | The untouched original; never edited |
| **Processed data** | Cleaned data produced by a script from raw data |
| **Sidecar** | A small JSON file next to a CSV holding its description |
| **Figure register** | The table mapping each manuscript figure to its script and data |
| **Vector PDF** | A PDF that stays sharp at any zoom; preferred for line art |
| **dpi** | Dots per inch; 300 is the minimum for raster figures |
| **Seed** | A fixed number that makes random sampling repeatable |
| **Git** | Version history for text and code; not a backup for large data |
| **Smoke test** | A tiny run (few catchments) to prove the pipeline works |
| **Reproducible** | Another person can regenerate your results from your folders |

---

## 11. Final rules

1. One project, one entry point, one config, one output root.
2. Raw data is read-only.
3. Every figure comes from a script and has a register row.
4. Never edit an exported figure by hand.
5. Design figures at final size, and never below 7 pt text.
6. After every run, write the five-question summary.
7. State what is incomplete as clearly as what is finished.
8. Keep the structure simple enough that you can explain it in one minute.

**The test of a well-run project:** hand the folder to a colleague with
`README.md`, `PROJECT_STATUS.md`, and the figure register, and they can tell
what the study asks, what has been done, and how to reproduce it — without
reading a single line of code.
