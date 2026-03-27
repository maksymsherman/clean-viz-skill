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
  <img alt="Claude Code skill" src="https://img.shields.io/badge/Claude%20Code-skill-111111">
  <img alt="Codex compatible" src="https://img.shields.io/badge/Codex-compatible-0A7EA4">
</p>

<p align="center"><strong>Make chart requests come back with range frames, direct labels, honest audit summaries, and no chartjunk.</strong></p>

For Claude Code:

```bash
/plugin marketplace add maksymsherman/clean-viz-skill
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

For Codex:

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --url https://github.com/maksymsherman/clean-viz-skill/tree/main/skills/clean-viz
```

> Note: This project is not affiliated with Edward Tufte. It applies visualization principles described in his published works.

## TL;DR

### The Problem

Default chart generation tends to produce the same problems over and over:

- legends when direct labels would be clearer
- heavy gridlines and extra spines
- decorative color instead of readable structure
- pie charts, 3D charts, and dual-axis charts that distort the data
- vague claims that a chart was "checked" without any real visual verification

### The Solution

`clean-viz` is a reusable skill for Claude Code and Codex that activates on real visualization requests. It applies a strict house style, loads library-specific reference patterns on demand, substitutes banned chart types with better forms, and requires an explicit audit summary before the agent finishes.

### Why Use clean-viz?

| Need | What clean-viz does | Where it lives |
|---|---|---|
| Cleaner defaults | Removes chartjunk, uses serif typography, trims axes to the data range | [`skills/clean-viz/SKILL.md`](skills/clean-viz/SKILL.md) |
| Honest verification | Separates code checks from rendered checks so the agent does not fake visual QA | [`skills/clean-viz/references/checklist.md`](skills/clean-viz/references/checklist.md) |
| Better library output | Ships concrete patterns for matplotlib, seaborn, Plotly, Altair, D3.js, ggplot2, and Observable Plot | [`skills/clean-viz/references/`](skills/clean-viz/references/) |
| Safer chart choices | Refuses pie, donut, radar, 3D, and dual-axis charts and proposes substitutes | [`skills/clean-viz/SKILL.md`](skills/clean-viz/SKILL.md) |
| Regression checking | Includes a tracked smoke-test harness for saved model responses | [`eval/`](eval/) |
| Reference rendering | Verifies the runnable chart examples in the markdown docs | [`eval/verify_reference_examples.py`](eval/verify_reference_examples.py) |

## Quick Example

1. Install the skill in Claude Code:

```bash
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

2. Ask for a chart:

```text
Create a matplotlib line chart showing monthly revenue in USD.
Use direct labels, range frames, inward ticks, and include an audit summary.
```

3. Ask for a critique or restyle pass:

```text
Critique this Plotly chart and restyle it to match the clean-viz rules.
Call out anything you could not visually verify.
```

4. Ask for a banned chart type and watch the substitution behavior:

```text
Make this market-share view as a pie chart.
```

5. Render the repository's sample charts locally:

```bash
uv run --with matplotlib --with numpy --with pandas python examples/mpg_five_charts.py
```

That script writes five example PNGs into [`examples/output/`](examples/output/), including a grouped scatter, a direct-labeled multi-line chart, a strip plot, a horizontal bar chart, and a small-multiples view.

## Design Philosophy

### 1. Lead with the data, not the furniture

The skill removes non-data ink first: extra spines, decorative fills, heavy gridlines, border-heavy legends, and default styling noise.

### 2. Label the marks directly

Legends force eye travel. The skill prefers direct labels, end-of-line annotations, and data-space callouts whenever that is readable.

### 3. Refuse misleading chart forms

Pie charts, radar charts, 3D charts, and dual-axis composites are banned because they routinely lower graphical integrity. The skill explains why and offers a substitute instead of silently complying.

### 4. Be explicit about what was actually checked

The audit model distinguishes between code checks, rendered checks, and session-consistency checks. If the chart was not rendered, the skill must say so.

### 5. Go deep where it matters

Primary support is strongest for matplotlib, seaborn, and Plotly. Other libraries get practical patterns, but the deepest coverage is concentrated where most generated code lands.

## Comparison

| Approach | What you get | Tradeoff |
|---|---|---|
| Default chart prompting | Fast, but usually generic styling and inconsistent chart judgment | You repeat the same cleanup instructions every time |
| A one-off prompt snippet in your notes | Better than defaults and easy to paste | No shared reference patterns, no tracked eval harness, easy to drift |
| `clean-viz-skill` | Triggered skill, chart-type substitution rules, library references, audit gate, and regression checks | Intentionally opinionated and not meant for every visual style |

## Installation

### 1. Claude Code marketplace

Recommended if you want the skill managed like a normal plugin:

```bash
/plugin marketplace add maksymsherman/clean-viz-skill
/plugin install clean-viz@maksymsherman-clean-viz-skill
```

You can scope the install:

```bash
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope user
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope project
/plugin install clean-viz@maksymsherman-clean-viz-skill --scope local
```

### 2. Codex skill installer from GitHub

Recommended if you use Codex and want the shared skill directory installed directly:

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --url https://github.com/maksymsherman/clean-viz-skill/tree/main/skills/clean-viz
```

