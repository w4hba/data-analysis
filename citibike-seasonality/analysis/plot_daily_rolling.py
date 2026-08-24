"""Daily rides with 7-day average, one panel per season.
-> assets/daily_rolling.png (from sql/06).

Shared y-axis so the seasonal level difference is visible; the bold line is the
month-partitioned 7-day moving average, the thin bars are raw daily counts.
"""
import pathlib
import sys

import matplotlib.pyplot as plt
import pandas as pd

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402

TITLES = {1: "January (winter)", 4: "April (spring)",
          7: "July (summer)", 10: "October (fall)"}


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "06_daily_trend_rolling.sql")
    df["started_date"] = pd.to_datetime(df["started_date"])
    df["day"] = df["started_date"].dt.day
    ymax = df["rides"].max() / 1e3

    fig, axes = plt.subplots(2, 2, figsize=(11, 6.4), sharey=True)
    for ax, m in zip(axes.ravel(), [1, 4, 7, 10]):
        sub = df[df["month_num"] == m]
        ax.bar(sub["day"], sub["rides"] / 1e3, color=cs.BLUE, alpha=0.28, width=0.8)
        ax.plot(sub["day"], sub["rides_7day_avg"] / 1e3, color=cs.BLUE, linewidth=2)
        ax.set_title(TITLES[m], loc="left", fontsize=11.5, color=cs.INK)
        ax.set_ylim(0, ymax * 1.1)
        ax.set_xlim(0.5, 31.5)
        ax.set_xlabel("Day of month", fontsize=9)
        ax.grid(axis="x", visible=False)
    for ax in axes[:, 0]:
        ax.set_ylabel("Rides (thousands)")

    fig.suptitle("Ridership climbs into fall; every week dips on weekends",
                 x=0.01, ha="left", fontsize=14, fontweight="bold", color=cs.INK)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    out = PROJ / "assets" / "daily_rolling.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
