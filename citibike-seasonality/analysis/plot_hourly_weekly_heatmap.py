"""Weekday x hour demand heatmap, members vs casual.
-> assets/hourly_weekly_heatmap.png (from sql/04).

Each panel is scaled to its own busiest hour, so the timing *pattern* is comparable
even though members ride far more than casual riders overall.
"""
import pathlib
import sys

import matplotlib.pyplot as plt
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "04_hourly_weekly_profile.sql")

    fig, axes = plt.subplots(1, 2, figsize=(13, 4.6), sharey=True)
    for ax, grp in zip(axes, ["member", "casual"]):
        sub = df[df["member_casual"] == grp]
        mat = (sub.pivot(index="weekday_num", columns="started_hour", values="rides")
                  .reindex(index=range(7), columns=range(24)).fillna(0).values)
        mat_pct = 100 * mat / mat.max()          # scale to this panel's peak hour
        im = ax.imshow(mat_pct, aspect="auto", cmap=cs.CMAP_BLUE, vmin=0, vmax=100)
        ax.set_xticks(range(0, 24, 3))
        ax.set_xticklabels(range(0, 24, 3))
        ax.set_yticks(range(7))
        ax.set_yticklabels(DAYS)
        ax.set_xlabel("Hour of day")
        ax.grid(False)
        ax.set_title(f"{grp.capitalize()}s", loc="left", fontsize=12, color=cs.INK)

    cbar = fig.colorbar(im, ax=axes, fraction=0.02, pad=0.02)
    cbar.set_label("% of panel's peak hour", color=cs.INK_2)
    cbar.outline.set_visible(False)
    fig.suptitle("Members commute; casual riders ride weekend middays",
                 x=0.02, ha="left", fontsize=14, fontweight="bold", color=cs.INK)
    out = PROJ / "assets" / "hourly_weekly_heatmap.png"
    fig.savefig(out, bbox_inches="tight")
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
