"""Monthly revenue trend -> assets/monthly_revenue_trend.png (from sql/03)."""
import pathlib
import sys

import matplotlib.pyplot as plt
import pandas as pd

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "03_revenue_and_orders_trend.sql")
    df["month"] = pd.to_datetime(df["month"])
    rev_m = df["revenue"] / 1e6

    fig, ax = plt.subplots(figsize=(10, 4.6))
    ax.fill_between(df["month"], rev_m, color=cs.BLUE, alpha=0.10)
    ax.plot(df["month"], rev_m, color=cs.BLUE, linewidth=2, marker="o", markersize=4)

    # Label the two November peaks — the holiday build-up is the seasonal signal.
    for _, r in df.iterrows():
        if r["month"].month == 11:
            ax.annotate(f"£{r['revenue']/1e6:.2f}m",
                        (r["month"], r["revenue"] / 1e6),
                        textcoords="offset points", xytext=(0, 9),
                        ha="center", fontsize=9, color=cs.INK, fontweight="bold")

    ax.set_ylim(0, rev_m.max() * 1.18)
    ax.set_ylabel("Revenue (£m)")
    ax.margins(x=0.02)
    cs.title(ax, "Monthly revenue peaks every autumn",
             "Net sales after removing cancellations, returns, and non-product lines. "
             "Dec 2011 is partial (data ends Dec 9).")
    fig.tight_layout()
    out = PROJ / "assets" / "monthly_revenue_trend.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
