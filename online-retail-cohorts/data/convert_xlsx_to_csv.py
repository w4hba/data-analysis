"""
Convert the UCI Online Retail II workbook into a single load-ready CSV.

The source ships as one .xlsx with two sheets ("Year 2009-2010", "Year 2010-2011").
MySQL's LOAD DATA cannot read .xlsx, so this step stacks both sheets into one CSV
that 02_load_and_clean.sql loads into a staging table. It does NOT clean the data
beyond what is needed to make the file loadable — the analytical cleaning (dropping
cancellations, negatives, dedupe, etc.) happens in SQL so it is visible and auditable.

Two things are normalized here because they would otherwise break a flat CSV load:
  - "Customer ID" (float like 13085.0, blank when missing) -> integer or empty,
    written as \\N so MySQL loads it as NULL rather than 0.
  - Description free text may contain embedded newlines, which would split a row
    across lines under LINES TERMINATED BY '\\n'. Newlines are collapsed to spaces.

Run:  python data/convert_xlsx_to_csv.py
Reads: data/raw/online_retail_II.xlsx   Writes: data/raw/online_retail_II.csv
"""
from pathlib import Path
import sys
import pandas as pd

HERE = Path(__file__).resolve().parent
SRC = HERE / "raw" / "online_retail_II.xlsx"
OUT = HERE / "raw" / "online_retail_II.csv"

COLUMNS = ["Invoice", "StockCode", "Description", "Quantity",
           "InvoiceDate", "Price", "CustomerID", "Country"]


def main() -> int:
    if not SRC.exists():
        sys.exit(f"Source not found: {SRC}\nDownload it first (see data/README.md).")

    xls = pd.ExcelFile(SRC)
    frames = []
    for sheet in xls.sheet_names:
        df = xls.parse(sheet)
        frames.append(df)
        print(f"read '{sheet}': {len(df):,} rows")

    d = pd.concat(frames, ignore_index=True)
    d = d.rename(columns={"Customer ID": "CustomerID"})

    # Nullable integer so IDs write as "13085" and missing IDs write as blank/\N.
    d["CustomerID"] = d["CustomerID"].astype("Int64")
    # Collapse newlines/tabs in free text so each record stays on one CSV line.
    d["Description"] = (
        d["Description"].astype("string")
        .str.replace(r"[\r\n\t]+", " ", regex=True)
        .str.strip()
    )
    # ISO datetime string that MySQL DATETIME parses without STR_TO_DATE.
    d["InvoiceDate"] = pd.to_datetime(d["InvoiceDate"]).dt.strftime("%Y-%m-%d %H:%M:%S")

    d = d[COLUMNS]
    d.to_csv(OUT, index=False, na_rep="\\N", encoding="utf-8")
    print(f"\nwrote {len(d):,} rows -> {OUT}")
    print(f"file size: {OUT.stat().st_size/1e6:.1f} MB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
