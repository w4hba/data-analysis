-- Q: When during the week are bikes actually used, and does that timing differ
--    between members and casual riders?
-- Rides by rider type x weekday x hour — the grid behind the demand heatmap.
-- weekday_num is 0=Mon..6=Sun (MySQL WEEKDAY), so the rows already sort Mon->Sun.

SELECT
  member_casual,
  weekday_num,
  started_hour,
  COUNT(*) AS rides
FROM trips
GROUP BY member_casual, weekday_num, started_hour
ORDER BY member_casual, weekday_num, started_hour;
