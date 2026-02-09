# clean-viz-skill

A Claude Code plugin that applies data visualization best practices inspired by Edward Tufte's principles. When activated, Claude automatically produces publication-quality, chartjunk-free graphics across any charting library.

> **Note**: This project is not affiliated with Edward Tufte. It applies visualization principles described in his published works.

## What it does

This skill auto-triggers whenever you ask Claude to create charts, plots, or visualizations. It applies these principles:

- **Maximizes data-ink ratio** — removes non-data elements (extra spines, heavy gridlines, decorative fills)
- **Uses range frames** — axis lines span only the data range
- **Direct labeling** — annotations replace legend boxes
- **Serif typography** — clean, readable text
- **Grayscale default** — with a single accent color for emphasis
- **Bans chartjunk** — no pie charts, 3D effects, dual axes, gradient fills, or rainbow colormaps
- **Offers substitutes** — when a banned chart type is requested, suggests a clean alternative

## Supported libraries

| Library | Support |
|---|---|
| matplotlib | Full patterns — range frames, dot emphasis, white gridlines, slope charts, sparklines, small multiples |
| seaborn | Override patterns on top of matplotlib |
| Plotly | Full patterns — layout template, annotations, small multiples, sparklines |
| Altair | Theme configuration, faceting, direct labels |
| D3.js | Axis styling, spine removal, dot emphasis |
| ggplot2 | `theme_tufte()`, `geom_rangeframe()`, `ggrepel` labels |
| Observable Plot | Styling config, bar charts, faceting |

## Installation

### From the plugin marketplace (recommended)

Inside Claude Code, run:

```
/plugin marketplace add maksymsherman/clean-viz-skill
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

You can scope the installation:

```
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope user      # all your projects (default)
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope project   # shared with collaborators
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope local     # this repo only
```

### From a local clone

```bash
git clone https://github.com/maksymsherman/clean-viz-skill.git
claude --plugin-dir /path/to/clean-viz-skill
```

## How it works

The plugin has two layers:

1. **SKILL.md** — Core principles, mandatory rules, banned chart types with substitutes, and a response protocol. This loads whenever a visualization request is detected.

2. **references/** — Library-specific code patterns loaded on demand:
   - `matplotlib-patterns.md` — matplotlib and seaborn
   - `plotly-patterns.md` — Plotly
   - `general-patterns.md` — Altair, D3.js, ggplot2, Observable Plot
   - `checklist.md` — Post-generation verification checklist

## Examples

**Request:** "Create a line chart showing monthly revenue"

**Result:** Serif font, range frames, inward ticks, direct labels, no legend box, grayscale palette.

**Request:** "Make a pie chart of market share"

**Result:** Claude explains why pie charts violate data-ink principles, then generates a horizontal bar chart instead.

**Request:** "Create a 3D bar chart"

**Result:** Claude explains occlusion/perspective problems, generates a clean 2D bar chart.

## Visualization principles

Based on Edward Tufte's *The Visual Display of Quantitative Information*:

- **Data-ink ratio**: Maximize the proportion of ink used to present data
- **Graphical integrity**: Visual representation proportional to numerical values (Lie Factor 0.95-1.05)
- **Chartjunk elimination**: Remove all non-data visual elements
- **Small multiples**: Repeated small charts for comparison instead of complex overlaid graphics
- **Sparklines**: Word-sized graphics for inline data display

## License

MIT
