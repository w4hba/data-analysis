-- Q: Which start stations carry the most demand, and are they commuter or leisure
--    stations (member- vs casual-heavy)?
-- RANK over ride volume; the casual share separates tourist/leisure docks from
-- commuter docks. Dockless pickups (null station) are excluded here only.

SELECT
  RANK() OVER (ORDER BY COUNT(*) DESC)             AS rnk,
  start_station_name,
  COUNT(*)                                          AS rides,
  ROUND(100 * AVG(member_casual = 'casual'), 1)    AS pct_casual,
  ROUND(AVG(trip_minutes), 1)                       AS avg_trip_min
FROM trips
WHERE start_station_name IS NOT NULL
GROUP BY start_station_name
ORDER BY rides DESC
LIMIT 15;
