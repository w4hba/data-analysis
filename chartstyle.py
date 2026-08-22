"""Shared matplotlib styling for the portfolio charts.

One palette and one set of rcParams so every chart across the three projects reads
as a single system. Colors are the validated defaults from the data-viz reference
palette (blue primary, orange highlight, a single-hue blue ramp for magnitude).
Charts render on a near-white surface so they stay legible on GitHub's light and
dark themes alike.
"""
from __future__ import annotations

import matplotlib as mpl
from matplotlib.colors import LinearSegmentedColormap

# chrome + ink
SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK_2 = "#52514e"
MUTED = "#898781"
GRID = "#e1e0d9"
BASELINE = "#c3c2b7"

# categorical (validated adjacent pair)
BLUE = "#2a78d6"
ORANGE = "#eb6834"
CRITICAL = "#d03b3b"
GOOD = "#0ca30c"

# single-hue blue ramp for sequential magnitude (heatmaps)
SEQ_BLUE = ["#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b"]
CMAP_BLUE = LinearSegmentedColormap.from_list("seq_blue", SEQ_BLUE)


def apply_style() -> None:
    mpl.rcParams.update({
        "figure.facecolor": SURFACE,
        "axes.facecolor": SURFACE,
        "savefig.facecolor": SURFACE,
        "font.family": "sans-serif",
        "font.sans-serif": ["Helvetica Neue", "Helvetica", "Arial", "DejaVu Sans"],
        "font.size": 11,
        "text.color": INK,
        "axes.edgecolor": BASELINE,
        "axes.labelcolor": INK_2,
        "axes.titlecolor": INK,
        "axes.titlesize": 14,
        "axes.titleweight": "bold",
        "axes.spines.top": False,
        "axes.spines.right": False,
        "xtick.color": MUTED,
        "ytick.color": MUTED,
        "xtick.labelcolor": INK_2,
        "ytick.labelcolor": INK_2,
        "axes.grid": True,
        "axes.axisbelow": True,
        "grid.color": GRID,
        "grid.linewidth": 0.8,
        "figure.dpi": 110,
        "savefig.dpi": 150,
        "savefig.bbox": "tight",
    })


def title(ax, main: str, subtitle: str | None = None) -> None:
    """Bold title with an optional muted one-line subtitle beneath it."""
    ax.set_title(main, loc="left", pad=18 if subtitle else 10)
    if subtitle:
        ax.text(0.0, 1.02, subtitle, transform=ax.transAxes,
                fontsize=10.5, color=MUTED, ha="left", va="bottom")