If your system exposes `python` instead of `python3`, use that. Restart Codex after installation so it reloads the skill catalog.

### 3. Local clone for development

Useful when you want to edit the skill itself:

```bash
git clone https://github.com/maksymsherman/clean-viz-skill.git
claude --plugin-dir /path/to/clean-viz-skill
```

## Quick Start

1. Install the skill using one of the methods above.
2. Restart Claude Code or Codex if the new skill does not appear immediately.
3. Ask for a real visualization request, not a generic use of the word "plot" or "graph".
4. Name the target library when you care about the output surface, for example matplotlib or Plotly.
5. Ask for critique, restyling, or generation. The skill covers all three.
6. Review the audit summary at the end of the answer.
7. If you want to customize behavior, edit the markdown files in [`skills/clean-viz/`](skills/clean-viz/).

Prompt patterns that trigger the skill well:

```text
Create a seaborn scatter plot of horsepower vs mpg and label the outliers.
Restyle this matplotlib chart to follow the clean-viz rules.
Critique this dashboard figure and explain what violates graphical integrity.
```

## Command Reference

| Command | Purpose |
|---|---|
| `/plugin marketplace add maksymsherman/clean-viz-skill` | Adds the repository to Claude Code's plugin marketplace list |
| `/plugin install clean-viz@maksymsherman-clean-viz-skill` | Installs the skill in Claude Code |
| `python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py --url https://github.com/maksymsherman/clean-viz-skill/tree/main/skills/clean-viz` | Installs the shared skill into Codex |
| `uv run --with matplotlib --with numpy --with pandas python examples/mpg_five_charts.py` | Renders the sample charts in [`examples/`](examples/) |
| `python3 eval/check_response.py --case matplotlib-line /path/to/response.md` | Checks one saved response against a canonical case |
| `python3 eval/check_response.py --responses-dir /path/to/responses` | Checks a directory of saved responses in batch mode |
| `uv run --with matplotlib --with numpy --with seaborn --with plotly --with kaleido --with pandas --with altair --with vl-convert-python python eval/verify_reference_examples.py` | Renders and verifies the runnable reference examples |

## Configuration and Customization

There is no standalone config file. The configuration surface is the skill itself.

```text
skills/clean-viz/
  SKILL.md                        # trigger words, hard rules, banned chart types
  agents/openai.yaml              # Codex display metadata
  references/checklist.md         # audit gate used before final answers
  references/matplotlib-patterns.md
  references/plotly-patterns.md
  references/general-patterns.md
```

What to edit:

