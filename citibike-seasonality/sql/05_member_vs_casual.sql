-- Q: How do members and casual riders differ — volume, trip length, when they ride,
--    and what they ride?
-- The windowed SUM turns each group's count into a share of all rides in one pass.

SELECT
  member_casual,
  COUNT(*)                                                   AS rides,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)           AS pct_of_rides,
  ROUND(AVG(trip_minutes), 1)                                AS avg_trip_min,
  ROUND(100 * AVG(is_weekend), 1)                            AS pct_weekend_rides,
  ROUND(100 * AVG(rideable_type = 'electric_bike'), 1)       AS pct_electric
FROM trips
GROUP BY member_casual
ORDER BY rides DESC;
