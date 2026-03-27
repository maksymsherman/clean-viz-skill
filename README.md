# clean-viz-skill

<div align="center">
<pre>
mpg
45 |                            Japan
35 |                   Europe
25 |          USA
15 +------------------------------- year
     '70       '75       '80   '82
</pre>
</div>

<p align="center">
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-2ea44f"></a>
  <img alt="Claude Code plugin" src="https://img.shields.io/badge/Claude%20Code-plugin-111111">
  <img alt="Codex skill" src="https://img.shields.io/badge/Codex-skill-0A7EA4">
</p>

<p align="center"><strong>An installable chart-quality skill for Claude Code and Codex that strips chartjunk, refuses misleading chart types, and requires an honest audit summary before the agent finishes.</strong></p>

For Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash
```

For Claude Code:

```bash
/plugin marketplace add maksymsherman/clean-viz-skill
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

> Note: This project is not affiliated with Edward Tufte. It applies visualization principles described in his published works.

---

## TL;DR

**The Problem:** most AI-generated charts default to heavy gridlines, generic legends, decorative color, and misleading chart forms such as pie charts, 3D charts, or dual-axis composites.

**The Solution:** `clean-viz` is a reusable skill that activates on chart-generation, critique, and restyling requests; enforces a strict house style; substitutes banned chart types with more honest alternatives; and requires a compact audit summary covering code checks, rendered checks, and session consistency.

### Why use clean-viz?

| Need | What clean-viz does | Where it lives |
|---|---|---|
| **Cleaner defaults** | Removes chartjunk, uses serif typography, applies range frames, and favors direct labels | [`skills/clean-viz/SKILL.md`](skills/clean-viz/SKILL.md) |
| **Honest verification** | Forces the agent to distinguish code review from actual visual verification | [`checklist.md`](skills/clean-viz/references/checklist.md) |
| **Library-specific patterns** | Ships concrete patterns for matplotlib, seaborn, Plotly, Altair, D3.js, ggplot2, and Observable Plot | [`references/`](skills/clean-viz/references/) |
| **Safer chart choices** | Refuses pie, donut, radar, 3D, and dual-axis requests unless the user explicitly insists | [`skills/clean-viz/SKILL.md`](skills/clean-viz/SKILL.md) |
| **Regression checking** | Includes a lightweight response checker and reference-example renderer for repo-side verification | [`eval/`](eval/) |

---

## Quick Example

1. Install the skill into Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash
```

2. Restart Codex if it was already running.

3. Ask for a chart:

```text
Create a matplotlib line chart showing monthly revenue in USD.
Use direct labels, range frames, inward ticks, and include an audit summary.
```

4. Ask for a critique or restyle pass:

```text
Critique this Plotly chart and restyle it to match the clean-viz rules.
Call out anything you could not visually verify.
```

5. Ask for a banned chart type:

```text
Make this market-share view as a pie chart.
```

The skill explains why pie charts are banned, offers a horizontal bar chart or dot plot instead, and only complies if the user explicitly insists after seeing the substitute.

---

## What This Repo Ships

This repository now supports the two real install surfaces directly:

| Surface | How it works | User-facing entrypoint |
|---|---|---|
| **Codex** | `install.sh` downloads this repo and copies `skills/clean-viz` into `~/.codex/skills/clean-viz` | [`install.sh`](install.sh) |
| **Claude Code** | Claude reads the plugin metadata in `.claude-plugin/` and installs the skill from `./skills/` | [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) |
| **Development / verification** | Clone the repo to work on examples, evals, and reference patterns | [`examples/`](examples/), [`eval/`](eval/) |

That separation matters:

- The installable skill payload is [`skills/clean-viz/`](skills/clean-viz/).
- The sample charts, eval harness, and repo docs stay in the repo and are not required for the Codex install.
- Codex users no longer need to know or type the nested GitHub path.

---

## Gallery

Five example charts generated from the classic MPG dataset, all following clean-viz rules:

| Chart | What it demonstrates |
|---|---|
| ![Weight vs MPG scatter](examples/output/chart1_weight_vs_mpg.png) | Grouped scatter with restrained color, range frames, and minimal legend usage |
| ![MPG trend by origin](examples/output/chart2_mpg_trend_by_origin.png) | Multi-line chart with line-style variation, direct labels, and collision handling |
| ![MPG by cylinders](examples/output/chart3_mpg_by_cylinders.png) | Raw-data-first categorical view instead of a summary-only bar chart |
| ![Median MPG by origin](examples/output/chart4_median_mpg_by_origin.png) | Horizontal bar chart with direct value labels and a single narrative accent |
| ![Displacement vs MPG faceted](examples/output/chart5_displacement_vs_mpg_faceted.png) | Small multiples with shared axes and restrained annotation |

Render them locally:

```bash
uv run --with matplotlib --with numpy --with pandas python examples/mpg_five_charts.py
```

---

## Design Philosophy

### 1. Lead with the data, not the furniture

Remove non-data ink first: extra spines, decorative fills, heavy gridlines, border-heavy legends, and default styling noise.

### 2. Label the marks directly

Legends force eye travel. Direct labels, end-of-line annotations, and data-space callouts are preferred whenever readable.

### 3. Refuse misleading chart forms

Pie charts, radar charts, 3D charts, and dual-axis composites are banned by default because they routinely lower graphical integrity.

### 4. Be explicit about what was actually checked

The audit model separates code checks from rendered checks so the agent cannot pretend it visually verified a chart it never rendered.

### 5. Prefer practical depth over vague universality

Primary coverage is deepest for matplotlib, seaborn, and Plotly. Other libraries have concrete patterns, but the strongest implementation guidance is concentrated where most generated chart code lands.

---

## Comparison

| Approach | What you get | Tradeoff |
|---|---|---|
| **Default chart prompting** | Fast, but generic styling and inconsistent chart judgment | You repeat the same cleanup instructions every time |
| **A saved prompt snippet** | Better than defaults and easy to paste | No shared references, no eval harness, and it drifts over time |
| **`clean-viz-skill`** | Triggered skill, banned-type substitution, library references, audit gate, and repo-side verification tools | Intentionally opinionated and not meant for every visual style |

**When clean-viz is ideal:**

- Reports, notebooks, and analysis workflows where clarity matters more than decorative branding
- Teams that want a repeatable chart house style without maintaining their own prompt library
- Sessions where you want the agent to explicitly say what it did and did not verify

**When clean-viz is not ideal:**

- Brand-heavy marketing graphics that need custom palettes and decorative treatment
- Editorial or artistic illustrations where visual flair matters more than quantitative clarity

---

## Installation

### 1. Codex one-line install

Recommended for Codex users:

```bash
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash
```

By default the installer copies [`skills/clean-viz/`](skills/clean-viz/) into:

```text
~/.codex/skills/clean-viz
```

Useful options:

```bash
# install somewhere else
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash -s -- --dest /custom/skills

