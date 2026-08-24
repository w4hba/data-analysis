-- NYC Citi Bike 2024 (4 seasonal months) — schema.
-- MySQL 8.0 syntax (verified on 9.7.1). Two tables:
--   trips_stg  raw rides loaded from CSV by data/load_trips.sh (LOAD DATA LOCAL INFILE)
--   trips      the clean analysis base, built by 02_load_and_clean.sql
--
-- Only the six columns the analysis needs are loaded; ride_id, end-station, and
-- lat/lng are skipped at load time to keep 12M rows lean. Timestamps carry
-- millisecond precision in the source, so DATETIME(3) preserves them verbatim.

DROP TABLE IF EXISTS trips_stg;
CREATE TABLE trips_stg (
  rideable_type      VARCHAR(20),
  started_at         DATETIME(3),
  ended_at           DATETIME(3),
  start_station_name VARCHAR(128),
  start_station_id   VARCHAR(20),
  member_casual      VARCHAR(12)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Clean base. The time-part columns are generated once here so every seasonality
-- query groups on the same definitions of hour, weekday, weekend, and month
-- rather than re-deriving them (and re-deriving them differently) each time.
DROP TABLE IF EXISTS trips;
CREATE TABLE trips (
  id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
  rideable_type      ENUM('classic_bike','electric_bike','docked_bike') NOT NULL,
  member_casual      ENUM('member','casual') NOT NULL,
  started_at         DATETIME(3) NOT NULL,
  ended_at           DATETIME(3) NOT NULL,
  start_station_name VARCHAR(128),
  start_station_id   VARCHAR(20),
  trip_minutes       DECIMAL(8,2) AS (TIMESTAMPDIFF(SECOND, started_at, ended_at) / 60) STORED,
  started_date       DATE    AS (DATE(started_at))            STORED,
  started_hour       TINYINT AS (HOUR(started_at))            STORED,
  weekday_num        TINYINT AS (WEEKDAY(started_at))         STORED,  -- 0=Mon .. 6=Sun
  is_weekend         TINYINT AS (WEEKDAY(started_at) >= 5)    STORED,
  month_num          TINYINT AS (MONTH(started_at))           STORED,
  KEY idx_started (started_at),
  KEY idx_date (started_date),
  KEY idx_member (member_casual),
  KEY idx_hour (started_hour),
  KEY idx_month (month_num),
  KEY idx_station (start_station_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
