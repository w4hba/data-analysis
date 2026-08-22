"""RFM segment value -> assets/rfm_segments.png (from sql/05)."""
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
    df = query_file(get_engine(), PROJ / "sql" / "05_rfm_segments.sql")
    df = df.sort_values("revenue_share_pct")     # largest at top after barh

    # Blue for all; orange flags "At Risk" — lapsed but high-value, the re-engagement target.
    colors = [cs.ORANGE if s == "At Risk" else cs.BLUE for s in df["segment"]]

    fig, ax = plt.subplots(figsize=(9.5, 5.6))
    bars = ax.barh(df["segment"], df["revenue_share_pct"], color=colors, height=0.46)
    ax.bar_label(bars, labels=[f"{v:.0f}%" for v in df["revenue_share_pct"]],
                 padding=5, fontsize=10, color=cs.INK, fontweight="bold")

    # Second line sits in the gap below each bar (bar half-height 0.23 < 0.36 offset).
    for y, (_, r) in enumerate(df.iterrows()):
        ax.text(0.3, y - 0.36, f"{int(r['customers']):,} customers · "
                f"{int(r['avg_recency_days'])}d since last order · avg {r['avg_orders']:.1f} orders",
                fontsize=8.5, color=cs.MUTED, va="center")

    ax.set_ylim(-0.7, len(df) - 0.3)
    ax.set_xlim(0, max(df["revenue_share_pct"]) * 1.15)
    ax.set_xlabel("Share of revenue (%)")
    ax.grid(axis="y", visible=False)
    cs.title(ax, "Two segments hold 85% of revenue; 'At Risk' is the leak",
             "Customers scored on Recency, Frequency, Monetary (NTILE quintiles). "
             "'At Risk' = lapsed repeat buyers.")
    fig.tight_layout()
    out = PROJ / "assets" / "rfm_segments.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
