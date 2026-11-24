# Build the Revision 1 manuscript from the docx source and the pipeline tables.
# Usage (from the project root):  powershell -File 03-writeup/Revision-1/latex/build_all.ps1
# Steps:
#   1. pandoc:  docx -> manuscript_pandoc.tex (+ media/)
#   2. python : inject the revision preamble -> manuscript.tex
#   3. R      : CSV tables -> booktabs .tex files in tables/
#   4. latexmk: manuscript.tex -> build/manuscript.pdf

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\..\..')   # project root

pandoc '03-writeup/Revision-1/Deshmukh_2025_KG_R1.docx' `
  -f docx -t latex -s `
  -o '03-writeup/Revision-1/latex/manuscript_pandoc.tex' `
  --extract-media='03-writeup/Revision-1/latex/media' `
  --top-level-division=section

python '03-writeup/Revision-1/latex/build_latex.py'

# Tables only exist after the production run; skip quietly otherwise.
if (Test-Path '02-outputs/revision/tables') {
  & 'C:\Program Files\R\R-4.4.1\bin\Rscript.exe' `
    '03-writeup/Revision-1/latex/make_tables.R'
}

latexmk -pdf -interaction=nonstopmode `
  -output-directory='03-writeup/Revision-1/latex/build' `
  '03-writeup/Revision-1/latex/manuscript.tex'

Write-Host 'PDF: 03-writeup/Revision-1/latex/build/manuscript.pdf'
