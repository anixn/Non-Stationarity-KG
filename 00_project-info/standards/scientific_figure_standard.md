# SCIENTIFIC FIGURE AND VISUALIZATION SPECIFICATION

## 1. General Typography and Formatting

- **Font family:** Roboto throughout the entire figure, including titles, axis labels, tick labels, legends, annotations, and panel labels.
- **Base font size:** 10 pt for all figure text.
- **Panel labels:** Use lowercase alphabetical labels in the format **a.)**, **b.)**, **c.)**, etc.
  - Position consistently at the upper-left corner of each panel.
  - Use bold Roboto, 10 pt.
  - Ensure labels do not overlap plotted data.
- **Axis titles:** Roboto, 10 pt, regular or medium weight.
- **Tick labels:** Roboto, 10 pt.
- **Legend text:** Roboto, 10 pt.
- **Annotations:** Roboto, 10 pt, with smaller text permitted only when essential and legibility is maintained.
- Avoid unnecessary bold formatting, oversized headings, decorative typography, and excessive text.
- Use standard date format
- my default page is a4.

## 2. Publication-Quality Figure Design

- Use a clean, minimal, professional scientific visualization style.
- Prefer white backgrounds with no unnecessary decorative elements.
- Use consistent typography, margins, spacing, line widths, and visual hierarchy across all figures in the manuscript.
- Avoid unnecessary borders, shadows, gradients, 3D effects, and ornamental elements.
- Use subtle panel separators only when scientifically or visually necessary.
- Maintain balanced whitespace and avoid overcrowding.
- Ensure all graphical elements remain legible at the intended publication size.

## 3. Colour Palette and Accessibility

- Use scientifically appropriate, perceptually uniform colour palettes.
- Prefer colourblind-friendly palettes such as:
  - Viridis
  - Cividis
  - Plasma
  - ColorBrewer palettes
  - Tol palettes for categorical data.
- Avoid rainbow and jet colour maps.
- Use sequential palettes for continuous variables, diverging palettes for positive/negative anomalies, and qualitative palettes for categorical variables.
- Maintain sufficient contrast between plotted elements and backgrounds.
- Do not rely exclusively on colour to distinguish categories. Use line types, shapes, or patterns where appropriate.
- Maintain consistent variable-to-colour mapping across related figures.

## 4. Axes, Lines, and Graphical Elements

- Use clear axis titles with appropriate units.
- Include units in parentheses, e.g., Precipitation (mm), Temperature (°C), and SPEI (dimensionless).
- Use appropriate decimal precision and avoid unnecessary tick marks.
- Keep axis limits scientifically justified and consistent across comparable panels.
- Use readable tick intervals and avoid excessive gridlines.
- Prefer subtle major gridlines and remove unnecessary minor gridlines.
- Use consistent line widths:
  - Primary data: 0.8–1.2 pt.
  - Reference lines: 0.5–0.8 pt.
  - Confidence intervals: clearly distinguishable without overpowering the main data.
- Avoid truncated axes that could misrepresent the magnitude of differences.
- Use logarithmic scales only when scientifically justified and explicitly indicated.

## 5. Multi-Panel Figure Organization

- Arrange panels logically to communicate the scientific narrative.
- Use lowercase alphabetical labels: a.), b.), c.), d.), etc.
- Maintain consistent panel dimensions, alignment, and spacing.
- Use shared axes where appropriate to facilitate comparisons.
- Avoid repeating axis labels and legends when a common legend or shared axis is sufficient.
- Ensure each panel remains independently interpretable.
- Keep panel labels consistently positioned and separated from plotted content.
- Use consistent spatial extent, projection, and scale for comparable maps.

## 6. Maps and Geospatial Visualizations

For hydrological, climatic, and remote-sensing maps:

- Use an appropriate projected coordinate reference system.
- Select projections that minimize distortion for the study region.
- Include a scale bar and north arrow when they improve geographic interpretation.
- Include administrative boundaries, catchment boundaries, rivers, and other reference features only when relevant.
- Use consistent spatial extents and map scales across comparable panels.
- Use scientifically appropriate colour ramps for continuous raster data.
- Ensure legends clearly communicate units, classification intervals, and missing values.
- Distinguish NoData areas from valid low-value observations.
- Avoid excessive basemap details and unnecessary geographic annotations.
- Include coordinate labels only when they improve spatial interpretation.
- Ensure map insets and locator maps are appropriately sized and positioned.

