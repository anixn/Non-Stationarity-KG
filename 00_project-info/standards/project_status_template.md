# Project Status and Research Summary

> **Purpose:** This is the plain-language, continuously updated overview
> of the study. It should allow the researcher to understand the
> research question, current progress, findings, problems, and next
> steps without reading code or terminal logs.

**Last updated:** YYYY-MM-DD HH:MM\
**Overall status:** Planning / Data collection / Data preparation /
Analysis / Modelling / Validation / Manuscript preparation / Completed\
**Current stage:**\
**Last working session:** YYYYMMDD

> **Companions:** `RUN_SUMMARY.md` holds the run-by-run technical log;
> this file holds the readable state of the project. `FIGURES.md` holds the
> figure register. Write the run summary first, then update this file from it.

------------------------------------------------------------------------

## 1. What is this study about?

Explain the study in clear, non-technical language.

-   **Problem:** What real-world or scientific problem is being
    investigated?
-   **Why it matters:** Why is the problem important?
-   **Research question:** What does the study seek to answer?
-   **Intended contribution:** What new understanding, method, dataset,
    or evidence may the study provide?

A researcher should understand the broad purpose of the study from this
section alone.

## 2. Research objectives

1.  Objective 1.
2.  Objective 2.
3.  Objective 3.

Update these only when the research objectives genuinely change. Record
important changes in the decision log.

## 3. Overall project status

  -----------------------------------------------------------------------
  Research stage          Status                  Short explanation
  ----------------------- ----------------------- -----------------------
  Research design         Not started / In        
                          progress / Completed /  
                          Blocked                 

  Data acquisition        Not started / In        
                          progress / Completed /  
                          Blocked                 

  Data preparation        Not started / In        
                          progress / Completed /  
                          Blocked                 

  Analysis and modelling  Not started / In        
                          progress / Completed /  
                          Blocked                 

  Validation and          Not started / In        
  uncertainty             progress / Completed /  
                          Blocked                 

  Figures and tables      Not started / In        
                          progress / Completed /  
                          Blocked                 

  Manuscript              Not started / In        
                          progress / Completed /  
                          Blocked                 
  -----------------------------------------------------------------------

Use evidence to assign statuses. Do not mark work complete merely
because a script or task was attempted.

## 4. Data and resources

  --------------------------------------------------------------------------
  Dataset or     Purpose        Period /       Source and DOI Status /
  resource                      coverage                      limitations
  -------------- -------------- -------------- -------------- --------------
                                                              

  --------------------------------------------------------------------------

Record important data characteristics: spatial and temporal resolution,
units, coordinate reference system, licensing, access date, missing
data, and known limitations.

## 5. Methodology in simple language

Describe the study workflow in numbered steps. For each step, explain:

-   What is done?
-   Why is it needed?
-   What input is used?
-   What output is produced?
-   How is the result checked?

Avoid unnecessary programming detail. Link to the relevant scripts where
useful.

## 6. Key findings so far

Summarize findings using actual evidence and values where available.

For each finding, state whether it is:

-   **Preliminary:** An early observation that has not completed
    validation.
-   **Validated:** Checked using the documented analytical and
    validation procedure.
-   **Uncertain:** Evidence is incomplete, conflicting, or sensitive to
    assumptions.

Do not present preliminary results as established conclusions. Include
sample sizes, periods, units, and relevant uncertainty where
appropriate.

## 7. Latest working session

**Date:** YYYYMMDD\
**Session objective:**\
**Session outcome:** Completed / Partially completed / Not completed

> The detailed run entries for this session are in `RUN_SUMMARY.md`.
> Summarise them here; do not paste the whole log.

### Work completed

Explain in plain language what was done and why it matters to the study.

### Files created

  File and location   Purpose
  ------------------- ---------
                      

### Files modified

  File and location   What changed
  ------------------- --------------
                      

### Results and interpretation

Explain what the work produced and what the results mean. Distinguish
successful execution from scientific validation.

### Problems and errors

Record errors, data issues, failed approaches, and unresolved problems.
State whether each issue was resolved.

### Decisions made

Record methodological or project decisions and the reason for each
decision. Do not silently change previously agreed methods.

### Verification performed

State what was actually checked, such as file integrity, record counts,
units, spatial alignment, code execution, statistical assumptions, or
independent validation. Do not claim checks that were not performed.

## 8. Pending tasks

  Priority   Task   Why it is needed   Status / dependency
  ---------- ------ ------------------ ---------------------
  High                                 Pending
  Medium                               Pending
  Low                                  Pending

Prioritize tasks that affect scientific validity, data integrity, or the
ability to reproduce results.

## 9. Next recommended steps

List the next practical actions in execution order. Explain briefly why
each is needed. These are recommendations, not claims that the work has
already been done.

## 10. Important research decisions and limitations

Maintain a concise record of:

-   Methodological assumptions.
-   Changes in analytical approach.
-   Parameter choices and their justification.
-   Data limitations and exclusions.
-   Validation design and potential leakage risks.
-   Spatial or temporal dependence concerns.
-   Uncertainty and sensitivity issues.
-   Decisions that should not be changed without scientific
    justification.

## 11. Reproducibility and execution

-   **Main scripts and execution order:**
-   **Input data locations:**
-   **Output locations:**
-   **Figure script and register:**
-   **Software and versions:**
-   **R package environment / `renv.lock`:**
-   **Python environment, if applicable:**
-   **Random seeds:**
-   **Configuration and parameter files:**
-   **Known execution requirements or issues:**

Explain what is required for another researcher to reproduce the main
results.

## 12. Overall research assessment

Provide a concise, evidence-based assessment:

-   How much of the original research objective has been addressed?
-   Which findings are currently supported?
-   What are the main methodological weaknesses?
-   What additional validation or uncertainty analysis is needed?
-   What remains before submission or publication?

Do not make unsupported claims about novelty, significance, or
publication readiness.

## 13. Session history

Add the newest session at the top. Preserve previous entries; do not
replace the history with only the latest session.

### YYYYMMDD --- Short session title

-   **Objective:**
-   **Work completed:**
-   **Files created or modified:**
-   **Results:**
-   **Problems or unresolved issues:**
-   **Decisions:**
-   **Next steps:**

------------------------------------------------------------------------

## Instructions for maintaining this file

### At the beginning of every working session

1.  Read `README.md`.
2.  Read `PROJECT_STATUS.md`.
3.  Read the latest entries in `RUN_SUMMARY.md` and check `FIGURES.md`.
4.  Review the latest session and pending tasks.
5.  Inspect relevant files before assuming the state of the project.
6.  Verify important claims when necessary.

### At the end of every working session

Append a run entry to `RUN_SUMMARY.md` (five-question report), update
`FIGURES.md` for any figure created or changed, then update this file before
reporting the session as complete. Include the date, objective, work
performed, files changed, results, problems, decisions, checks performed, and
next steps.

Also update the overall project description, stage statuses, findings,
and limitations if the session changed them.

### Writing rules

-   Use simple, direct English suitable for a researcher who does not
    need to inspect source code.
-   Explain what was done, why it was done, and what it means for the
    study.
-   Include meaningful numbers and actual outcomes where available.
-   Distinguish attempted work, successfully executed work, and
    scientifically validated work.
-   Never invent results, progress, tests, or successful completion.
-   If work was interrupted, state exactly what remains incomplete.
-   Preserve historical session summaries and important decisions.
-   Keep the document useful and concise; do not repeat unchanged
    technical details unnecessarily.

**Final requirement:** After every substantive working session, this
file must answer four questions: What did OpenCode do? What does it mean
for the study? What is the overall project state now? What should happen
next?
