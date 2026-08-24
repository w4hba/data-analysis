"""Traffic-source conversion with 95% CIs -> assets/traffic_type_ci.png (from sql/05).

Point conversion rate per channel with Wilson 95% CI whiskers. Where whiskers don't
overlap, the channels differ by more than sampling noise.
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


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "05_conversion_by_traffic_type.sql")
    df = df.sort_values("conversion_pct").reset_index(drop=True)

    y = np.arange(len(df))
    lo = df["conversion_pct"] - df["ci_low_pct"]
    hi = df["ci_high_pct"] - df["conversion_pct"]

    fig, ax = plt.subplots(figsize=(9.5, 5.6))
    ax.errorbar(df["conversion_pct"], y, xerr=[lo, hi], fmt="o", color=cs.BLUE,
                ecolor=cs.BASELINE, elinewidth=1.6, capsize=3, markersize=7, zorder=3)
    ax.axvline(15.47, color=cs.MUTED, linewidth=1, linestyle=(0, (4, 3)))
    ax.text(15.47, len(df) - 0.4, " overall 15.5%", color=cs.MUTED, fontsize=9, va="top")

    for yi, (_, r) in enumerate(df.iterrows()):
        ax.text(r["ci_high_pct"] + 0.6, yi, f"{r['conversion_pct']:.0f}%  (n={int(r['sessions']):,})",
                va="center", fontsize=8.5, color=cs.INK_2)

    ax.set_yticks(y)
    ax.set_yticklabels([f"Traffic type {int(t)}" for t in df["traffic_type"]])
    ax.set_xlabel("Conversion rate (%), with 95% confidence interval")
    ax.set_xlim(0, 38)
    ax.grid(axis="y", visible=False)
    cs.title(ax, "Conversion varies 5x across traffic sources",
             "Channels with ≥100 sessions, ranked. Non-overlapping intervals are "
             "real differences, not noise.")
    fig.tight_layout()
    out = PROJ / "assets" / "traffic_type_ci.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
