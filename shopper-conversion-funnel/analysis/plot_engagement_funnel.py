"""Engagement funnel -> assets/engagement_funnel.png (from sql/03)."""
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
    df = query_file(get_engine(), PROJ / "sql" / "03_engagement_funnel.sql")
    df = df.iloc[::-1].reset_index(drop=True)     # deepest stage on top

    fig, ax = plt.subplots(figsize=(9.5, 4.8))
    # width = share of sessions; color = conversion rate (highlight the valued stage)
    colors = [cs.ORANGE if "valued" in s else cs.BLUE for s in df["engagement_stage"]]
    bars = ax.barh(df["engagement_stage"], df["pct_of_sessions"], color=colors, height=0.62)
    for y, (_, r) in enumerate(df.iterrows()):
        ax.text(r["pct_of_sessions"] + 1.2, y,
                f"{r['sessions']:,} sessions · {r['conversion_rate_pct']:.0f}% convert",
                va="center", fontsize=9.5, color=cs.INK)

    ax.set_xlim(0, 100)
    ax.set_xlabel("Share of all sessions (%)")
    ax.grid(axis="y", visible=False)
    cs.title(ax, "The conversion cliff is reaching a page with value",
             "12,330 sessions by engagement depth. Only 22% reach a valued page — but "
             "those convert at 56%.")
    fig.tight_layout()
    out = PROJ / "assets" / "engagement_funnel.png"
    fig.savefig(out)
    print("wrote", out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
