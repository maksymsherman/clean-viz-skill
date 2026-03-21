"""Five clean visualizations of the Auto MPG dataset.

Charts:
  1. Scatter — weight vs mpg (all origins, legend by marker shape)
  2. Multi-line — median mpg by model year, per origin
  3. Strip plot — mpg distribution by cylinder count
  4. Horizontal bar — median mpg by origin
  5. Small multiples — displacement vs mpg faceted by origin
"""

import pathlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
import pandas as pd

# ── Data ────────────────────────────────────────────────────────────────
DATA_PATH = pathlib.Path(__file__).parent / "data" / "mpg.csv"
df = pd.read_csv(DATA_PATH)
df = df.dropna(subset=["horsepower"])  # a few missing hp values

# ── Clean-viz constants ─────────────────────────────────────────────────
CLEAN_BLACK = "#333333"
CLEAN_DARK_GRAY = "#555555"
CLEAN_MEDIUM_GRAY = "#888888"
CLEAN_LIGHT_GRAY = "#cccccc"
CLEAN_FAINT_GRAY = "#eeeeee"
CLEAN_REF_GRAY = "#d0d0d0"
CLEAN_ACCENT = "#c0392b"

CLEAN_FONT_SIZE = 11
CLEAN_TITLE_SIZE = 13
CLEAN_LABEL_SIZE = 10
CLEAN_SMALL_SIZE = 9

CLEAN_LINE_STYLES = ["solid", "dashed", (0, (4, 2, 1, 2)), "dotted"]

CLEAN_COLORS = [
    "#332288",  # indigo
    "#CC6677",  # rose
    "#117733",  # green
    "#882255",  # wine
    "#44AA99",  # teal
    "#AA4499",  # purple
    "#88CCEE",  # cyan
    "#999933",  # olive
]
CLEAN_LINE_COLORS = CLEAN_COLORS[:6]

FIGSIZE = (8, 5)

plt.rcParams.update(
    {
        "font.family": "serif",
        "font.size": CLEAN_FONT_SIZE,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.titlesize": CLEAN_TITLE_SIZE,
        "axes.titleweight": "normal",
        "axes.labelsize": CLEAN_FONT_SIZE,
        "xtick.direction": "in",
        "ytick.direction": "in",
        "xtick.major.size": 4,
        "ytick.major.size": 4,
        "xtick.minor.size": 0,
        "ytick.minor.size": 0,
        "axes.grid": False,
        "grid.alpha": 0,
        "legend.frameon": False,
        "figure.facecolor": "white",
        "axes.facecolor": "white",
        "savefig.facecolor": "white",
        "savefig.dpi": 150,
        "figure.dpi": 100,
    }
)

ORIGIN_ORDER = ["usa", "europe", "japan"]
ORIGIN_LABELS = {"usa": "USA", "europe": "Europe", "japan": "Japan"}
ORIGIN_COLORS = {
    "usa": CLEAN_LIGHT_GRAY,
    "europe": CLEAN_DARK_GRAY,
    "japan": CLEAN_ACCENT,
}
ORIGIN_MARKERS = {"usa": "o", "europe": "s", "japan": "D"}


# ── Helpers ─────────────────────────────────────────────────────────────
def apply_range_frame(ax, x, y, pad_fraction=0.05):
    """Bind spine extents to the data range."""
    x_min, x_max = min(x), max(x)
    y_min, y_max = min(y), max(y)
    x_pad = (x_max - x_min) * pad_fraction or 1
    y_pad = (y_max - y_min) * pad_fraction or 1

    ax.spines["bottom"].set_bounds(x_min, x_max)
    ax.spines["left"].set_bounds(y_min, y_max)

    ax.set_xlim(x_min - x_pad, x_max + x_pad)
    ax.set_ylim(y_min - y_pad, y_max + y_pad)
    ax.xaxis.set_major_locator(ticker.MaxNLocator(nbins=5))
    ax.yaxis.set_major_locator(ticker.MaxNLocator(nbins=5))

    ax.figure.canvas.draw()
    ax.set_xticks([t for t in ax.get_xticks() if x_min <= t <= x_max])
    ax.set_yticks([t for t in ax.get_yticks() if y_min <= t <= y_max])


def pad_axis_for_labels(ax, x_data, y_data, pad_fraction=0.12):
    """Extend xlim for label room while keeping range-frame ticks."""
    x_min, x_max = min(x_data), max(x_data)
    x_range = x_max - x_min
    ax.set_xlim(x_min - x_range * 0.02, x_max + x_range * pad_fraction)
    existing_ticks = [t for t in ax.get_xticks() if x_min <= t <= x_max]
    ax.set_xticks(existing_ticks)
    ax.spines["bottom"].set_bounds(x_min, x_max)
    if y_data is not None:
        ax.spines["left"].set_bounds(min(y_data), max(y_data))


