"""Regenerate WOS picks with unique readable keys; skip entries already in the KG bib."""
import re
import unicodedata
from pathlib import Path

ROOT = Path(r"D:/Research/Non-Stationarity-KG/03-writeup")
KG = (ROOT / "references" / "KG_Bibliography.bib").read_text(encoding="utf-8")
CORPUS = (ROOT / "prior-art" / "WOS_corpus_merged.bib").read_text(encoding="utf-8")


def norm(s):
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", s).strip().lower()


def field(e, name):
    m = re.search(rf"(?m)^\s*{name}\s*=\s*\{{", e, re.IGNORECASE)
    if not m:
        return ""
    i = m.end()
    depth, start = 1, i
    while i < len(e) and depth:
        if e[i] == "{":
            depth += 1
        elif e[i] == "}":
            depth -= 1
        i += 1
    return re.sub(r"\s+", " ", e[start : i - 1].strip())


# KG bib: titles + years (normalised) to detect duplicates
kg_titles = set()
for e in re.split(r"(?m)^(?=@)", KG)[1:]:
    t = field(e, "title")
    if t:
        kg_titles.add(norm(t)[:70])
    y = field(e, "year")
    if t and y:
        kg_titles.add(norm(t)[:70] + "|" + y)

TARGETS = [  # (readable key, title fragment)
    ("jahanshahi2022transferability", "Dependence of rainfall-runoff model transferability on climate conditions in Iran"),
    ("liu2025budykotvp", "Identification of time-varying parameters of a monthly Budyko function"),
    ("liu2024spatiotemporalcalibration", "A calibration framework for distributed hydrological models considering spatiotemporal"),
    ("zhang2024tvpforecasting", "Time-varying parameters from the same period in previous years"),
    ("krapu2022differentiable", "A Differentiable Hydrology Approach for Modeling With Time-Varying Parameters"),
    ("zhou2022tvpdiagnosis", "Diagnosing structural deficiencies of a hydrological model by time-varying parameters"),
    ("zhou2022weitvp", "Identification of Time-Varying Parameters of Distributed Hydrological Model in Wei River"),
    ("zhangliu2021tvpsplitsample", "A time-varying parameter estimation approach using split-sample calibration"),
    ("seibert2022retrospective", "A retrospective on hydrological catchment modelling based on half a century"),
    ("song2025cmip6kg", "CMIP6 GCMs Projected Future Koppen-Geiger Climate Zones on a Global Scale"),
    ("bayar2023climatezoneacceleration", "CMIP6 Earth System Models Project Greater Acceleration of Climate Zone Change"),
    ("vasquez2025chilekg", "Robust spatial changes in climate classes: insights from bias-corrected CMIP6"),
    ("teixeira2026portugalkg", "Climate Classification Shifts for Future Climate Change in Portugal"),
    ("pimentel2023pet", "Which Potential Evapotranspiration Formula to Use in Hydrological Modeling World-Wide"),
    ("almorox2015pet", "Global performance ranking of temperature-based approaches for evapotranspiration"),
    ("fitriana2026lowflowcopula", "Non-stationary low-flow frequency analysis with mixed Weibull"),
    ("duethmann2020conceptualfail", "Why does a conceptual hydrological model fail to correctly predict discharge changes"),
    ("dakhlaoui2019bootstrap", "A bootstrap-based differential split-sample test"),
    ("zeng2019gr4jtransfer", "Improving Parameter Transferability of GR4J Model under Changing Environments"),
    ("bohl2026hybridgeneralize", "Hybrid models generalize better to warmer climate conditions"),
    ("jahanshahi2026multicatchment", "A multi-catchment evaluation of hydrological model transferability and ensemble averaging"),
    ("malamos2025etkg", "Global reference evapotranspiration clustering and its relation"),
    ("lian2024tvpdifferentiable", "Identification of Time-Varying Conceptual Hydrological Model Parameters"),
    ("anderson2025stationaritybias", "Stationarity Assumptions in Streamflow Sensitivity to Precipitation"),
    ("vormoor2018crashtest", "Hydrological model parameter (in)stability"),
    ("meng2016tvpdataassim", "Tracing Temporal Changes of Model Parameters in Rainfall-Runoff Modeling"),
    ("wallner2015somb", "Non-stationary hydrological model parameters: a framework based on SOM-B"),
    ("johnston2022novascotia", "Identifying Hydrologic Regimes and Drivers in Nova Scotia"),
    ("jahanshahi2022similarity", "Identifying most relevant controls on catchment hydrological similarity"),
    ("wang2024chinakg", "The impacts of global warming on climate zones over China"),
    ("saidi2019quantifying", "Quantifying impacts of climate variability and human activities"),
    ("wang2026dlregionalization", "Advancing Deep Learning for Regionalized Streamflow Modeling"),
    ("schlef2021floodprojection", "Comparing Flood Projection Approaches Across Hydro-Climatologically Diverse"),
    ("dajuma2023africakg", "Projected expansion of hottest climate zones over Africa"),
    ("wu2026chinakg", "Changes of K"),
    ("yessimkhanova2026kazakhstan", "Spatial and Temporal Analysis of Climatic Zones in Kazakhstan"),
]

entries = re.split(r"(?m)^(?=@article\{)", CORPUS)[1:]
found = {}
for e in entries:
    title = field(e, "Title")
    nt = norm(title)
    for key, frag in TARGETS:
        if norm(frag)[:40] in nt:
            y = int(field(e, "Year") or 0)
            if key not in found or y > int(field(found[key][1], "Year") or 0):
                found[key] = (title, e)

out, used = [], set()
for key, frag in TARGETS:
    if key not in found:
        print("MISSING:", key)
        continue
    title, e = found[key]
    nt = norm(title)[:70]
    if nt in kg_titles or (nt + "|" + field(e, "Year")) in kg_titles:
        print("skip (already in KG bib):", key)
        continue
    if key in used:
        key += "b"
    used.add(key)
    year = field(e, "Year")
    author = field(e, "Author")
    journal = field(e, "Journal")
    vol, num, pages, doi, art = (field(e, x) for x in ("Volume", "Number", "Pages", "DOI", "Article-Number"))
    lines = ["@article{%s," % key, "  title = {%s}," % title, "  author = {%s}," % author, "  journal = {%s}," % journal.title()]
    if vol:
        lines.append("  volume = {%s}," % vol)
    if num:
        lines.append("  number = {%s}," % num)
    if pages:
        lines.append("  pages = {%s}," % pages)
    elif art:
        lines.append("  pages = {%s}," % art)
    lines.append("  year = {%s}," % year)
    if doi:
        lines.append("  doi = {%s}," % doi)
    lines.append("}")
    out.append("\n".join(lines))

dest = ROOT / "prior-art" / "WOS_key_picks.bib"
dest.write_text("% WOS prior-art picks (2026-11-24) - readable keys; full metadata from WOS BibTeX export\n\n" + "\n\n".join(out) + "\n", encoding="utf-8")
print(f"{len(out)} entries -> {dest}")