- Change triggers, chart bans, or audit wording in [`skills/clean-viz/SKILL.md`](skills/clean-viz/SKILL.md)
- Change reusable code patterns in [`skills/clean-viz/references/matplotlib-patterns.md`](skills/clean-viz/references/matplotlib-patterns.md), [`skills/clean-viz/references/plotly-patterns.md`](skills/clean-viz/references/plotly-patterns.md), or [`skills/clean-viz/references/general-patterns.md`](skills/clean-viz/references/general-patterns.md)
- Change the final verification gate in [`skills/clean-viz/references/checklist.md`](skills/clean-viz/references/checklist.md)

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

Repo-side verification:
saved responses ----------> eval/check_response.py
reference markdown -------> eval/verify_reference_examples.py
```

## Troubleshooting

### The skill does not trigger

Use an actual visualization request such as "create a line chart" or "critique this scatter plot." The activation guard deliberately ignores generic references to "plot," "graph," or "dashboard" when they are not clearly about chart generation or review.

### Claude Code or Codex does not see the new install

Restart the tool after installation. Both environments cache available skills and plugins during startup.

### `python3` is not available

Use `python` instead for the installer or eval scripts if that is how your system exposes Python.

### Plotly static export fails during reference verification

`kaleido` may still need browser runtime libraries. The Ubuntu package set documented in [`eval/README.md`](eval/README.md) is the expected fix on slim Linux environments.

### Batch response checking fails because files are "missing"

Batch mode expects filenames that match the case names in [`eval/cases/`](eval/cases/), for example `matplotlib-line.md`, `pie-substitution.md`, and `plotly-multi-line.md`.

## Limitations

- Primary support is deepest for matplotlib, seaborn, and Plotly. Altair, D3.js, ggplot2, and Observable Plot are useful secondary references, not equally deep implementations.
- The skill can enforce honest reporting about rendered checks, but it cannot visually verify a chart that was never rendered.
- The tracked eval harness is regex-based policy smoke testing, not semantic analysis and not a replacement for visual review.
- The visual style is intentionally opinionated. If you need a brand-heavy marketing aesthetic, you will probably want to override parts of the house style.
- This repository is a chart-generation skill, not a general dashboard framework or plotting library.

## FAQ

### Does it always refuse pie charts?

Yes, by default. The skill explains why pie and donut charts are misleading in this style system and substitutes a horizontal bar chart or dot plot instead.

### Can I override the rules?

Yes. The skill allows explicit user overrides, but the default posture is to keep the stricter clean-viz behavior unless there is a strong reason to bend it.

### Which libraries are best supported?

Matplotlib, seaborn, and Plotly are the strongest paths. Altair, D3.js, ggplot2, and Observable Plot have secondary pattern references.

### Does the repo include anything beyond the skill markdown?

Yes. It also ships a tracked response-check harness in [`eval/`](eval/) and a runnable sample chart script in [`examples/mpg_five_charts.py`](examples/mpg_five_charts.py).

### What does the audit summary mean?

It is the final quality gate. Code checks are always required, rendered checks can only be marked as passed if the chart was actually viewed, and session-consistency checks apply when multiple related charts are involved.

### Is there a bigger benchmark than the tracked smoke tests?

Yes, but it is local-only. The heavier ChartBench workflow is documented in [`CLAUDE.md`](CLAUDE.md) and is not part of the published plugin payload.

## About Contributions

> *About Contributions:* Please don't take this the wrong way, but I do not accept outside contributions for any of my projects. I simply don't have the mental bandwidth to review anything, and it's my name on the thing, so I'm responsible for any problems it causes; thus, the risk-reward is highly asymmetric from my perspective. I'd also have to worry about other "stakeholders," which seems unwise for tools I mostly make for myself for free. Feel free to submit issues, and even PRs if you want to illustrate a proposed fix, but know I won't merge them directly. Instead, I'll have Claude or Codex review submissions via `gh` and independently decide whether and how to address them. Bug reports in particular are welcome. Sorry if this offends, but I want to avoid wasted time and hurt feelings. I understand this isn't in sync with the prevailing open-source ethos that seeks community contributions, but it's the only way I can move at this velocity and keep my sanity.

## License

MIT. See [`LICENSE`](LICENSE).