def label_lines_no_overlap(ax, series_endpoints, min_gap_pts=12):
    """End-of-line labels with vertical collision avoidance."""
    sorted_items = sorted(series_endpoints, key=lambda s: s[1])
    fig = ax.get_figure()
    fig.canvas.draw()
    inv = ax.transData.inverted()
    x0, _ = inv.transform((0, 0))
    x1, _ = inv.transform((28, 0))
    _, y0 = inv.transform((0, 0))
    _, y1 = inv.transform((0, min_gap_pts))
    label_dx = abs(x1 - x0)
    gap_data = abs(y1 - y0)

    display_positions = []
    for i, (x_end, y_end, label, line_color) in enumerate(sorted_items):
        pos = y_end
        if i > 0 and pos - display_positions[i - 1] < gap_data:
            pos = display_positions[i - 1] + gap_data
        display_positions.append(pos)

    for (x_end, y_end, label, line_color), y_display in zip(
        sorted_items, display_positions
    ):
        displaced = abs(y_display - y_end) > gap_data * 0.1
        ax.annotate(
            label,
            xy=(x_end, y_end),
            xytext=(x_end + label_dx, y_display),
            xycoords="data",
            textcoords="data",
            fontsize=CLEAN_LABEL_SIZE,
            color=CLEAN_BLACK,
            va="center",
            fontfamily="serif",
            arrowprops=(
                dict(arrowstyle="-", color=line_color, lw=0.8) if displaced else None
            ),
        )


# ═══════════════════════════════════════════════════════════════════════
# Chart 1 — Scatter: weight vs fuel economy
# Narrative: Japanese cars are lighter and more efficient
# ═══════════════════════════════════════════════════════════════════════
fig1, ax1 = plt.subplots(figsize=FIGSIZE)

for origin in ORIGIN_ORDER:
    sub = df[df.origin == origin]
    ax1.scatter(
        sub.weight,
        sub.mpg,
        c=ORIGIN_COLORS[origin],
        marker=ORIGIN_MARKERS[origin],
        s=18,
        alpha=0.7,
        edgecolors="none",
        label=ORIGIN_LABELS[origin],
    )

apply_range_frame(ax1, df.weight, df.mpg)
# Manual round ticks inside range frame
ax1.set_xticks([2000, 2500, 3000, 3500, 4000, 4500, 5000])
ax1.set_yticks([10, 15, 20, 25, 30, 35, 40, 45])
ax1.spines["bottom"].set_bounds(df.weight.min(), df.weight.max())
ax1.spines["left"].set_bounds(df.mpg.min(), df.mpg.max())

ax1.set_title("Japanese cars are lighter and more fuel-efficient")
ax1.set_xlabel("Weight (lbs)")
ax1.set_ylabel("Fuel economy (mpg)")

# Minimal legend (grouped scatter — direct labels would overlap)
ax1.legend(
    fontsize=CLEAN_SMALL_SIZE,
    loc="upper right",
    markerscale=1.2,
    handletextpad=0.4,
    borderpad=0,
    labelspacing=0.3,
)

plt.tight_layout()
OUT = pathlib.Path(__file__).parent / "output"
OUT.mkdir(exist_ok=True)
fig1.savefig(OUT / "chart1_weight_vs_mpg.png")


# ═══════════════════════════════════════════════════════════════════════
# Chart 2 — Multi-line: median mpg over model years by origin
# ═══════════════════════════════════════════════════════════════════════
fig2, ax2 = plt.subplots(figsize=FIGSIZE)

yearly = (
    df.groupby(["model_year", "origin"])["mpg"]
    .median()
    .reset_index()
    .pivot(index="model_year", columns="origin", values="mpg")
)
years = yearly.index.values
all_y = []
endpoints = []

for i, origin in enumerate(ORIGIN_ORDER):
    y = yearly[origin].values
    color = CLEAN_LINE_COLORS[i]
    style = CLEAN_LINE_STYLES[i]
    ax2.plot(years, y, linestyle=style, color=color, linewidth=1.2)
    all_y.extend(y[~np.isnan(y)])
    last_valid = np.where(~np.isnan(y))[0][-1]
    endpoints.append((years[last_valid], y[last_valid], ORIGIN_LABELS[origin], color))

apply_range_frame(ax2, years, all_y)
ax2.set_xticks([70, 75, 80, 82])
ax2.set_xticklabels(["'70", "'75", "'80", "'82"])
ax2.set_yticks([15, 20, 25, 30, 35])
ax2.spines["bottom"].set_bounds(years.min(), years.max())
ax2.spines["left"].set_bounds(min(all_y), max(all_y))

pad_axis_for_labels(ax2, years, all_y)

label_lines_no_overlap(ax2, endpoints)

ax2.set_title("Fuel economy rose steadily, led by Japan and Europe")
ax2.set_ylabel("Median mpg")

plt.tight_layout()
fig2.savefig(OUT / "chart2_mpg_trend_by_origin.png")


# ═══════════════════════════════════════════════════════════════════════
# Chart 3 — Strip plot: mpg distribution by cylinder count
# Shows full distribution, not just summary statistics
# ═══════════════════════════════════════════════════════════════════════
fig3, ax3 = plt.subplots(figsize=FIGSIZE)

