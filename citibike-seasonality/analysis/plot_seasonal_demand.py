"""Seasonal ridership -> assets/seasonal_demand.png (from sql/03)."""
import pathlib
import sys

import matplotlib.pyplot as plt

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "03_seasonal_demand.sql")
    rides_m = df["rides"] / 1e6
    peak, trough = rides_m.max(), rides_m.min()
    peak_season = df.loc[rides_m.idxmax(), "season"].split(" ")[0]

    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(df["season"], rides_m, color=cs.BLUE, width=0.6)
    ax.bar_label(bars, labels=[f"{v:.1f}M" for v in rides_m], padding=4,
                 fontsize=11, color=cs.INK, fontweight="bold")
    # casual share sits under each bar's value
    for x, (_, r) in enumerate(df.iterrows()):
        ax.text(x, rides_m[x] / 2, f"{r['pct_casual']:.0f}%\ncasual",
                ha="center", va="center", fontsize=9, color="#ffffff")

    ax.set_ylabel("Rides (millions)")
    ax.set_ylim(0, peak * 1.15)
    ax.grid(axis="x", visible=False)
    cs.title(ax, f"Peak-season ridership is {peak/trough:.1f}x winter",
             f"Citi Bike rides per sampled month, 2024 ({peak_season} is busiest). "
             "Casual share rises with the weather.")
    fig.tight_layout()
    out = PROJ / "assets" / "seasonal_demand.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