# replace an existing install
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash -s -- --force

# install from a different git ref
curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash -s -- --ref main
```

### 2. Claude Code marketplace install

Recommended for Claude Code users:

```bash
/plugin marketplace add maksymsherman/clean-viz-skill
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

You can scope the install if needed:

```bash
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope user
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope project
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope local
```

### 3. Manual install or development clone

Useful if you want the repo extras as well:

```bash
git clone https://github.com/maksymsherman/clean-viz-skill.git
cp -R clean-viz-skill/skills/clean-viz "${CODEX_HOME:-$HOME/.codex}/skills/clean-viz"
```

If you prefer Codex's built-in GitHub installer, this still works:

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo maksymsherman/clean-viz-skill \
  --path skills/clean-viz
```

Restart Codex or Claude Code after installation so the skill catalog is reloaded.

---

## Quick Start

1. Install `clean-viz` using one of the methods above.
2. Restart the tool if it was already running.
3. Use a real visualization request such as `create a line chart`, `critique this scatter plot`, or `restyle this Plotly figure`.
4. Name the library when you care about the output surface, for example `matplotlib` or `Plotly`.
5. Review the audit summary at the end of the answer.
6. If you want to customize the rules, edit the files under [`skills/clean-viz/`](skills/clean-viz/).

Prompt patterns that trigger the skill well:

```text
Create a seaborn scatter plot of horsepower vs mpg and label the outliers.
Restyle this matplotlib chart to follow the clean-viz rules.
Critique this dashboard figure and explain what violates graphical integrity.
```

---

## Command Reference

| Command | Purpose |
|---|---|
| `curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash` | Install the skill into Codex from this repo |
| `/plugin marketplace add maksymsherman/clean-viz-skill` | Add the repository to Claude Code's plugin marketplace list |
| `/plugin install clean-viz@maksymsherman-clean-viz-skill` | Install the skill in Claude Code |
| `uv run --with matplotlib --with numpy --with pandas python examples/mpg_five_charts.py` | Render the sample charts in [`examples/`](examples/) |
| `python3 eval/check_response.py --case matplotlib-line response.md` | Check one saved response against a canonical case |
| `python3 eval/check_response.py --responses-dir /path/to/responses` | Check a directory of saved responses in batch mode |
| `uv run --with matplotlib --with numpy --with seaborn --with plotly --with kaleido --with pandas --with altair --with vl-convert-python python eval/verify_reference_examples.py` | Render and verify the runnable reference examples |

---

## Configuration and Customization

There is no separate config file. The configuration surface is the skill itself:

```text
skills/clean-viz/
  SKILL.md                        # trigger words, hard rules, banned chart types
  agents/openai.yaml              # Codex display metadata
  references/checklist.md         # mandatory audit gate
  references/matplotlib-patterns.md
  references/plotly-patterns.md
  references/general-patterns.md
