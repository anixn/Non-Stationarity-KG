# Generate booktabs LaTeX tables from the revision pipeline outputs.
# Writes one .tex file per table into 03-writeup/Revision-1/latex/tables/.
# Each file contains a full tabular (no floats), ready for \input in the
# manuscript or for the response letter.

if (!exists("PROJ")) {
  .a <- commandArgs(FALSE); .f <- sub("^--file=", "", .a[grep("^--file=", .a)])
  .root <- if (length(.f)) dirname(dirname(dirname(dirname(normalizePath(.f))))) else getwd()
  source(file.path(.root, "01-analysis", "R", "00_config.R"))
  source(file.path(.root, "01-analysis", "R", "01_functions.R"))
}

out_dir <- file.path(PROJ, "03-writeup", "Revision-1", "latex", "tables")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

esc <- function(x) {
  x <- as.character(x)
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([&%$#_{}])", "\\\\\\1", x)
  x <- gsub("~", "\\\\textasciitilde{}", x, fixed = TRUE)
  x <- gsub("\\^", "\\\\textasciicircum{}", x, fixed = TRUE)
  x
}

fmt <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "--"
  num <- suppressWarnings(as.numeric(x))
  ok <- !is.na(num)
  x[ok] <- formatC(num[ok], format = "g", digits = 3)
  esc(x)
}

write_tab <- function(df, file, caption = NULL, align = NULL) {
  n <- ncol(df)
  if (is.null(align)) align <- paste(c("l", rep("r", n - 1)), collapse = "")
  body <- apply(df, 2, fmt)
  if (nrow(df) == 1) body <- matrix(body, nrow = 1)
  rows <- apply(body, 1, function(r)
    paste0(paste(r, collapse = " & "), " \\\\"))
  hdr <- paste(esc(names(df)), collapse = " & ")
  lines <- c(
    "% auto-generated from 02-outputs/revision/tables -- do not edit",
    if (!is.null(caption)) paste0("% ", caption),
    "\\begin{tabular}{", align, "}",
    "\\toprule",
    paste0(hdr, " \\\\"),
    if (n > 1) paste0("\\cmidrule(lr){2-", n, "}"),
    rows,
    "\\bottomrule",
    "\\end{tabular}"
  )
  con <- file(file.path(out_dir, file), open = "wb")
  writeLines(lines, con, useBytes = TRUE)
  close(con)
  cat("wrote", file.path(out_dir, file), "\n")
}

TAB <- DIR_TAB
kgf <- DIR_KG

if (file.exists(file.path(TAB, "T3_calibration_summary.csv"))) {
  d <- read_out(file.path(TAB, "T3_calibration_summary.csv"))
  write_tab(d, "T3_calibration_summary.tex", caption = "Calibration summary")
}
if (file.exists(file.path(TAB, "T4_split_sample_summary.csv"))) {
  d <- read_out(file.path(TAB, "T4_split_sample_summary.csv"))
  write_tab(d, "T4_split_sample_summary.tex",
            caption = "Differential split-sample validation")
}
if (file.exists(file.path(TAB, "T5_kg_transition_summary.csv"))) {  d <- read_out(file.path(TAB, "T5_kg_transition_summary.csv"))
  write_tab(d, "T5_kg_transition_summary.tex", caption = "Observed KG transitions")
}
if (file.exists(file.path(kgf, "kg_map_summary.csv"))) {
  d <- read_out(file.path(kgf, "kg_map_summary.csv"))
  write_tab(d, "T5b_kg_map_transitions.tex",
            caption = "Delta-change KG map transitions")
}
if (file.exists(file.path(TAB, "T6_climate_vs_physiography.csv"))) {
  d <- read_out(file.path(TAB, "T6_climate_vs_physiography.csv"))
  write_tab(d, "T6_climate_vs_physiography.tex",
            caption = "Climate vs physiography variance shares")
}
if (file.exists(file.path(TAB, "T7_threshold_comparison.csv"))) {
  d <- read_out(file.path(TAB, "T7_threshold_comparison.csv"))
  write_tab(d, "T7_threshold_comparison.tex", caption = "Threshold comparison")
}
if (file.exists(file.path(TAB, "T7_threshold_identifiability.csv"))) {
  d <- read_out(file.path(TAB, "T7_threshold_identifiability.csv"))
  write_tab(d, "T7_threshold_identifiability.tex",
            caption = "Threshold identifiability")
}
if (file.exists(file.path(TAB, "T8_threshold_decomposition.csv"))) {
  d <- read_out(file.path(TAB, "T8_threshold_decomposition.csv"))
  write_tab(d, "T8_threshold_decomposition.tex",
            caption = "SPF-CZIPEF decomposition")
}
if (file.exists(file.path(TAB, "T9_sensitivity_summary.csv"))) {
  d <- read_out(file.path(TAB, "T9_sensitivity_summary.csv"))
  write_tab(d, "T9_sensitivity_summary.tex", caption = "Sensitivity summary")
}
