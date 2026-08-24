# Operational demand and seasonality — NYC Citi Bike 2024

**Question:** How does bike-share demand move across seasons, weekdays, and hours, and
how do members differ from casual riders?

**Headline:** Demand is two overlapping products on one fleet. Members (80.8% of rides)
ride a weekday 8am/5pm commute; casual riders (19.2%) take longer weekend trips.
Ridership runs 2.7× higher in fall than winter, and the busiest docks are commuter
stations, with a few leisure exceptions near parks.

## Dataset
- **NYC Citi Bike system data**, [citibikenyc.com/system-data](https://citibikenyc.com/system-data), NYCBS Data Use Policy (non-commercial).
- Four representative months of 2024 (Jan/Apr/Jul/Oct), 14,972,591 clean rides.
- Source, license, scope rationale, and reproduction: [`data/README.md`](data/README.md).

## Approach
1. **Load** all monthly CSVs into a staging table with `LOAD DATA LOCAL INFILE` ([`data/load_trips.sh`](data/load_trips.sh)), keeping 6 of 13 columns.
2. **Clean** in SQL ([`sql/02_load_and_clean.sql`](sql/02_load_and_clean.sql)): drop over-24h and invalid rides, keep dockless NULL stations → 14.97M rows. Time-part columns are generated ([`sql/01_schema.sql`](sql/01_schema.sql)).
3. **Analyze** — one question per file:
   - [`03_seasonal_demand.sql`](sql/03_seasonal_demand.sql) — rides and rider mix by season
   - [`04_hourly_weekly_profile.sql`](sql/04_hourly_weekly_profile.sql) — weekday × hour demand by rider type
   - [`05_member_vs_casual.sql`](sql/05_member_vs_casual.sql) — behavioral comparison
   - [`06_daily_trend_rolling.sql`](sql/06_daily_trend_rolling.sql) — daily counts with a 7-day moving average
   - [`07_top_stations.sql`](sql/07_top_stations.sql) — busiest stations by volume, with casual share
4. **Chart** from live query output ([`analysis/`](analysis)) → [`assets/`](assets).

MySQL 8.0 syntax on MySQL 9.7.1. Charts in Python (pandas + matplotlib). Window
functions used for the moving average, peak-month share, ranking, and group shares.

## Key findings

Members commute on weekdays; casual riders ride weekend middays.

![Weekday x hour heatmap](assets/hourly_weekly_heatmap.png)

Ridership is 2.7× higher in the fall peak than in winter.

![Seasonal demand](assets/seasonal_demand.png)

Full writeup, the behavioral table, the other two charts, caveats, and the
recommendation: [`findings.md`](findings.md).

## Caveats (short version)
Four months, so seasonality is a four-season comparison, not a continuous curve. No
weather joined in. Counts are trip starts, so they understate demand where bikes run
out. Member/casual is a plan type, not a verified tourist/resident split. Full list in
[`findings.md`](findings.md#caveats-and-limitations).

## Reproduce
```bash
# from the repo root, venv active, db.local.cnf in place, local_infile=1 on the server
# (download+unzip the 4 months first — see data/README.md)
mysql --defaults-extra-file=db.local.cnf < citibike-seasonality/sql/01_schema.sql
bash citibike-seasonality/data/load_trips.sh
mysql --defaults-extra-file=db.local.cnf < citibike-seasonality/sql/02_load_and_clean.sql
for f in citibike-seasonality/analysis/plot_*.py; do python "$f"; done
```
