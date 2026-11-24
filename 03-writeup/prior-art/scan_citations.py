"""Scan manuscript.tex for author-year citation patterns; list distinct tokens."""
import re
from pathlib import Path

SRC = Path(r"D:/Research/Non-Stationarity-KG/03-writeup/Revision-1/latex/manuscript.tex")
t = SRC.read_text(encoding="utf-8")

# skip the References section body
ref_start = t.find(r"\section{References}")
main = t[:ref_start]

GROUP = re.compile(r"\(([^()]{0,300}?[^()]{0,300}?)\)")
toks = set()
for m in re.finditer(r"\(([^()]*\b(?:19|20)\d{2}[a-z]?\b[^()]*)\)", main):
    toks.add(m.group(1))

narrative = set()
for m in re.finditer(r"([A-Z][\w'\-]+(?:[ \-][A-Z][\w'\-]+|\s+et\ al\.|\s+\\\&|\s+and\b|,\s*[A-Z]\.|\\&[A-Za-z\-\s]+)*)\s*\((?:19|20)\d{2}[a-z]?(?:,\s*(?:19|20)\d{2}[a-z]?)*\)", main):
    narrative.add(m.group(1))

print(f"paren groups: {len(toks)}")
for x in sorted(toks):
    print("  P |", x.replace("\n", " "))
print(f"narrative: {len(narrative)}")
for x in sorted(narrative):
    print("  N |", x.replace("\n", " "))
