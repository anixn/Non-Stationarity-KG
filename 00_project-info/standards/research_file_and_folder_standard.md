# Research File and Folder Management Standard

## 1. Purpose

This standard governs how research files and folders are created, named,
organized, documented, and maintained.

It is designed for computational hydrology, water resources, drought
analysis, remote sensing, GIS, climate science, statistical analysis,
and machine learning.

The user is a researcher, not a professional software developer.
Prioritize:

1.  Simplicity and ease of navigation.
2.  Scientific reproducibility.
3.  Data integrity and provenance.
4.  Consistent naming.
5.  Clear documentation.
6.  Portability across Windows, Linux, GitHub, and HPC systems.

Do not introduce complex software-engineering structures unless the
research genuinely requires them.

## 2. Standard project structure

Use this simple, numbered structure for new research projects:

``` text
project-name/
├── 00_project-info/
├── 01_data/
├── 02_scripts/
├── 03_results/
├── 04_figures/
├── 05_documents/
├── 06_references/
├── 07_archive/
├── README.md
├── PROJECT_STATUS.md
└── .gitignore
```

Create subfolders only when needed. Do not create empty or speculative
directory trees.

### Folder purposes

  -----------------------------------------------------------------------
  Folder                              What belongs here
  ----------------------------------- -----------------------------------
  `00_project-info/`                  Research questions, objectives,
                                      methodology notes, project log,
                                      data inventory, important decisions

  `01_data/`                          Original, processed, and supporting
                                      datasets

  `02_scripts/`                       R, Python, Google Earth Engine,
                                      MATLAB, and other analysis scripts

  `03_results/`                       Model outputs, statistical
                                      summaries, evaluation metrics, and
                                      analytical results

  `04_figures/`                       Maps, plots, diagrams, and
                                      publication figures

  `05_documents/`                     Manuscripts, reports,
                                      presentations, and supplementary
                                      material

  `06_references/`                    Literature notes, bibliographic
                                      files, papers where licensing
                                      permits, and source records

  `07_archive/`                       Superseded material that must be
                                      retained but is no longer active
  -----------------------------------------------------------------------

Recommended data subfolders, when useful:

``` text
01_data/
├── raw/
├── processed/
└── external/
```

Recommended figure subfolders, when useful:

``` text
04_figures/
├── working/
└── publication/
```

Recommended document subfolders, when useful:

``` text
05_documents/
├── manuscript/
├── reports/
├── presentations/
└── supplementary/
```

Keep the structure shallow. Add a subfolder only when it makes files
easier to find.

## 3. Naming conventions

### Folders

Use lowercase kebab-case, except for the numbered standard folders shown
above.

Examples:

-   `drought-analysis/`
-   `climate-modelling/`
-   `hydrological-modelling/`
-   `remote-sensing/`
-   `catchment-characterization/`

### Files

Use lowercase snake_case.

Examples:

-   `calculate_spei.R`
-   `precipitation_daily_2020_2025.csv`
-   `catchment_attributes.csv`
-   `model_performance_summary.xlsx`
-   `study_area_map.pdf`
-   `research_methodology.md`

Avoid spaces, unnecessary punctuation, vague names, and names such as
`final`, `latest`, `new`, `final_final`, or `test123`.

Use lowercase file extensions consistently: `.R`, `.py`, `.csv`, `.tif`,
`.nc`, `.gpkg`, `.docx`, `.pdf`, `.md`, `.xlsx`, `.svg`, and `.png`.

### Dates

Use `YYYYMMDD` in filenames when a date is useful.

Examples:

-   `20261127_research_meeting_notes.md`
-   `20261127_precipitation_data.csv`
-   `20261127_project_report.pdf`

Use `YYYY-MM-DD` in prose and human-readable documentation where it
improves readability.

### Versions

Use zero-padded versions for important deliverables:

-   `v001`
-   `v002`
-   `v003`

Examples:

-   `manuscript_v001.docx`
-   `response_to_reviewers_v002.docx`

Do not create multiple files named `final`, `latest`, or `final_final`.
Use Git for code and text history where practical; use explicit versions
for deliverables that need snapshots.

## 4. Data management and integrity

-   Preserve original datasets in `01_data/raw/`.
-   Never overwrite or manually modify raw data.
-   Store cleaned and transformed datasets in `01_data/processed/`.
-   Store supporting boundary files, reference layers, and externally
    supplied inputs in `01_data/external/`.
