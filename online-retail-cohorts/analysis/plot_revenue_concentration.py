"""Revenue concentration (Pareto) -> assets/revenue_concentration.png (from sql/07).

Per-decile share (bars) and cumulative share (line) are both percentages, so they
share one axis — no second y-scale.
"""
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
    df = query_file(get_engine(), PROJ / "sql" / "07_revenue_concentration.sql")

    x = df["spend_decile"]
    fig, ax = plt.subplots(figsize=(9.5, 5.0))
    bars = ax.bar(x, df["revenue_share_pct"], color=cs.BLUE, width=0.62,
                  label="Revenue in this decile")
    ax.bar_label(bars, labels=[f"{v:.0f}" for v in df["revenue_share_pct"]],
                 padding=3, fontsize=9, color=cs.INK_2)
    ax.plot(x, df["cumulative_share_pct"], color=cs.ORANGE, linewidth=2,
            marker="o", markersize=5, label="Cumulative revenue")

    # Call out the top-decile and top-30% cumulative points.
    ax.annotate(f"Top 10% = {df.loc[df.spend_decile==1,'cumulative_share_pct'].iat[0]:.0f}%",
                (1, df.loc[df.spend_decile == 1, "cumulative_share_pct"].iat[0]),
                textcoords="offset points", xytext=(14, -4), fontsize=9,
                color=cs.ORANGE, fontweight="bold")
    ax.annotate(f"Top 30% = {df.loc[df.spend_decile==3,'cumulative_share_pct'].iat[0]:.0f}%",
                (3, df.loc[df.spend_decile == 3, "cumulative_share_pct"].iat[0]),
                textcoords="offset points", xytext=(10, 14), fontsize=9, color=cs.ORANGE)

    ax.set_xticks(range(1, 11))
    ax.set_xticklabels([f"{d}0%" for d in range(1, 11)])
    ax.set_xlabel("Customer spend decile (cumulative share of customers)")
    ax.set_ylabel("Share of revenue (%)")
    ax.set_ylim(0, 105)
    ax.legend(loc="center right", frameon=False, fontsize=9.5)
    cs.title(ax, "Revenue is highly concentrated",
             "Customers ranked by lifetime spend, split into deciles.")
    fig.tight_layout()
    out = PROJ / "assets" / "revenue_concentration.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
