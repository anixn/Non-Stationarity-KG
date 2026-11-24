// Inject revision-specific LaTeX preamble fixes into the pandoc-generated
// manuscript and write manuscript.tex.
const fs = require('fs');
const path = require('path');

const dir = '03-writeup/Revision-1/latex';
const src = path.join(dir, 'manuscript_pandoc.tex');
const dst = path.join(dir, 'manuscript.tex');

let tex = fs.readFileSync(src, 'utf8');

const extra = `
% --- Revision-specific preamble (added by build.js, do not edit by hand) -----
\\usepackage{textgreek}
\\newunicodechar{\u03c9}{\\textomega}
\\newunicodechar{\u03b4}{\\textdelta}
\\newunicodechar{\u2265}{\\ensuremath{\\geq}}
\\newunicodechar{\u2264}{\\ensuremath{\\leq}}
\\newunicodechar{\u00d7}{\\ensuremath{\\times}}
\\newunicodechar{\u2212}{\\textendash}
\\setcounter{secnumdepth}{3}
\\graphicspath{{./}}
\\usepackage{setspace}
\\linespread{1.15}
`;

tex = tex.replace(/\\begin\{document\}/, extra + '\n\\begin{document}');
if (!tex.includes('Revision-specific preamble')) {
  console.error('injection point not found');
  process.exit(1);
}
fs.writeFileSync(dst, tex);
console.log('wrote', dst, tex.length, 'bytes');
