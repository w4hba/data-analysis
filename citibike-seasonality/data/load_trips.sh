#!/usr/bin/env bash
# Bulk-load the Citi Bike CSVs into trips_stg with LOAD DATA LOCAL INFILE.
# Requires: sql/01_schema.sql already run, local_infile=1 on the server
# (SET PERSIST local_infile=1), and db.local.cnf at the repo root.
#
# Each month ships as several CSVs; every file has its own header (IGNORE 1 LINES).
# Only 6 of the 13 columns are kept — the rest map to throwaway @variables. Empty
# strings become NULL; a trailing CR from Windows line endings is trimmed off the
# last field so the member_casual ENUM matches on the clean side.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
CNF="$ROOT/db.local.cnf"
RAW="$HERE/raw"

shopt -s nullglob
files=("$RAW"/2024*-citibike-tripdata*.csv)
if [ ${#files[@]} -eq 0 ]; then
  echo "No CSVs in $RAW — download and unzip first (see data/README.md)." >&2
  exit 1
fi

mysql --defaults-extra-file="$CNF" --local-infile=1 -e "TRUNCATE TABLE trips_stg;"

for f in "${files[@]}"; do
  echo "loading $(basename "$f") ..."
  mysql --defaults-extra-file="$CNF" --local-infile=1 -e "
    LOAD DATA LOCAL INFILE '$f' INTO TABLE trips_stg
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
    LINES TERMINATED BY '\n' IGNORE 1 LINES
    (@ride_id,@rideable,@started,@ended,@ssn,@ssid,@esn,@esid,@slat,@slng,@elat,@elng,@mc)
    SET rideable_type      = @rideable,
        started_at         = NULLIF(@started, ''),
        ended_at           = NULLIF(@ended, ''),
        start_station_name = NULLIF(@ssn, ''),
        start_station_id   = NULLIF(@ssid, ''),
        member_casual      = TRIM(TRAILING '\r' FROM @mc);"
done

n=$(mysql --defaults-extra-file="$CNF" -N -e "SELECT COUNT(*) FROM trips_stg;" 2>/dev/null)
echo "loaded $n rows into trips_stg"