```

What to edit:

- **Triggers, chart bans, or audit wording** in [`SKILL.md`](skills/clean-viz/SKILL.md)
- **Reusable code patterns** in [`matplotlib-patterns.md`](skills/clean-viz/references/matplotlib-patterns.md), [`plotly-patterns.md`](skills/clean-viz/references/plotly-patterns.md), or [`general-patterns.md`](skills/clean-viz/references/general-patterns.md)
- **The final verification gate** in [`checklist.md`](skills/clean-viz/references/checklist.md)

---

## Architecture

```text
User asks for a chart / critique / restyle
                |
                v
       Claude Code or Codex
                |
                v
   clean-viz trigger + activation guard
                |
                v
       skills/clean-viz/SKILL.md
                |
        +-------+--------+
        |                |
        v                v
  banned-type        library-specific
  substitution       reference patterns
                         |
                         v
              generated code or chart critique
                         |
                         v
            references/checklist.md audit gate
                         |
       +-----------------+------------------+
       |                 |                  |
       v                 v                  v
   code checks      rendered checks   session consistency
                         |
                         v
              final answer + audit summary

Codex install path:
install.sh ----------> ~/.codex/skills/clean-viz

Claude install path:
.claude-plugin/* ----> /plugin install clean-viz@maksymsherman-clean-viz-skill

Repo-side verification:
saved responses ----------> eval/check_response.py
reference markdown -------> eval/verify_reference_examples.py
```

---

## Troubleshooting

### The skill does not trigger

Use an actual visualization request such as `create a line chart` or `critique this scatter plot`. The activation guard deliberately ignores generic references to `plot`, `graph`, or `dashboard` when they are not clearly about chart generation or review.

### Codex does not see the new install

Restart Codex after running the installer. Codex caches the skill catalog at startup.

### The installer says the destination already exists

Re-run the installer with `--force`, or remove the old directory manually:

```bash
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/clean-viz"
```

### `curl` is not available

Use `wget`, `python3`, or a normal `git clone`. The installer itself already falls back to `wget` or `python3` when available.

### Plotly static export fails during reference verification

`kaleido` may still need browser runtime libraries. The Ubuntu package set documented in [`eval/README.md`](eval/README.md) is the expected fix on slim Linux environments.

### Batch response checking says files are missing

Batch mode expects filenames that match the case names in [`eval/cases/`](eval/cases/), for example `matplotlib-line.md`, `pie-substitution.md`, and `plotly-multi-line.md`.

---

## Limitations

- Primary support is deepest for matplotlib, seaborn, and Plotly. Altair, D3.js, ggplot2, and Observable Plot are useful secondary references, not equally deep implementations.
- The skill can enforce honest reporting about rendered checks, but it cannot visually verify a chart that was never rendered.
- The tracked eval harness is regex-based policy smoke testing, not semantic analysis and not a replacement for visual review.
- The visual style is intentionally opinionated. If you need a brand-heavy marketing aesthetic, you will probably want to override parts of the house style.
- The Codex installer installs only the skill payload. If you want the sample charts or eval harness, clone the repo.

---

## FAQ

### Does it always refuse pie charts?

Yes, by default. The skill explains why pie and donut charts are misleading and substitutes a horizontal bar chart or dot plot instead. If you insist after seeing the substitute, it complies but still applies the rest of the clean-viz rules.

### Does `install.sh` install the examples and eval harness too?

No. It installs only [`skills/clean-viz/`](skills/clean-viz/) into Codex. Clone the repo separately if you want [`examples/`](examples/) and [`eval/`](eval/).

### Can I override the rules?

Yes. The skill allows explicit user overrides, but the default posture is to keep the stricter behavior unless there is a strong reason to bend it.

### Which libraries are best supported?

Matplotlib, seaborn, and Plotly are the strongest paths. Altair, D3.js, ggplot2, and Observable Plot have secondary pattern references.

### What does the audit summary mean?

It is the final quality gate. Code checks are always required, rendered checks can only be marked as passed if the chart was actually viewed, and session-consistency checks apply when multiple related charts are involved.

### Is there a bigger benchmark than the tracked smoke tests?

Yes, but it is local-only. The heavier ChartBench workflow is documented in [`CLAUDE.md`](CLAUDE.md) and is not part of the published install payload.

### Does the skill work with non-Python libraries?

Yes. D3.js, ggplot2, and Observable Plot have reference patterns in [`general-patterns.md`](skills/clean-viz/references/general-patterns.md). The coverage is lighter than for the Python libraries but still provides concrete implementation guidance.

### What happens when I generate multiple charts in one session?

The skill treats them as a unified visual system. It enforces consistent color assignments, typography, axis styling, and figure dimensions across all charts, and includes session-consistency checks in the final audit.

## License

MIT. See [`LICENSE`](LICENSE).
