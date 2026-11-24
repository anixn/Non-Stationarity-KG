"""Remove the single duplicate entry (block ends at the next '^@' or EOF)."""
import re
from pathlib import Path

f = Path(r"D:/Research/Non-Stationarity-KG/03-writeup/Revision-1/latex-v2/references.bib")
t = f.read_text(encoding="utf-8")
pat = re.compile(r"(?ms)^@article\{wos_identificationoftimevaryingpar,.*?\n\}\n\n")
matches = list(pat.finditer(t))
print("occurrences:", len(matches))
if len(matches) > 1:
    m = matches[1]  # remove the SECOND occurrence only
    t = t[: m.start()] + t[m.end():]
    f.write_text(t, encoding="utf-8")

t = f.read_text(encoding="utf-8")
keys = re.findall(r"(?m)^@(\w+)\{([^,]+),", t)
import collections
print("entries:", len(keys), "dupes:", [k for k, c in collections.Counter(k for _, k in keys).items() if c > 1] or "none")
