-- Q: How much does ridership swing across the seasons, and does the rider mix
--    change with it?
-- One row per sampled month. The windowed MAX gives each month as a share of the
-- busiest month, so the seasonal swing reads directly.

SELECT
  month_num,
  CASE month_num WHEN 1 THEN 'Jan (winter)' WHEN 4  THEN 'Apr (spring)'
                 WHEN 7 THEN 'Jul (summer)' WHEN 10 THEN 'Oct (fall)' END AS season,
  COUNT(*)                                                    AS rides,
  ROUND(100 * COUNT(*) / MAX(COUNT(*)) OVER (), 0)            AS pct_of_peak_month,
  ROUND(100 * AVG(member_casual = 'casual'), 1)              AS pct_casual,
  ROUND(AVG(trip_minutes), 1)                                AS avg_trip_min,
  ROUND(100 * AVG(rideable_type = 'electric_bike'), 1)       AS pct_electric
FROM trips
GROUP BY month_num
ORDER BY month_num;
