"""Build latex-v2/manuscript.tex from the pandoc tex:
- convert Zotero author-year text citations to natbib \\citep/\\citet
- correct six mis-mapped references
- insert the 2022-2026 literature blocks and the sharpened gap statement
- replace the plain-text References section with BibTeX
"""
import re
import unicodedata
from pathlib import Path

ROOT = Path(r"D:/Research/Non-Stationarity-KG/03-writeup")
SRC = ROOT / "Revision-1" / "latex" / "manuscript.tex"
DEST = ROOT / "Revision-1" / "latex-v2" / "manuscript.tex"
BIB = ROOT / "Revision-1" / "latex-v2" / "references.bib"

t = SRC.read_text(encoding="utf-8")


def norm(s: str) -> str:
    # unescape LaTeX accents: \"{o} \'e \`a \c{c} \`{\i} ...
    s = re.sub(r"\\['`^~\"=.]\s*\{?\s*\\?([a-zA-Z])", r"\1", s)
    s = re.sub(r"\\['`^~\"=.cbiuHv]\s*([a-zA-Z])", r"\1", s)
    s = re.sub(r"\{([a-zA-Z])\}", r"\1", s)
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.replace("\u0131", "i").replace("\u0130", "I")
    s = s.replace("\\&", "&").replace("\\ and ", " & ")
    s = re.sub(r"\band\b", "&", s)
    s = re.sub(r"\b[A-Z]\.\s*", "", s)  # strip initials like "W. "
    s = s.replace(".", " ").replace("-", " ").replace("'", " ")
    s = re.sub(r"\s+et\s+al\b.*$", " et al", s)
    s = re.sub(r"[^a-z& ]", " ", s.lower())
    s = re.sub(r"\s+", " ", s).strip()
    return s


# ---------------------------------------------------------------- bib map
bib = BIB.read_text(encoding="utf-8")
VARIANTS = {}  # norm(author-variant) -> {year -> key}
for e in re.split(r"(?m)^(?=@)", bib)[1:]:
    m = re.match(r"@(\w+)\{([^,]+),", e)
    if not m:
        continue
    key = m.group(2).strip()

    def fld(name, e=e):
        mm = re.search(rf"(?m)^\s*{name}\s*=\s*\{{", e, re.IGNORECASE)
        if not mm:
            return ""
        i, depth, start = mm.end(), 1, mm.end()
        while i < len(e) and depth:
            if e[i] == "{":
                depth += 1
            elif e[i] == "}":
                depth -= 1
            i += 1
        return re.sub(r"\s+", " ", e[start : i - 1].strip())

    year = fld("year")
    if not year:
        continue
    authors = fld("author")
    fams = [a.split(",")[0].replace("{", "").replace("}", "").strip() for a in authors.split(" and ") if a.strip()]
    fams = [f for f in fams if f]
    if not fams:
        continue
    if len(fams) == 1:
        variants = [fams[0], fams[0] + " et al"]
    elif len(fams) == 2:
        variants = [fams[0] + " & " + fams[1], fams[0] + " et al", fams[1] + " & " + fams[0]]
    else:
        variants = [fams[0] + " et al", fams[0]]
    for v in variants:
        nv = norm(v)
        VARIANTS.setdefault(nv, {}).setdefault(year, key)

# ---------------------------------------------------------------- overrides
OVERRIDE = {
    "khan et al": {"2020": "hui2020bias"},
    "shen et al": {"2022": "coron2012crash,dakhlaoui2019bootstrap"},
    "vormoor et al": {"2021": "vormoor2018hydrological"},
    "calvin et al": {"2023": "calvin2023climate"},
    "melsen & guse": {"2021a": "melsen2021climate", "2021b": "melsen2021climate", "2021": "melsen2021climate"},
    "w zhang et al": {"2024": "zhangAnthropogenicAmplificationPrecipitation2024"},
    "singh et al": {"2014": "singh2015vulnerability"},
    "breiman et al": {"1984": "breiman2017classification"},
    "koppen & geiger": {"1930": "koppen1930handbuch"},
}

fails = []

# ------------------------------------------------- 1. drop References body
ref_re = re.compile(r"\\section\{References\}.*?(?=\\section\{Supplementary figures\})", re.DOTALL)
t, n_ref = ref_re.subn(
    "\\\\section{References}\n\n"
    "\\\\bibliographystyle{apalike}\n"
    "\\\\bibliography{references}\n\n",
    t,
)

# ------------------------------------------------- 2. narrative citations
t = re.sub(r"Beck\s+et\s+al\.\s*\(\s*2023\s*\)", r"\\citet{beck2023high}", t)
t = re.sub(r"Deshmukh\s+\\\&\s+Singh\s*\(\s*2019\s*\)", r"\\citet{deshmukhWhittakerBiomeBasedFramework2019}", t)
t = re.sub(r"Garcia-Aristizabal\s+et\s+al\.\s*\(\s*2015\s*\)", r"\\citet{garciaaristizabal2015analysis}", t)

