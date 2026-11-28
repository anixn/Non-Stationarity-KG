# RUN SUMMARY

> **Purpose:** a newest-first log of every run, written in plain language, so
> the project's progress can be understood without reading code or logs.
>
> **Companion files:** `working_file.md` §6 (the method),
> `project_status_template.md` (the project state).
>
> **Rules:** one entry per run. Newest at the top. Real numbers only, read
> from output files. State what is incomplete as clearly as what is finished.

**Project:**
**Last updated:** YYYY-MM-DD HH:MM

---

## Entry template (copy this block)

```markdown
## YYYY-MM-DD HH:MM — Short title

**Command run:** `____`
**Result:** Completed / Partly completed / Failed

### What ran
One or two sentences in plain language.

### What changed
| File | Change |
|---|---|
| | |

### Key numbers
| Item | Value | Where |
|---|---|---|
| | | |

### What it means
Two to four sentences. What this changes for the study, and what it does not.

### Checks performed
- [ ] Script exited without error
- [ ] Output files exist with today's timestamp
- [ ] Row and catchment counts match expectations
- [ ] No "Error" in the log
- [ ] Figure opens and passes the checklist

### Problems and warnings
Skipped steps, warnings, unresolved issues. Say if a check was not performed.

### Status now
Stage: Analysis / Validation / Figures / Writing
Done: …
Not done: …

### Next action
One concrete step.
```

---

## Filled example

The numbers below are illustrative — replace them with values read from your
own output files.

```markdown
## 2026-11-28 14:05 — GR4J validation stage

**Command run:** `Rscript 02_scripts/05_model_validation.R`
**Result:** Completed

### What ran
Scored the calibrated GR4J models on the 2001–2014 validation window for
every catchment that passed calibration.

### What changed
| File | Change |
|---|---|
| `03_results/model_performance_summary.csv` | Rewritten, 192 rows |
| `04_figures/publication/fig_04_model_performance.pdf` | Redrawn |

### Key numbers
| Item | Value | Where |
|---|---|---|
| Median KGE, calibration (1981–2000) | 0.80 | Table T3 |
| Median KGE, validation (2001–2014) | 0.54 | Table T3 |
| Catchments scored | 192 of 222 | `03_results/coverage.csv` |

### What it means
Validation skill is lower than calibration skill, as expected, but the median
is still above 0.5, so the model is usable for the low-flow analysis. Thirty
catchments were not scored because they failed calibration; this is recorded
in the exclusion log and does not change the validation sample definition.

### Checks performed
- [x] Script exited without error
- [x] Output files exist with today's timestamp
- [x] Row and catchment counts match expectations (192)
- [x] No "Error" in the log
- [x] Figure opens and passes the checklist

### Problems and warnings
Two catchments have `n_gap_filled` above 10 % of the validation record. Flagged
in the output table; sensitivity run not yet done.

### Status now
Stage: Validation
Done: Calibration and validation scored for all eligible catchments.
Not done: Gap-fill sensitivity; manuscript Table T3 update.

### Next action
Run the gap-fill sensitivity and then update Table T3.
```

---

## One-line receipt (for chat or a quick note)

```text
Run YYYY-MM-DD HH:MM: <what> → <completed/failed>; <key number 1>, <key number 2>; <what changed>; next: <action>.
```

Example shape (numbers illustrative):

```text
Run 2026-11-28 14:05: validation → completed; 192/222 catchments, median KGE 0.80 calibration / 0.54 validation; fig_04 redrawn; next: update Table T3 in the manuscript.
```

---

## Entries

<!-- Newest entry at the top. Do not delete old entries. -->
