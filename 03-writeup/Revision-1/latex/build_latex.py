"""Inject revision-specific LaTeX preamble fixes into the pandoc-generated
manuscript and write manuscript.tex. Run from the project root."""
import io
import os
import shutil
import sys

DIR = '03-writeup/Revision-1/latex'
SRC = f'{DIR}/manuscript_pandoc.tex'
DST = f'{DIR}/manuscript.tex'
FIGDIR = '02-outputs/revision/figures'
SIDIR = f'{DIR}/si'

MARK = '% --- Revision-specific preamble (added by build_latex.py, do not edit) ---'

extra = r"""
\usepackage{newunicodechar}
\newunicodechar{@OMEGA@}{\ensuremath{\omega}}
\newunicodechar{@DELTA@}{\ensuremath{\delta}}
\newunicodechar{@GE@}{\ensuremath{\geq}}
\newunicodechar{@LE@}{\ensuremath{\leq}}
\newunicodechar{@H2010@}{-}
\newunicodechar{@MINUS@}{\textminus}
\newunicodechar{@GRAVE@}{\`{}}
\newunicodechar{@ACUTE@}{\'{}}
\newunicodechar{@TIMES@}{\texttimes}
\setcounter{secnumdepth}{0}
\usepackage{setspace}
\linespread{1.15}
\usepackage{graphicx}
""".replace('@OMEGA@', chr(0x03C9)).replace('@DELTA@', chr(0x03B4)) \
   .replace('@GE@', chr(0x2265)).replace('@LE@', chr(0x2264)).replace('@H2010@', chr(0x2010)) \
   .replace('@MINUS@', chr(0x2212)).replace('@GRAVE@', chr(0x0300)) \
   .replace('@ACUTE@', chr(0x0301)).replace('@TIMES@', chr(0x00D7))

extra = MARK + extra

with io.open(SRC, encoding='utf-8') as f:
    tex = f.read()

# Remove a previously injected block, then inject fresh.
if MARK in tex:
    start = tex.index(MARK)
    end = tex.index('\\begin{document}', start)
    tex = tex[:start] + tex[end:]

if '\\begin{document}' not in tex:
    sys.exit('injection point not found')

tex = tex.replace('\\begin{document}', extra + '\n\\begin{document}')

# Figures: pandoc writes absolute inches from the docx, which overflow the text
# width. Scale every included image to the line width instead.
import re
tex = re.sub(r'\\includegraphics\[[^\]]*\]', r'\\includegraphics[width=\\linewidth,keepaspectratio]', tex)

# Captions already carry their number in the docx text ("Figure 8 ...").
# Strip it so the auto-generated caption number is not duplicated.
tex = re.sub(r'\\caption\{(Figure|Table)\s*\d+[a-zA-Z]?(:\s*|\s+)', r'\\caption{', tex)

# ------------------------------------------------------------------ SI figures
SI_FIGS = [
    ('F1_calibration_performance', 'Figure S1',
     'Distribution of the median KGE and NSE of the retained behavioural sets '
     'across the 332 candidate catchments. The dashed line marks KGE = 0.5.'),
    ('F2_split_sample', 'Figure S2',
     'Differential split-sample validation. Median KGE in the calibration period '
     'against the validation period for the forward and reverse directions; the '
     'dashed line is the 1:1 line and the dotted line is KGE = 0.5.'),
    ('F3_parameter_drift', 'Figure S3',
     'Parameter drift from 10-year moving-window recalibration, averaged by '
     'K\\"oppen-Geiger class (mean $\\\\pm$ one standard error).'),
    ('F4_kg_baseline_map', 'Figure S4',
     'Baseline K\\"oppen-Geiger class of the analysed catchments (1981-2010), '
     'assigned with the Beck et al. (2023) scheme.'),
    ('F5_kg_transition_map', 'Figure S5',
     'Fraction of the 121 synthetic scenarios in which a catchment leaves its '
     'baseline K\\"oppen-Geiger class.'),
    ('F6_variance_partition', 'Figure S6',
     'Variance partitioning of the behavioural parameter values into climate, '
     'physiography, shared and unexplained fractions.'),
    ('F7_rf_importance', 'Figure S7',
     'Random-forest importance of the climate and physiographic attributes for '
     'each parameter.'),
    ('F10b_sensitivity_LFI_MAMF', 'Figure S8',
     'PRCC and Sobol sensitivity of the HBV parameters for LFI and MAMF in the '
     'six representative catchments.'),
    ('F11_uncertainty', 'Figure S9',
     'Parametric uncertainty of the three indicators arising from the 200 '
     'retained behavioural sets.'),
    ('F12_threshold_identifiability', 'Figure S10',
     'Share of catchments with an identifiable precipitation and temperature '
     'threshold for each indicator and framework.'),
]

