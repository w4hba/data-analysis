# Data source: Online Shoppers Purchasing Intention

## Source
- **Dataset:** Online Shoppers Purchasing Intention Dataset
- **Publisher:** UCI Machine Learning Repository ([dataset 468](https://archive.ics.uci.edu/dataset/468/online+shoppers+purchasing+intention+dataset))
- **Direct download:** https://archive.ics.uci.edu/static/public/468/online+shoppers+purchasing+intention+dataset.zip (~1 MB)
- **License:** Creative Commons Attribution 4.0 International (CC BY 4.0). Commercial use permitted with attribution.
- **Citation:** Sakar, C.O. & Kastro, Y. (2018). Online Shoppers Purchasing Intention Dataset [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5F88Q

## What it is
12,330 browsing sessions on an e-commerce site over a one-year span, with 17 features
and a boolean `Revenue` target (did the session end in a purchase). Features include
page-group counts and dwell times (Administrative, Informational, ProductRelated),
Google-Analytics session metrics (BounceRates, ExitRates, PageValues, SpecialDay), and
context (Month, VisitorType, Weekend, plus anonymized OperatingSystems, Browser,
Region, TrafficType).

Overall conversion is **15.47%** (1,908 of 12,330).

## Important framing: this is session-level, not an event funnel
Each row is one session summarized as aggregate metrics, not a stream of clicks for
one user. So the "funnel" in this project is **engineered** from the page-group counts
(did the session reach product pages, did it reach pages with value), not traced step
by step through a real user journey. The analysis says so wherever it matters.

## Known data quality issues (verified on the file)
- **Month is inconsistent.** Nine 3-letter codes plus one spelled-out `June`; `02`
  normalizes them to a month number.
- **Two months are missing.** No January or April rows at all, so any month/seasonal
  read has gaps.
- **125 exact-duplicate rows** are kept, not dropped. Rows are anonymized session
  feature-vectors, so identical rows are plausibly distinct bounce sessions; removing
  them would undercount bounces. Flagged, not deleted.
- **Anonymized codes.** OperatingSystems, Browser, Region, TrafficType are integer
  codes with no published lookup, so segments are "TrafficType 2", not "Google / paid".
- **Class imbalance.** 15.47% positive. Matters for baselining conversion lift.
- **PageValues is 0 for 77.9% of sessions** and long-tailed otherwise.

## Reproduction
```bash
cd shopper-conversion-funnel/data/raw
curl -sSL -o online_shoppers.zip \
  "https://archive.ics.uci.edu/static/public/468/online+shoppers+purchasing+intention+dataset.zip"
unzip -o online_shoppers.zip
# then, from the repo root (needs local_infile=1):
mysql --defaults-extra-file=../../../db.local.cnf < ../../sql/01_schema.sql
mysql --defaults-extra-file=../../../db.local.cnf --local-infile=1 < ../../sql/02_load_and_clean.sql
```
