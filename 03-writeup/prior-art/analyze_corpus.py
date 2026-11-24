"""Parse the merged WOS prior-art corpus and produce a cluster overview.

Outputs (same folder):
  wos_corpus.csv       - flat record list (key, year, title, journal)
  WOS_CLUSTER_REPORT.md - thematic clusters with counts and titles
"""
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path

DIR = Path(__file__).parent
TEXT = (DIR / "WOS_corpus_merged.bib").read_text(encoding="utf-8")

entries = re.split(r"(?m)^(?=@article\{)", TEXT)
entries = [e for e in entries if e.startswith("@article{")]

FIELD = re.compile(r"(?m)^\s*([A-Za-z-]+)\s*=\s*\{")


def field(entry: str, name: str) -> str:
    m = re.search(rf"(?m)^\s*{name}\s*=\s*\{{", entry, re.IGNORECASE)
    if not m:
        return ""
    start = m.end()
    depth = 1
    i = start
    while i < len(entry) and depth:
        if entry[i] == "{":
            depth += 1
        elif entry[i] == "}":
            depth -= 1
        i += 1
    return entry[start : i - 1].strip().replace("\n", " ")


records = []
for e in entries:
    key = field(e.split("\n", 1)[0], "@article")
    m = re.match(r"@article\{\s*([A-Za-z0-9:_-]+)", e)
    key = m.group(1) if m else ""
    records.append(
        {
            "key": key,
            "year": field(e, "year") or field(e, "Year"),
            "title": re.sub(r"\s+", " ", field(e, "Title")),
            "journal": re.sub(r"\s+", " ", field(e, "Journal")),
        }
    )

with open(DIR / "wos_corpus.csv", "w", newline="", encoding="utf-8-sig") as f:
    w = csv.DictWriter(f, fieldnames=["key", "year", "title", "journal"])
    w.writeheader()
    w.writerows(records)

# ---- thematic clusters -------------------------------------------------
CLUSTERS = {
    "Parameter non-stationarity / time-varying parameters": [
        "non-stationar* parameter", "time-varying parameter", "temporal* parameter",
        "dynamic parameter", "parameter evolution", "evolving parameter",
        "parameter drift", "changing parameter", "adaptive parameter",
    ],
    "Model transferability / stationarity assumption": [
        "transferab*", "stationarity", "stationary assumption", "generalisation",
        "generaliz*", "spatial transference",
    ],
    "Koppen / climate classification + hydrology": [
        "koppen", "climate classification", "climate zone", "climatic zone",
        "climate class", "geiger",
    ],
    "Regionalization / similarity / catchment classification": [
        "regionaliz*", "regionalis*", "regionalisation", "regionalization",
        "donor catchment", "physical similarity", "hydrological similarity",
        "catchment classification", "ungauged", "proximity",
    ],
    "Climate change impact + conceptual / lumped models": [
        "HBV", "GR4J", "HYMOD", "Sacramento", "conceptual rainfall-runoff",
        "conceptual hydrological model", "lumped model", "rainfall-runoff model",
    ],
    "Vulnerability / resilience / risk frameworks": [
        "vulnerability", "resilience", "susceptibility", "exposure",
        "sensitivity analysis", "fragility",
    ],
    "Delta-change / scenario experiments": [
        "delta change", "delta-change", "perturbation approach", "sensitivity-based climate",
        "climate scenario", "forcing perturbation", "what-if",
    ],
    "Low-flow / drought indices under change": [
        "low flow", "low-flow", "drought index", "baseflow index", "MAMF", "Q95",
        "flow duration", "7-day", "dry spell",
    ],
    "Uncertainty ( behavioural / GLUE / Monte Carlo / sensitivity )": [
        "GLUE", "behavioural", "behavioral", "Monte Carlo", "Latin hypercube",
        "Sobol", "PRCC", "sensitivity analysis", "equifinality", "uncertainty analysis",
    ],
    "CMIP6 / projections / bias correction": [
        "CMIP6", "GCM", "bias correction", "downscaling", "SSP", "RCP", "projection",
    ],
    "Snow / energy / PET in hydrological response": [
        "snowmelt", "degree-day", "snow pack", "potential evapotranspiration",
        "PET", "aridity", "energy balance",
    ],
}


def glob_match(title: str, pat: str) -> bool:
    rx = re.escape(pat).replace(r"\*", r"[a-z]*")
    return re.search(rx, title, re.IGNORECASE) is not None


assign = defaultdict(list)
unassigned = []
for r in records:
    t = r["title"].lower()
    hits = [c for c, pats in CLUSTERS.items() if any(glob_match(t, p) for p in pats)]
    if hits:
        for h in hits:
            assign[h].append(r)
    else:
        unassigned.append(r)

lines = [
    "# WOS prior-art corpus - thematic overview",
    "",
    f"Records: **{len(records)}** (merged, deduplicated; export from Web of Science",
    "Core Collection, institutional IP, queried 2026-11-24).",
    "",
    "| Cluster | Records | 2022-2026 share |",
    "|---|---|---|",
]
for c in CLUSTERS:
    rs = assign.get(c, [])
    recent = sum(1 for r in rs if r["year"] and int(r["year"]) >= 2022)
    lines.append(f"| {c} | {len(rs)} | {recent}/{len(rs)} |")
recent_all = sum(1 for r in records if r["year"] and int(r["year"]) >= 2022)
lines.append(f"| *all records* | {len(records)} | {recent_all}/{len(records)} |")
lines += ["", "## Year distribution", "", "| Year | Count |", "|---|---|"]
yc = Counter(r["year"] for r in records)
for y in sorted(yc, reverse=True):
    lines.append(f"| {y} | {yc[y]} |")
lines += ["", "## Cluster contents (titles, newest first)", ""]
for c in CLUSTERS:
    rs = assign.get(c, [])
    rs.sort(key=lambda r: r["year"], reverse=True)
    lines += [f"### {c} ({len(rs)})", ""]
    for r in rs[:60]:
        lines.append(f"- ({r['year']}) {r['title']} — *{r['journal']}*")
    if len(rs) > 60:
        lines.append(f"- ... ({len(rs)-60} more, see wos_corpus.csv)")
    lines.append("")
(DIR / "WOS_CLUSTER_REPORT.md").write_text("\n".join(lines), encoding="utf-8")
print(f"records={len(records)} clusters={len(CLUSTERS)} unassigned={len(unassigned)}")
print("wrote wos_corpus.csv and WOS_CLUSTER_REPORT.md")
