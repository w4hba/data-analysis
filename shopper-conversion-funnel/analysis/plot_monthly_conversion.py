"""Monthly conversion -> assets/monthly_conversion.png (from sql/07)."""
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
    df = query_file(get_engine(), PROJ / "sql" / "07_conversion_by_month.sql")
    peak = df["conversion_pct"].idxmax()
    colors = [cs.ORANGE if i == peak else cs.BLUE for i in df.index]

    fig, ax = plt.subplots(figsize=(9.5, 5))
    bars = ax.bar(df["month"], df["conversion_pct"], color=colors, width=0.64)
    ax.bar_label(bars, labels=[f"{v:.0f}" for v in df["conversion_pct"]],
                 padding=3, fontsize=9.5, color=cs.INK_2)
    ax.axhline(15.47, color=cs.MUTED, linewidth=1, linestyle=(0, (4, 3)))
    ax.text(len(df) - 0.5, 15.47, "overall 15.5%", color=cs.MUTED, fontsize=9,
            va="bottom", ha="right")

    ax.set_ylabel("Conversion rate (%)")
    ax.set_ylim(0, 30)
    ax.grid(axis="x", visible=False)
    cs.title(ax, "Conversion builds through fall and peaks in November",
             "By month (Jan and Apr are absent from the data). November is Black-Friday "
             "season; February is the trough.")
    fig.tight_layout()
    out = PROJ / "assets" / "monthly_conversion.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