# ------------------------------------------------- 3. parenthesised groups
GROUP = re.compile(r"\(([^()]*\b(?:19|20)\d{2}[a-z]?\b[^()]*)\)")
ITEM = re.compile(r"^\s*(.*?)\s*,\s*((?:19|20)\d{2}[a-z]?)((?:\s*,\s*(?:19|20)\d{2}[a-z]?)*?)\s*$")
YEARS = re.compile(r"(19|20)\d{2}[a-z]?")


def resolve_group(content: str):
    keys, ok = [], True
    for item in re.split(r";\s*", content):
        item = re.sub(r"\s+", " ", item).strip()
        m = ITEM.match(item)
        if not m:
            ok = False
            fails.append(("noitem", item))
            return None
        authors, year, extra = m.group(1), m.group(2), m.group(3)
        extra_years = re.findall(r"(?:19|20)\d{2}[a-z]?", extra) if extra else []
        years = [year] + extra_years
        na = norm(authors)
        got = []
        for y in years:
            if na in OVERRIDE and y in OVERRIDE[na]:
                got.append(OVERRIDE[na][y])
                continue
            ent = VARIANTS.get(na, {})
            if y in ent:
                got.append(ent[y])
            else:
                ok = False
                fails.append(("nomap", item))
                return None
        keys.extend(got)
    return keys


def repl(m):
    keys = resolve_group(m.group(1))
    if keys is None:
        return m.group(0)
    return "\\citep{" + ",".join(keys) + "}"


t = GROUP.sub(repl, t)

# ------------------------------------------------- 4. literature blocks
B1 = r"""The two halves of this linkage have advanced considerably in the 2022--2026 literature, but largely in isolation. On the parameter side, transferability experiments now demonstrate that the calibration--evaluation climate contrast is a first-order control on performance: model transfer degrades across climate conditions \citep{jahanshahi2022transferability}, the effect persists in multi-catchment and ensemble-averaging settings \citep{jahanshahi2026multicatchment}, and hybrid process--machine-learning structures generalize better to warmer conditions than either purely process-based or purely data-driven models \citep{bohl2026hybridgeneralize}, while crash tests of the HBV model show that parameter stability depends on which flood-generating processes dominate the calibration window \citep{vormoor2018hydrological} and the causes of conceptual-model failure under climate change have been diagnosed directly \citep{duethmann2020conceptualfail}. On the parameter-evolution side, time-varying parameter approaches have matured from self-organizing-map optimization \citep{wallner2015somb} and data assimilation \citep{meng2016tvpdataassim} to split-sample dynamic programming \citep{zhangTimevaryingParameterEstimation2021}, differentiable parameter learning \citep{krapu2022differentiable,lian2024identification,feng2022differentiable}, and diagnostic time-varying frameworks \citep{zhou2022tvpdiagnosis,liu2025budykotvp}, with applications ranging from monthly Budyko functions in US MOPEX catchments \citep{liu2025budykotvp} to forecasting with previously learned time-varying parameters \citep{zhang2024tvpforecasting}. On the climate-classification side, CMIP6-based K\"oppen--Geiger projections now quantify where and how fast zones shift \citep{beck2023high,bayar2023climatezoneacceleration,song2025cmip6kg,vasquez2025chilekg,teixeira2026portugalkg,wang2024chinakg}, and recent analyses warn that retaining stationarity in streamflow sensitivity can bias future projections \citep{anderson2025stationaritybias}. What none of these lines provides is a framework that connects the three: time-varying methods anchor parameter change to time or state rather than to an interpretable external classification, transferability studies diagnose climate-dependent performance loss but do not construct climate-conditioned parameter pools, and the K\"oppen--Geiger mapping literature stops at the climate surface without touching hydrological model structure."""

B2 = r"""Despite this progress, a three-way methodological gap persists. First, transferability and robustness studies establish that parameters calibrated under one climate regime degrade under another \citep{coron2012crash,merz2011time,dakhlaoui2019bootstrap,jahanshahi2022transferability}, but they quantify performance loss without redefining the parameter distributions that a future climate regime would support. Second, time-varying parameter frameworks recover parameter drift from the hydrological record itself, but anchor it to time or internal state \citep{wallner2015somb,zhangTimevaryingParameterEstimation2021,krapu2022differentiable,liu2025budykotvp}, so the evolution is neither interpretable nor transferable to a catchment whose class membership changes rather than whose record extends. Third, the K\"oppen--Geiger change literature projects where zones will shift \citep{beck2023high,bayar2023climatezoneacceleration,song2025cmip6kg} but does not propagate those shifts into hydrological model parameterization or into vulnerability thresholds. Consequently, no comprehensive framework has explicitly established the linkage between parameter non-stationarity and K\"oppen--Geiger climate zone transitions under future climate scenarios, and no study has quantified how much catchment vulnerability estimates change when stationary parameters are replaced by climate-zone-conditioned parameters. This relationship is essential for characterizing the conditions under which model reconfiguration becomes necessary as hydrological basins migrate toward drier or warmer climatic classifications. Therefore, the present investigation addresses this gap by systematically evaluating whether hydrological model parameters require structured adjustment as catchments evolve through K\"oppen--Geiger classification transitions from the historical period to projected climate scenarios."""

