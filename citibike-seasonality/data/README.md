# Data source — NYC Citi Bike 2024

## Source
- **Dataset:** Citi Bike System Data (trip histories)
- **Publisher:** Lyft / NYC Bike Share LLC (NYCBS), operating the NYC DOT bike-share program
- **Landing page:** https://citibikenyc.com/system-data
- **Files:** public S3 bucket, https://s3.amazonaws.com/tripdata/ (monthly zips from 2024 on)
- **License:** [NYCBS Data Use Policy](https://www.citibikenyc.com/data-sharing-policy). Grants a royalty-free, perpetual license to analyze and publish results for **non-commercial** purposes. It prohibits re-selling or re-hosting the raw data as a standalone dataset and prohibits re-identifying riders.

This repository is a non-commercial analysis portfolio. It does not redistribute the
raw data — `data/raw/` is gitignored, and only derived aggregates and code are
committed, which the policy permits. Attribution: data provided by Citi Bike / NYC
Bike Share.

## Scope: four representative months
Full-year 2024 is ~8.6 GB zipped (~40M rides). This project uses **four months, one
per season** — January, April, July, October 2024 (~2.9 GB, ~12M rides) — which keeps
the load feasible on a laptop while still showing the seasonal contrast (winter vs
summer ridership) and the full within-week and within-day demand patterns.

The consequence, stated plainly: seasonality here is read as a **four-season
comparison**, not a smooth twelve-month curve. Month-over-month values between, say,
February and March are not available. The daily, weekly, and hourly patterns are
complete within each of the four months.

## Schema
The 2024 files use Citi Bike's current 13-column format: `ride_id, rideable_type,
started_at, ended_at, start_station_name, start_station_id, end_station_name,
end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual`. Timestamps
carry millisecond precision.

This project loads six of the thirteen columns — `rideable_type, started_at,
ended_at, start_station_name, start_station_id, member_casual` — and skips ride_id,
the end station, and all lat/lng, which the seasonality and operational questions do
not use. Staying on 2024-only data also sidesteps the pre-2021 schema (which used
`tripduration`, `starttime`, `usertype`, `birth year`, `gender`); mixing the two
would require reconciling different column sets.

## Known data quality issues
- **Missing start stations** — dockless / e-bike pickups leave the station name and
  id blank. Kept (loaded as NULL); they only drop out of the station-level query.
- **Bad durations** — some rides have `ended_at <= started_at`, and a small number
  run longer than 24 hours (undocked or lost bikes, not real trips). Both are removed.
- **Sub-minute trips** — real short hops and re-docks; these are kept.
- **Multiple files per month** — busy months split across several CSVs, each with its
  own header row. The loader ignores the header of every file.

Measured counts for each of these are printed by `sql/02_load_and_clean.sql` and
recorded below after the load.

## Reproduction
```bash
# 1. download the four monthly zips into data/raw/ and unzip
cd citibike-seasonality/data/raw
for m in 01 04 07 10; do
  curl -sSL -O "https://s3.amazonaws.com/tripdata/2024${m}-citibike-tripdata.zip"
  unzip -o "2024${m}-citibike-tripdata.zip"
done

# 2. schema, bulk load, clean (needs local_infile=1 on the server)
mysql --defaults-extra-file=../../../db.local.cnf < ../../sql/01_schema.sql
bash ../load_trips.sh
mysql --defaults-extra-file=../../../db.local.cnf < ../../sql/02_load_and_clean.sql
```