cyl_counts = sorted(df.cylinders.unique())
for idx, cyl in enumerate(cyl_counts):
    vals = df.loc[df.cylinders == cyl, "mpg"].values
    jitter = np.random.default_rng(42).uniform(-0.15, 0.15, size=len(vals))
    color = CLEAN_ACCENT if cyl == 4 else CLEAN_LIGHT_GRAY
    ax3.scatter(
        np.full_like(vals, idx) + jitter,
        vals,
        s=12,
        color=color,
        alpha=0.6,
        edgecolors="none",
    )
    # Overlay median tick
    med = np.median(vals)
    ax3.hlines(med, idx - 0.25, idx + 0.25, colors=CLEAN_BLACK, linewidths=1.2)
    ax3.text(
        idx + 0.30,
        med,
        f"{med:.0f}",
        va="center",
        fontsize=CLEAN_SMALL_SIZE,
        color=CLEAN_BLACK,
        fontfamily="serif",
    )

ax3.set_xticks(range(len(cyl_counts)))
ax3.set_xticklabels([f"{c} cyl" for c in cyl_counts])
ax3.spines["left"].set_bounds(df.mpg.min(), df.mpg.max())
ax3.set_yticks([10, 20, 30, 40])
ax3.spines["bottom"].set_visible(False)
ax3.tick_params(bottom=False)
ax3.set_ylabel("Fuel economy (mpg)")
ax3.set_title("Four-cylinder cars dominate fuel economy")

plt.tight_layout()
fig3.savefig(OUT / "chart3_mpg_by_cylinders.png")


# ═══════════════════════════════════════════════════════════════════════
# Chart 4 — Horizontal bar: median mpg by origin
# ═══════════════════════════════════════════════════════════════════════
fig4, ax4 = plt.subplots(figsize=(FIGSIZE[0], 3))

medians = df.groupby("origin")["mpg"].median().reindex(ORIGIN_ORDER)
sorted_pairs = sorted(zip(ORIGIN_ORDER, medians), key=lambda p: p[1])
cats = [ORIGIN_LABELS[p[0]] for p in sorted_pairs]
vals = [p[1] for p in sorted_pairs]
origins_sorted = [p[0] for p in sorted_pairs]

bar_colors = [
    CLEAN_ACCENT if o == "japan" else CLEAN_MEDIUM_GRAY for o in origins_sorted
]
bars = ax4.barh(cats, vals, color=bar_colors, edgecolor="none", height=0.5)

for spine in ax4.spines.values():
    spine.set_visible(False)

ax4.xaxis.grid(color=CLEAN_REF_GRAY, linewidth=0.8)
ax4.set_axisbelow(True)
ax4.tick_params(bottom=False, left=False)

for bar, val in zip(bars, vals):
    ax4.text(
        val + 0.4,
        bar.get_y() + bar.get_height() / 2,
        f"{val:.1f} mpg",
        ha="left",
        va="center",
        fontsize=CLEAN_LABEL_SIZE,
        fontfamily="serif",
        color=CLEAN_BLACK,
    )

ax4.set_title("Japan leads in median fuel economy")
ax4.set_xlim(0, max(vals) * 1.20)

plt.tight_layout()
fig4.savefig(OUT / "chart4_median_mpg_by_origin.png")


# ═══════════════════════════════════════════════════════════════════════
# Chart 5 — Small multiples: displacement vs mpg by origin
# ═══════════════════════════════════════════════════════════════════════
fig5, axes5 = plt.subplots(1, 3, figsize=(12, 4), sharex=True, sharey=True)

all_disp = df.displacement
all_mpg = df.mpg

for ax, origin in zip(axes5, ORIGIN_ORDER):
    sub = df[df.origin == origin]
    # Context: all points in light gray
    ax.scatter(all_disp, all_mpg, s=8, color=CLEAN_LIGHT_GRAY, edgecolors="none", alpha=0.3)
    # Focal: this origin's points
    focal_color = CLEAN_ACCENT if origin == "japan" else CLEAN_DARK_GRAY
    ax.scatter(sub.displacement, sub.mpg, s=14, color=focal_color, edgecolors="none", alpha=0.7)

    ax.set_title(ORIGIN_LABELS[origin], fontsize=CLEAN_FONT_SIZE, fontfamily="serif")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(direction="in", labelsize=CLEAN_SMALL_SIZE)

# Shared axis labels
axes5[0].set_ylabel("Fuel economy (mpg)")
fig5.text(0.5, -0.01, "Displacement (cu. in.)", ha="center", fontsize=CLEAN_FONT_SIZE, fontfamily="serif")

# Shared range-frame ticks
for ax in axes5:
    ax.set_xticks([100, 200, 300, 400])
    ax.set_yticks([10, 20, 30, 40])
    ax.spines["bottom"].set_bounds(all_disp.min(), all_disp.max())
    ax.spines["left"].set_bounds(all_mpg.min(), all_mpg.max())

fig5.suptitle(
    "Japanese cars cluster at low displacement and high mpg",
    fontsize=CLEAN_TITLE_SIZE,
    fontfamily="serif",
    y=1.02,
)
plt.tight_layout()
fig5.savefig(OUT / "chart5_displacement_vs_mpg_faceted.png", bbox_inches="tight")

plt.show()
