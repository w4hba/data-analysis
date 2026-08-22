# Customer retention and value — Online Retail II

**Question:** How do acquisition cohorts retain, which customer segments hold the
revenue, and who is worth winning back?

**Headline:** Repeat buyers are 72% of identified customers but 96.7% of revenue.
Holiday-acquired cohorts churn to single-digit retention within months, while a
group of 711 lapsed repeat buyers — worth £1.5M — is sliding away and is the
clearest re-engagement target.

## Dataset
- **Online Retail II**, UCI Machine Learning Repository ([dataset 502](https://archive.ics.uci.edu/dataset/502/online+retail+ii)), CC BY 4.0.
- 1,067,371 transaction lines for a UK online gift retailer, Dec 2009 – Dec 2011.
- Source, license, and download/reproduction steps: [`data/README.md`](data/README.md).

## Approach
1. **Load** the two-sheet Excel workbook to one CSV ([`data/convert_xlsx_to_csv.py`](data/convert_xlsx_to_csv.py)), then into a staging table ([`data/load_to_mysql.py`](data/load_to_mysql.py)).
2. **Clean** in SQL ([`sql/02_load_and_clean.sql`](sql/02_load_and_clean.sql)): drop cancellations, returns, non-product codes, and 33k duplicate rows → 1,003,210 clean lines. Removal counts are printed by the script.
3. **Analyze** — one question per file:
   - [`03_revenue_and_orders_trend.sql`](sql/03_revenue_and_orders_trend.sql) — monthly trend (running total, MoM growth)
   - [`04_cohort_retention.sql`](sql/04_cohort_retention.sql) — monthly cohort retention matrix
   - [`05_rfm_segments.sql`](sql/05_rfm_segments.sql) — RFM segmentation with `NTILE(5)`
   - [`06_repeat_vs_onetime.sql`](sql/06_repeat_vs_onetime.sql) — repeat vs one-time, time to second order
   - [`07_revenue_concentration.sql`](sql/07_revenue_concentration.sql) — spend concentration (Pareto)
4. **Chart** from live query output ([`analysis/`](analysis)) → [`assets/`](assets).

MySQL 8.0 syntax, run on MySQL 9.7.1. Charts in Python (pandas + matplotlib).

## Key findings

Holiday cohorts churn to 8–13%; the rest hold better. (The Dec 2009 top row is
inflated by left-censoring — see caveats.)

![Cohort retention](assets/cohort_retention_heatmap.png)

Two segments hold 85% of revenue; **At Risk** — lapsed repeat buyers — is the leak.

![RFM segments](assets/rfm_segments.png)

Full writeup, the other two charts, caveats, and the recommendation: [`findings.md`](findings.md).

## Caveats (short version)
22.8% of lines have no customer ID and are excluded from customer-level work. The
retailer is wholesale-heavy, so revenue is long-tailed. Data is observational, one
retailer, 2009–2011 — associations, not causal effects. Full list in
[`findings.md`](findings.md#caveats-and-limitations).

## Reproduce
```bash
# from the repo root, with the venv active and db.local.cnf in place
python online-retail-cohorts/data/convert_xlsx_to_csv.py
mysql --defaults-extra-file=db.local.cnf < online-retail-cohorts/sql/01_schema.sql
python online-retail-cohorts/data/load_to_mysql.py
mysql --defaults-extra-file=db.local.cnf < online-retail-cohorts/sql/02_load_and_clean.sql
for f in online-retail-cohorts/analysis/plot_*.py; do python "$f"; done
```
