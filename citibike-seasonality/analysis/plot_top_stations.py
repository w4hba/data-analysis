"""Top start stations -> assets/top_stations.png (from sql/07).

Bars colored by rider mix: orange marks leisure-leaning docks (>=30% casual),
blue the commuter docks that dominate the top of the list.
"""
import pathlib
import sys

import matplotlib.pyplot as plt

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402

CASUAL_CUT = 30.0


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "07_top_stations.sql")
    df = df.sort_values("rides")                    # largest at top after barh
    colors = [cs.ORANGE if c >= CASUAL_CUT else cs.BLUE for c in df["pct_casual"]]

    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.barh(df["start_station_name"], df["rides"] / 1e3, color=colors, height=0.7)
    ax.bar_label(bars, labels=[f"{v/1e3:.0f}k · {c:.0f}% casual"
                               for v, c in zip(df["rides"], df["pct_casual"])],
                 padding=4, fontsize=8.5, color=cs.INK_2)

    ax.set_xlabel("Rides (thousands)")
    ax.set_xlim(0, df["rides"].max() / 1e3 * 1.22)
    ax.grid(axis="y", visible=False)
    # legend by proxy
    from matplotlib.patches import Patch
    ax.legend(handles=[Patch(color=cs.BLUE, label="Commuter dock (<30% casual)"),
                       Patch(color=cs.ORANGE, label="Leisure-leaning (≥30% casual)")],
              loc="lower right", frameon=False, fontsize=9)
    cs.title(ax, "The busiest docks are commuter stations",
             "Top 15 start stations, 2024 (4 sampled months). A few near parks and the "
             "waterfront skew casual.")
    fig.tight_layout()
    out = PROJ / "assets" / "top_stations.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