B4 = r"""This directionally unstructured outcome is consistent with the newest transferability evidence and extends it from model performance to vulnerability. \citet{jahanshahi2022transferability} and \citet{jahanshahi2026multicatchment} show that rainfall--runoff model transferability depends strongly on climate conditions, with the largest degradations across hydroclimatic contrasts; \citet{duethmann2020conceptualfail} attribute conceptual-model failures under climate change to parameters that cannot absorb regime changes; and \citet{bohl2026hybridgeneralize} find that generalization to warmer climates remains the binding constraint for process-based models. CZIPEF adds a threshold-level consequence to this literature: when the parameter pool is redefined by climate class rather than frozen, the estimated vulnerability threshold moves in 72\% of catchments, in either direction, so a stationary-parameter study risks overstating vulnerability in some catchments and understating it in others. The weak pooled regression (slope 0.31, R$^2$ = 0.14) is therefore not a null result about the method but a statement about its spatial structure: the correction is catchment-specific and climatically patterned, which pooled metrics conceal."""

B5 = r"""Compared with time-varying parameter approaches, the climate-zone conditioning used here is deliberately coarser but interpretable and transferable. Time-varying frameworks recover continuous parameter trajectories from the hydrological record itself \citep{wallner2015somb,zhangTimevaryingParameterEstimation2021,krapu2022differentiable,zhou2022tvpdiagnosis,liu2025budykotvp}, which requires long in-catchment data and provides no rule for a catchment whose class membership changes under a scenario it has never experienced. The variance partitioning in Table 6 quantifies exactly this tension: climate zones carry a substantial but partial share of parameter variation, and physiography explains more for beta, k0, PERC and UZL, so a purely climatic reparameterization would overstate parameter change in physiographically controlled catchments. CZIPEF's parameter pools therefore act as a bounded, class-conditional prior rather than a fitted trajectory, which is also why the sensitivity results (three to six dominant parameters per indicator) are stable across zones."""

B6 = r"""Three operational extensions follow directly from the recent literature. First, because the delta-change experiment perturbs the observed climatology and reclassifies it \citep{beck2023high}, the same mechanism can consume published CMIP6 K\"oppen--Geiger projections \citep{bayar2023climatezoneacceleration,song2025cmip6kg,vasquez2025chilekg,teixeira2026portugalkg} to produce zone-consistent vulnerability updates as the projected zone map advances. Second, the PET formulation itself is a vulnerability control: global comparisons show that the ranking of temperature-based PET methods varies by K\"oppen class \citep{almorox2015pet,pimentel2023pet}, so the CZIPEF-versus-SPF threshold differences reported here should be read jointly with the choice of PET scheme, and a zone-conditional PET benchmark is a natural next step. Third, the non-stationary low-flow literature is converging on the same copula-based machinery used in the resampler \citep{fitriana2026lowflowcopula}, which makes the supplementary low-flow and high-flow indicators, identifiable in 10--26\% of catchments here, a realistic target for hierarchical or regional pooling once longer records or larger samples become available."""


def insert_before(anchor: str, block: str, text: str):
    i = text.find(anchor)
    if i < 0:
        fails.append(("anchor-before", anchor[:60]))
        return text
    return text[:i] + block + "\n\n" + text[i:]


def insert_after(anchor: str, block: str, text: str):
    i = text.find(anchor)
    if i < 0:
        fails.append(("anchor-after", anchor[:60]))
        return text
    return text[: i + len(anchor)] + "\n\n" + block + text[i + len(anchor):]


# B1 before the old gap paragraph; B2 replaces the old gap paragraph
gap_start = t.find("Despite the wide range of research that has independently investigated")
gap_end_marker = "to the projected climate scenarios."
if gap_start >= 0:
    gap_end = t.find(gap_end_marker, gap_start)
    if gap_end >= 0:
        gap_end += len(gap_end_marker)
        t = t[:gap_start] + B1 + "\n\n" + B2 + t[gap_end:]
    else:
        fails.append(("gap-end", "not found"))
else:
    fails.append(("gap-start", "not found"))

t = insert_after("performance and reduces projection uncertainty.", B4, t)
t = insert_after("while allowing the distribution to change with the climate regime\n\\citep{scott2015multivariate,silverman1998density}.", B5, t)
t = insert_after("emphasizing the variety of aspects of robustness \\citep{cutter2012social,fussel2006climate}.", B6, t)

# ------------------------------------------------- 5. preamble
t = t.replace("\\usepackage{xcolor}", "\\usepackage{xcolor}\n\\usepackage[round,authoryear]{natbib}\n\\usepackage[margin=2.5cm]{geometry}", 1)

DEST.write_text(t, encoding="utf-8")
print("wrote", DEST)
print("references section replaced:", n_ref)
if fails:
    print("FAILURES:")
    for f in fails:
        print("  ", f)
else:
    print("no failures")
