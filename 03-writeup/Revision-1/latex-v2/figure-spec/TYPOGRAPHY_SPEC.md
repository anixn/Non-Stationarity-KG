# TYPOGRAPHY_SPEC.md — fonts and spacing for the CZIPEF data figures

Same rules as the CIMP6 India house style
(`D:\Datasets\CIMP6_India\manuscript\figures\TYPOGRAPHY_SPEC.md`), applied to
the data figures of the KG paper (Figs 1, 2, 8–14 + S1–S10). The conceptual
figures (Figs 3–7) are Mermaid/pele exports and are specified in `FIGURES.md`.

## Inputs used for the calculation

| Constraint | Value |
|---|---|
| Font family | **Roboto** (static Regular + Bold; Arial fallback if absent), registered through showtext/sysfonts. Sizes are font-independent. |
| Final output | vector PDF (`cairo_pdf`) with 300-dpi PNG preview |
| Width | 7.2 in (double column); 6.6–7.0 in where two panels share a row |
| Viewing context | **print paper** |
| Minimum rendered text | **10 pt** at final size |
| Tick labels vs axis titles | ticks ≤ 2 pt smaller than titles; axis titles **bold** |

## 1. Recommended `base_size`

**`base_size = 12`** for a `theme_minimal()`/`theme_bw()` derivative, then
**override every element with absolute sizes** (table below) so nothing
depends on ggplot2's multipliers: default multipliers would put `axis.text`
at ≈ 9.6 pt — below the 10 pt floor.

## 2. Element specification

| Element | size_pt | face | margin / angle / other |
|---|---|---|---|
| `plot.title` | 13 | plain | left-aligned (`hjust = 0`), bottom margin 4 pt |
| `plot.subtitle` | 11 | plain | left-aligned, bottom margin 2 pt, grey 25 |
| `axis.title.x` | 12 | **bold** | top margin 4 pt; wrap long labels to ≤ 60 characters |
| `axis.title.y` | 12 | **bold** | right margin 4 pt; wrap to ≤ 40 characters |
| `axis.text.x` | 10.5 | plain | 0° for ≤ 6 short labels; otherwise 30–45° with `hjust = 1` |
| `axis.text.y` | 10.5 | plain | 0°; for ≥ 15 categorical rows keep 10 pt and increase panel height rather than shrink |
| `legend.title` | 11 | plain | bottom legend, horizontal |
| `legend.text` | 10 | plain | key size 10 pt |
| `strip.text` | 10.5 | plain | strip on white, 0.4-pt black rule, no fill |
| `caption` | 10 | plain | left-aligned, grey 35, top margin 3 pt |

## 3. Ticks and frame

| Property | Value |
|---|---|
| `axis.ticks` linewidth | 0.45 pt |
| `axis.ticks.length` | 1.6 mm (4.5 pt) |
| panel border | 0.5 pt black; no top/right-only frames |
| major grid | horizontal only, 0.3 pt, grey 88; no minor grid |

## 4. Per-figure geometry (existing figures, keep on rebuild)

| Figure | width × height (in) | overlap adjustments |
|---|---|---|
| F8b delta-change KG map (12 panels) | 7.2 × 7.0 | class medians printed at 10 pt inside panels; shared legend right, horizontal keys |
| F14 prevalence surface | 6.6 × 5.5 | colourbar title ≤ 40 chars, breaks ≤ 6 |
| F8b / F9 maps (SPF vs CZIPEF) | 7.2 × 6.0 | two rows (frameworks) × 3 indicator columns; facet strip 10.5 pt |
| F8 scatter | 6.6 × 5.2 | 1:1 line labelled at 10 pt; n = annotation top-left |
| F13 parameter CDFs | 7.2 × 7.0 | facet by parameter; class palette fixed: Cfa `#0072B2`, Csb `#E69F00`, Cfb `#009E73`, Dfa/Dfb `#CC79A7`, Dfc `#56B4E9`, Dsc `#D55E00` |
| F10 PRCC/Sobol | 7.2 × 6.2 | PRCC bars sorted; Sobol shares as right-hand panel |

## 5. Pass/fail check

```
Smallest text = 10.0 pt (legend.text, caption)
               10.5 pt (axis.text, strip.text)
Requirement   = 10 pt
=> PASS at final saved size on all data figures.
```

Repeat with ggplot2 defaults (`base_size = 9.5`, no overrides) gives 7.6 pt
— FAIL — which is why every element is set explicitly.
