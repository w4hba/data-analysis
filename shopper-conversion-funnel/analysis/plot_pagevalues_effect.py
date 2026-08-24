"""PageValues vs conversion -> assets/pagevalues_effect.png (from sql/06)."""
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
    df = query_file(get_engine(), PROJ / "sql" / "06_pagevalues_effect.sql")
    # zero bucket muted, the rising quartiles in blue
    colors = [cs.MUTED] + [cs.BLUE] * (len(df) - 1)

    labels = [f"{b}\n(n={int(n):,})" for b, n in zip(df["pv_bucket"], df["sessions"])]
    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(labels, df["conversion_pct"], color=colors, width=0.62)
    ax.bar_label(bars, labels=[f"{v:.0f}%" for v in df["conversion_pct"]],
                 padding=4, fontsize=11, color=cs.INK, fontweight="bold")

    ax.set_ylabel("Conversion rate (%)")
    ax.set_ylim(0, 90)
    ax.grid(axis="x", visible=False)
    cs.title(ax, "PageValues is the strongest conversion signal",
             "3.9% of zero-PageValues sessions convert; the top quartile of non-zero "
             "sessions converts at 78%.")
    fig.tight_layout()
    out = PROJ / "assets" / "pagevalues_effect.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
