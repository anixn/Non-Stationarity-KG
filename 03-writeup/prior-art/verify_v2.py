"""Verify: any remaining author-year text citations in the built tex?"""
import re
from pathlib import Path

t = Path(r"D:/Research/Non-Stationarity-KG/03-writeup/Revision-1/latex-v2/manuscript.tex").read_text(encoding="utf-8")
# main text = before bibliography
main = t.split("\\bibliographystyle")[0]

left = []
for m in re.finditer(r"\(([^()]*\b(?:19|20)\d{2}[a-z]?\b[^()]*)\)", main):
    c = m.group(1).strip()
    if re.search(r"[A-Za-z]{3,}", c):  # has letters -> likely a citation
        left.append(c)

narr = []
for m in re.finditer(r"[A-Z][A-Za-z'\-]+(?:\s+(?:et\s+al\.|\\\&\s+[A-Z][A-Za-z'\-]+))?\s*\((?:19|20)\d{2}\)", main):
    narr.append(m.group(0))

print("leftover paren groups with letters:", len(left))
for x in left:
    print("  ", x[:120])
print("leftover narrative:", len(narr))
for x in narr:
    print("  ", x[:120])
print("citep count:", main.count("\\citep{"), " citet count:", main.count("\\citet{"))
