-- Citi Bike — clean trips_stg into the analysis base `trips`.
-- Run after data/load_trips.sh has populated trips_stg.
--
-- Cleaning removes rides that would distort time or duration analysis: missing
-- timestamps, non-positive durations (end <= start), and rides longer than 24h
-- (almost all undocked/lost bikes, not real trips). Sub-minute trips are KEPT —
-- they are real short e-bike hops, not errors. Null start stations (dockless
-- pickups) are kept too; they only drop out of the station-level query.

TRUNCATE TABLE trips;

INSERT INTO trips
  (rideable_type, member_casual, started_at, ended_at, start_station_name, start_station_id)
SELECT
  rideable_type, member_casual, started_at, ended_at, start_station_name, start_station_id
FROM trips_stg
WHERE started_at IS NOT NULL
  AND ended_at   IS NOT NULL
  AND ended_at > started_at                                   -- drop zero/negative durations
  AND TIMESTAMPDIFF(SECOND, started_at, ended_at) <= 86400    -- drop trips over 24h
  AND member_casual IN ('member', 'casual')
  AND rideable_type IN ('classic_bike', 'electric_bike', 'docked_bike')
  AND YEAR(started_at) = 2024
  AND MONTH(started_at) IN (1, 4, 7, 10);

-- Cleaning summary.
SELECT 'raw staging rows'          AS step, COUNT(*) AS rows_ FROM trips_stg
UNION ALL SELECT 'null timestamp',        COUNT(*) FROM trips_stg WHERE started_at IS NULL OR ended_at IS NULL
UNION ALL SELECT 'non-positive duration', COUNT(*) FROM trips_stg WHERE ended_at <= started_at
UNION ALL SELECT 'over 24h',              COUNT(*) FROM trips_stg WHERE ended_at > started_at AND TIMESTAMPDIFF(SECOND, started_at, ended_at) > 86400
UNION ALL SELECT 'clean rows kept',       COUNT(*) FROM trips
UNION ALL SELECT '  null start station',  COUNT(*) FROM trips WHERE start_station_id IS NULL;

-- trips_stg can be dropped once trips is built, to reclaim space:
--   DROP TABLE trips_stg;
