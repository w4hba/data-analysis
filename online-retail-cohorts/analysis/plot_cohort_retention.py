"""Cohort retention heatmap -> assets/cohort_retention_heatmap.png (from sql/04)."""
import pathlib
import sys

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJ = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from db import get_engine, query_file          # noqa: E402
import chartstyle as cs                          # noqa: E402

MAX_OFFSET = 18   # keep the grid readable; later offsets exist only for early cohorts


def main() -> int:
    cs.apply_style()
    df = query_file(get_engine(), PROJ / "sql" / "04_cohort_retention.sql")
    # Drop offset 0 (always 100% by construction) so the color scale spans real decay.
    df = df[(df["month_offset"] >= 1) & (df["month_offset"] <= MAX_OFFSET)]

    piv = df.pivot(index="cohort_month", columns="month_offset", values="retention_pct")
    sizes = df.groupby("cohort_month")["cohort_size"].first()
    labels = [f"{pd.to_datetime(m).strftime('%b %Y')}  (n={sizes[m]:,})" for m in piv.index]

    fig, ax = plt.subplots(figsize=(11, 6.4))
    data = np.ma.masked_invalid(piv.values)
    im = ax.imshow(data, aspect="auto", cmap=cs.CMAP_BLUE, vmin=0, vmax=50)

    ax.set_xticks(range(piv.shape[1]))
    ax.set_xticklabels(piv.columns)
    ax.set_yticks(range(piv.shape[0]))
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel("Months since first purchase")
    ax.grid(False)

    # Annotate each cell; drop the trivial 100% acquisition column to reduce noise.
    for i in range(piv.shape[0]):
        for j in range(piv.shape[1]):
            v = piv.values[i, j]
            if np.isnan(v):
                continue
            ax.text(j, i, f"{v:.0f}", ha="center", va="center", fontsize=7.5,
                    color=cs.INK if v < 28 else "#ffffff")

    cbar = fig.colorbar(im, ax=ax, fraction=0.025, pad=0.02)
    cbar.set_label("Retention (%)", color=cs.INK_2)
    cbar.outline.set_visible(False)

    cs.title(ax, "Holiday cohorts churn; the early wholesale base sticks",
             "Share of each month's new customers active again N months later "
             "(acquisition month = 100%, omitted).")
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    out = PROJ / "assets" / "cohort_retention_heatmap.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