-   Record dataset name, provider, source URL or DOI, access date,
    temporal coverage, spatial resolution, units, coordinate reference
    system, and license where applicable.
-   Document filtering, missing-value treatment, outlier handling,
    transformations, and exclusions.
-   Preserve spatial metadata and variable units.
-   Avoid unnecessary duplicate copies of large datasets.
-   Do not commit large datasets to GitHub unless appropriate and
    permitted. Document how to obtain them instead.
-   Never redistribute restricted or licensed data without permission.

## 5. Scripts and analytical workflow

Keep scripts in `02_scripts/`. Use clear, action-oriented names and,
where execution order matters, numerical prefixes.

Example:

``` text
02_scripts/
├── 01_import_data.R
├── 02_clean_data.R
├── 03_calculate_drought_indices.R
├── 04_spatial_analysis.R
├── 05_model_validation.R
└── 06_generate_figures.R
```

Every major script should state:

1.  Its purpose.
2.  Required input files.
3.  Main processing steps.
4.  Output files and locations.
5.  Important parameters and assumptions.
6.  Software and package requirements.

Reproducibility rules:

-   Prefer project-relative paths; avoid machine-specific absolute
    paths.
-   Do not overwrite raw data.
-   Record important analytical parameters.
-   Set and record random seeds for stochastic methods.
-   Record software and package versions.
-   Preserve model settings, training/validation/test definitions, and
    evaluation procedures.
-   Make outputs regenerable from documented inputs and scripts.
-   Document manual steps that cannot be automated.
-   Avoid data leakage, including leakage across time or space where
    relevant.
-   Keep validation data independent from model fitting and tuning.

For R projects, use `here` for project-relative paths and `renv` to
record package dependencies when appropriate. Do not add tools merely
for appearance; use them when they improve reproducibility.

## 6. Results, figures, and documents

Store analytical outputs in `03_results/`. Keep intermediate results
distinct from final reported results where this distinction matters.

Store figures in `04_figures/`. Use names such as:

-   `fig_01_study_area.pdf`
-   `fig_02_methodology.pdf`
-   `fig_03_spatial_distribution.png`
-   `fig_04_model_performance.pdf`

Store tables with descriptive names:

-   `table_01_catchment_characteristics.csv`
-   `table_02_model_performance.csv`

Keep manuscripts, reports, presentations, and supplementary material in
`05_documents/`.

Use the separate `scientific_figure_standard.md` for figure design
whenever it is available. Figures must be reproducible from scripts and
documented inputs.

## 7. README requirements

Every project must have a root-level `README.md`. It should briefly
explain:

-   Project title and overview.
-   Research objectives.
-   Study area.
-   Data sources and access information.
-   Methodology overview.
-   Folder structure.
-   Script execution order.
-   Software requirements.
-   Reproducibility notes.
-   Key references.

Keep the README focused on explaining the project and how to navigate or
run it. Use `PROJECT_STATUS.md` for the changing project state and
session history.

## 8. General rules for OpenCode

### At the start of work

-   Inspect the existing project structure before changing it.
-   Read `README.md` and `PROJECT_STATUS.md`.
-   Review relevant scripts, data descriptions, and previous decisions.
-   Verify whether pending tasks are actually complete.
-   Preserve an existing logical structure rather than reorganizing it
    unnecessarily.

### While working

-   Save files in the appropriate existing folders.
-   Use the established naming conventions.
-   Avoid creating duplicate files or unnecessary subfolders.
-   Do not silently change data, methods, parameters, or outputs.
-   Do not delete or overwrite important files without explicit
    authorization.
-   Explain technical choices in language understandable to a
    researcher.

### At the end of work

-   Update `PROJECT_STATUS.md` as specified in that document.
-   Update `README.md` if project navigation, execution instructions, or
    dependencies changed.
-   Report files created, modified, and important outputs.
-   Identify incomplete work and unresolved issues honestly.

## 9. Archiving and project completion

Before archiving a project, ensure that:

-   The README and project status are current.
-   Data sources and licenses are documented.
-   Main scripts and execution order are available.
-   Important parameters and software dependencies are recorded.
-   Key outputs, figures, tables, and manuscripts are retained.
-   Known limitations and unresolved issues are documented.

Do not delete intermediate files required to reproduce or audit the
analysis.

## 10. Final rule

This is a practical research file-management standard, not a
software-engineering template. Keep the structure understandable to a
researcher. Scientific reproducibility, data integrity, and clarity take
priority over elaborate folder hierarchies.