## 7. Statistical and Model-Performance Figures

For statistical analysis, hydrological modelling, and machine learning:

- Clearly distinguish observed, simulated, predicted, and reference values.
- Include confidence intervals, uncertainty bands, or prediction intervals wherever scientifically appropriate.
- Use reference lines such as 1:1 lines, zero lines, and threshold lines when relevant.
- Clearly label statistical metrics, including NSE, KGE, RMSE, MAE, R², and correlation coefficients.
- Avoid displaying excessive performance metrics in a single panel.
- Distinguish training, validation, and independent testing results.
- Use consistent visual encodings for different models and scenarios.
- Avoid visual representations that exaggerate small performance differences.
- Clearly communicate uncertainty and sample sizes where relevant.

## 8. Figure Dimensions and Export Settings

- Design figures at their intended final publication dimensions rather than relying on later resizing.
- Use the target journal's column-width and page-width specifications whenever available.
- As a general starting point:
  - Single-column figure: approximately 85–90 mm.
  - Double-column figure: approximately 175–180 mm.
- Maintain aspect ratios appropriate to the scientific content.
- Export raster images at a minimum of 300 DPI.
- Prefer 600 DPI for line-art-heavy raster figures when required.
- Prefer vector formats for plots and diagrams wherever possible.

**Preferred export formats:**

- PDF: vector-based publication output.
- SVG: editable vector graphics.
- TIFF: high-resolution raster output.
- PNG: previews and web display.

Do not use JPEG for scientific plots containing fine lines, text, or sharp boundaries unless specifically required by the publisher.

## 9. Reproducibility and Technical Quality Control

- Generate figures directly from reproducible scripts.
- Avoid manual modifications to exported figures that cannot be reproduced.
- Keep plotting parameters centralized in reusable functions or configuration files.
- Maintain consistent colour palettes, font settings, dimensions, and theme definitions across the project.
- Use relative file paths rather than machine-specific absolute paths.
- Include meaningful filenames, such as:
  - fig_01_study_area.pdf
  - fig_02_methodology.pdf
  - fig_03_spatial_distribution.pdf
  - fig_04_model_performance.pdf
- Verify that fonts are embedded or properly preserved in exported vector files.
- Check for clipping, overlapping labels, missing legends, and incorrect symbols.
- Render and inspect the exported figure at its actual publication dimensions before finalizing.

## 10. R Programming Standards

For R-based visualization:

- Prefer ggplot2 for statistical and scientific plots.
- Use sf, terra, and tmap or ggplot2 for geospatial visualization as appropriate.
- Use patchwork or cowplot for multi-panel composition.
- Use showtext or an equivalent reliable font-management approach to render Roboto.
- Use ggsave() with explicitly specified dimensions, units, and DPI.
- Centralize common formatting in a reusable publication theme function, such as theme_publication().
- Ensure that the chosen export device supports the intended vector or raster output.

For Python-based visualization, apply equivalent formatting standards using Matplotlib, GeoPandas, Cartopy, and other suitable scientific libraries.

## 11. Final Publication Checklist

Before delivering any figure, verify:

- [ ] Roboto font is consistently applied.
- [ ] All standard figure text is 10 pt.
- [ ] Panel labels follow a.), b.), c.) formatting.
- [ ] Colour palettes are scientifically appropriate and accessible.
- [ ] Axis labels include appropriate units.
- [ ] Legends are clear, concise, and correctly positioned.
- [ ] No text or graphical elements are clipped.
- [ ] Multi-panel layouts are aligned consistently.
- [ ] Maps use appropriate projections and spatial references.
- [ ] Uncertainty is represented where scientifically relevant.
- [ ] Figure dimensions match the intended publication format.
- [ ] Vector or high-resolution raster files are exported correctly.
- [ ] Final output has been inspected at actual publication size.

## 12. Priority Rule

Scientific accuracy and interpretability must always take priority over visual aesthetics.

Do not modify data, statistical relationships, axis scales, spatial boundaries, classifications, or uncertainty representations merely to improve visual appearance.

The objective is to produce publication-ready scientific figures that are accurate, reproducible, visually consistent, accessible, and suitable for peer-reviewed journals in hydrology, water resources, remote sensing, climate science, and environmental modelling.
