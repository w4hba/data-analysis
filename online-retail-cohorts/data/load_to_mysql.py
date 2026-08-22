"""Load the raw Online Retail II CSV into the stg_retail staging table.

Prerequisites: run sql/01_schema.sql (creates stg_retail), and
convert_xlsx_to_csv.py (produces raw/online_retail_II.csv).

A chunked INSERT is used rather than LOAD DATA LOCAL INFILE because this server
has local_infile disabled and the analyst user cannot enable it. The equivalent
bulk-load, if you have the privilege, is documented in sql/02_load_and_clean.sql.
"""
import pathlib
import sys

import pandas as pd

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2]))
from db import get_engine  # noqa: E402

CSV = pathlib.Path(__file__).resolve().parent / "raw" / "online_retail_II.csv"


def main() -> int:
    if not CSV.exists():
        sys.exit(f"Missing {CSV} — run convert_xlsx_to_csv.py first.")

    df = pd.read_csv(
        CSV,
        na_values=["\\N"],
        dtype={"Invoice": "string", "StockCode": "string",
               "Description": "string", "Country": "string"},
    )
    df["CustomerID"] = df["CustomerID"].astype("Int64")
    df.columns = ["invoice", "stock_code", "description", "quantity",
                  "invoice_date", "price", "customer_id", "country"]

    engine = get_engine()
    with engine.begin() as conn:
        conn.exec_driver_sql("TRUNCATE TABLE stg_retail")
    df.to_sql("stg_retail", engine, if_exists="append", index=False,
              chunksize=10_000, method="multi")

    with engine.connect() as conn:
        n = conn.exec_driver_sql("SELECT COUNT(*) FROM stg_retail").scalar()
    print(f"loaded {n:,} rows into stg_retail")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
