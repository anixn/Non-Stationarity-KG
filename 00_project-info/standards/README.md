# Research Toolkit

A small set of plain-language standards for running computational research
projects reproducibly. Written for a researcher, not a software developer.

**Last updated:** 2026-11-28

---

## Start here

| If you want to… | Open |
|---|---|
| Understand how a project is organised, run, and reported | [`working_file.md`](working_file.md) |
| Know where a file or folder belongs, and what to name it | [`research_file_and_folder_standard.md`](research_file_and_folder_standard.md) |
| Make, describe, or modify a figure | [`scientific_figure_standard.md`](scientific_figure_standard.md) |
| Create the figure register for a project | [`figure_spec_template.md`](figure_spec_template.md) |
| Report what happened after a run | [`run_summary_template.md`](run_summary_template.md) |
| Write the plain-language project status | [`project_status_template.md`](project_status_template.md) |

---

## The workflow in one page

```text
 DEFINE        question, objectives, hypotheses
    │          → 00_project-info/
 ACQUIRE       raw data, untouched
    │          → 01_data/raw/  + data inventory
 PREPARE       cleaned, documented data
    │          → 01_data/processed/
 ANALYSE       numbered scripts, one config file
    │          → 02_scripts/  → 03_results/
 VALIDATE      independent data, no leakage
    │          → validation tables
 VISUALISE     figure script + shared theme + FIGURES.md
    │          → 04_figures/publication/
 WRITE         manuscript, tables, SI
    │          → 05_documents/
 ARCHIVE       frozen, documented, reproducible
               → 07_archive/
```

After **every run**, write the five-question summary in `RUN_SUMMARY.md`:
what ran, did it finish, what changed, what the numbers say, what next.
At the end of every session, update `PROJECT_STATUS.md`.

---

## The three rules

1. **One project, one entry point, one config, one output root.**
2. **Raw data is read-only; every figure comes from a script.**
3. **A run without a written summary did not happen.**

---

## Figure element sizes — quick card

Final printed sizes, measured at 100 % scale. Full rules in
[`scientific_figure_standard.md`](scientific_figure_standard.md) §1.

| Element | Recommended | Default |
|---|---|---|
| Axis titles | 9–10 pt | 10 pt |
| Axis tick labels | 8–9 pt | 9 pt |
| Figure legends | 8–9 pt | 9 pt |
| Panel labels — a), b), c) | 10–11 pt, bold | 11 pt bold |
| Annotations inside plots | 8–9 pt | 9 pt |
| Inset text | 7–8 pt | 8 pt |
| Map labels | 8–9 pt | 9 pt |
| Colorbar labels | 8–9 pt | 9 pt |

Never below 7 pt. At most three main sizes per figure. Design at final size
(160 mm for A4 with 2.5 cm margins), never shrink afterwards.

---

## How the standards are used in a project

Copy the whole toolkit into `00_project-info/standards/` at project start and
keep that copy frozen. The live toolkit may improve; the project copy records
what the project actually followed. If a project later adopts a newer standard,
copy it in deliberately and note the date in `PROJECT_STATUS.md`.

Existing projects with a working layout are **not reorganised**. Record the
mapping in `00_project-info/project_structure.md` (see the
`202505_Non_Stationarity_KG` example).
