# Data Analysis

Three SQL analytics projects on real public datasets, each answering a business
question end to end: raw data, a MySQL schema, a documented cleaning step, analysis
queries, charts built from live query output, and a written findings report.

I work from a question, not from the data. I load the real file with its warts, clean
it in SQL where the logic stays readable, and write each query to answer one specific
thing. I quantify what I drop and why, put a confidence interval on a rate before I
compare it, and caveat every finding, including the parts that undercut the headline.
A result that didn't hold is written up as such.

**Stack:** MySQL 8.0 syntax (run on MySQL 9.7.1) · Python (pandas, matplotlib) for
charts · window functions, CTEs, and aggregate SQL throughout.

## The projects

| Project | Question | Headline finding |
|---|---|---|
| [Online Retail cohorts](online-retail-cohorts) | Which customers and cohorts drive lasting revenue, and where is the retention leak? | Repeat buyers are 72% of customers but **96.7% of revenue**; 711 lapsed high-value customers worth £1.5M are the clearest re-engagement target. |
| [Citi Bike seasonality](citibike-seasonality) | How does bike-share demand vary by season, day, and hour, and how do members differ from casual riders? | Members (81%) ride a weekday commute; casual riders take longer weekend trips. Fall ridership is **2.7× winter**. |
| [Shopper conversion funnel](shopper-conversion-funnel) | Where do e-commerce sessions convert, and which visitors and channels convert best? | Reaching a page with value splits a session between **4% and 56%** conversion. New visitors convert nearly 2× returning ones. |

### Online Retail cohorts (retention, RFM, and revenue concentration)
12-month acquisition cohorts on 1.07M UK online-retail transactions (UCI Online Retail II).

![Cohort retention](online-retail-cohorts/assets/cohort_retention_heatmap.png)

### Citi Bike seasonality (operational time-series on 15M rides)
Weekday-by-hour demand for 14.97M NYC Citi Bike trips, members vs casual riders.

![Citi Bike demand](citibike-seasonality/assets/hourly_weekly_heatmap.png)

### Shopper conversion funnel (segment comparison with confidence intervals)
Conversion by traffic source across 12,330 sessions, with Wilson 95% intervals (UCI).

![Conversion by traffic source](shopper-conversion-funnel/assets/traffic_type_ci.png)

## Repository layout
```
online-retail-cohorts/    citibike-seasonality/    shopper-conversion-funnel/
  README.md   findings.md
  data/       source docs + loading scripts (raw data gitignored)
  sql/        01_schema → 02_load_and_clean → 03..07 (one question per file)
  analysis/   Python scripts that build the charts
  assets/     exported charts
db.py  chartstyle.py           shared DB connection and chart styling
requirements.txt  LICENSE  .gitignore
```

## Running it yourself
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# a local MySQL 8.0+ instance; create a database and user, then point a
# gitignored db.local.cnf ([client] section) at it, see each project's README
```
Each project's README lists the exact download, load, and chart steps. Raw data is not
committed; the loaders reproduce it from the documented sources.

## Author
[PLACEHOLDER, your name] · [PLACEHOLDER, email / LinkedIn / portfolio link]

Code is MIT licensed ([LICENSE](LICENSE)). Each dataset keeps its own license, cited in
the project's `data/README.md`.
