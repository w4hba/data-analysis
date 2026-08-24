# Data source: Online Retail II

## Source
- **Dataset:** Online Retail II
- **Publisher:** UCI Machine Learning Repository (dataset 502), donated by Daqing Chen, London South Bank University
- **Landing page:** https://archive.ics.uci.edu/dataset/502/online+retail+ii
- **Direct download:** https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip (45.6 MB)
- **License:** Creative Commons Attribution 4.0 International (CC BY 4.0). Commercial use permitted with attribution.
- **Citation:** Chen, D. (2019). Online Retail II [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D

## What it is
Transaction-level records for a UK-based online gift retailer, one row per product line
per invoice, spanning 2009-12-01 to 2011-12-09. 1,067,371 rows, 8 columns:
Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country.

The retailer sells mostly to wholesale buyers, so order sizes and monetary values are
right-skewed by bulk purchases.

## Reproduction
The raw file is not committed (`data/raw/` is gitignored). To rebuild it:

```bash
# 1. download + unzip into data/raw/
curl -sSL -o data/raw/online_retail_II.zip \
  "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
unzip -o data/raw/online_retail_II.zip -d data/raw/

# 2. convert the two-sheet workbook to one load-ready CSV
python data/convert_xlsx_to_csv.py     # -> data/raw/online_retail_II.csv
```

## Why a conversion step exists
The source is a single `.xlsx` with two sheets, one per year. MySQL's `LOAD DATA` reads
CSV, not Excel, so `convert_xlsx_to_csv.py` stacks both sheets into one CSV. It changes
only what is needed to make the file loadable: nulls written as `\N`, integer customer
IDs, ISO datetimes, and newlines stripped from free-text descriptions. Everything else
(cancellations, negatives, duplicates, non-product codes) stays intact and is handled in
`sql/02_load_and_clean.sql`, so the cleaning logic is visible in SQL rather than hidden
in a script.

## Known data quality issues (measured on the full file)
| Issue | Count | Handling |
|---|---:|---|
| Cancellations (Invoice starts `C`) | 19,494 | Excluded from the sales base; counted separately as returns |
| Negative Quantity | 22,950 | Excluded (returns/adjustments) |
| Zero or negative Price | 6,207 | Excluded |
| Null Customer ID | 243,007 (22.8%) | Kept for revenue totals; excluded from cohort/RFM, which require a customer |
| Exact duplicate rows | 34,339 | De-duplicated on (Invoice, StockCode, Quantity, Price, Customer ID) |
| Non-product StockCodes (POST, DOT, M, BANK CHARGES, AMAZONFEE, ADJUST, …) | 66 distinct codes | Excluded from product-level analysis |

Counts were produced directly from the source file, not copied from documentation.