# Result tables, in manuscript order, with the number used in the text.
SI_TABLES = [
    ('T3_calibration_summary', 'Table 3', 'Calibration performance of the 332 candidate catchments.'),
    ('T4_split_sample_summary', 'Table 4', 'Differential split-sample validation.'),
    ('T5_kg_transition_summary', 'Table 5', 'Observed decadal K\\"oppen-Geiger transitions, 1981-2010.'),
    ('T5b_kg_map_transitions', 'Table 5b', 'Delta-change K\\"oppen-Geiger class change for the 12 map levels.'),
    ('T6_climate_vs_physiography', 'Table 6', 'Climate against physiography variance shares of the parameter values.'),
    ('T7_threshold_comparison', 'Table 7', 'Precipitation and temperature thresholds by indicator and framework.'),
    ('T7_threshold_identifiability', 'Table 7b', 'Identifiability of the thresholds by indicator and framework.'),
    ('T8_threshold_decomposition', 'Table 8', 'Decomposition of the SPF-CZIPEF threshold differences.'),
    ('T9_sensitivity_summary', 'Table 9', 'Significant parameters by class and indicator.'),
]

os.makedirs(SIDIR, exist_ok=True)
appendix = ['\\clearpage', '\\appendix']

if os.path.isdir(FIGDIR):
    appendix.append('\\section{Supplementary figures}')
    appendix.append('Figures generated by \\texttt{01-analysis/R/10\\_figures.R} '
                    'from the Revision 1 production run.')
    for name, label, cap in SI_FIGS:
        src = os.path.join(FIGDIR, name + '.png')
        if not os.path.exists(src):
            continue
        shutil.copyfile(src, os.path.join(SIDIR, name + '.png'))
        appendix.append('\\begin{figure}[p]')
        appendix.append('\\centering')
        appendix.append(f'\\includegraphics[width=\\textwidth,height=0.85\\textheight,'
                        f'keepaspectratio]{{03-writeup/Revision-1/latex/si/{name}.png}}')
        appendix.append(f'\\caption*{{{label} {cap}}}')
        appendix.append('\\end{figure}')

tbl_dir = f'{DIR}/tables'
appendix.append('\\clearpage')
appendix.append('\\section{Revision result tables}')
appendix.append('Tables generated from \\texttt{02-outputs/revision/tables} by '
                '\\texttt{make\\_tables.R}. Column headers keep the CSV field names '
                'so that every number in the text is traceable to the pipeline output.')
for name, label, cap in SI_TABLES:
    if not os.path.exists(os.path.join(tbl_dir, name + '.tex')):
        continue
    appendix.append('\\begin{table}[p]')
    appendix.append('\\centering')
    appendix.append(f'\\resizebox{{\\textwidth}}{{!}}{{\\input{{03-writeup/Revision-1/latex/tables/{name}}}}}')
    appendix.append(f'\\caption*{{{label} {cap}}}')
    appendix.append('\\end{table}')

tex = tex.replace('\\end{document}', '\n'.join(appendix) + '\n\\end{document}')

with io.open(DST, 'w', encoding='utf-8') as f:
    f.write(tex)
print('wrote', DST, len(tex), 'bytes')
