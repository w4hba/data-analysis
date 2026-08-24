-- Q: Within each season, how does daily ridership move, and what does the weekly
--    rhythm look like once smoothed?
-- A 7-day moving average over daily counts. The frame is PARTITIONed by month so the
-- window never bridges the gaps between the four sampled months (Jan->Apr etc.);
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW is a trailing 7-day mean.

WITH daily AS (
  SELECT month_num, started_date, COUNT(*) AS rides
  FROM trips
  GROUP BY month_num, started_date
)
SELECT
  started_date,
  month_num,
  rides,
  ROUND(AVG(rides) OVER (PARTITION BY month_num ORDER BY started_date
                         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS rides_7day_avg
FROM daily
ORDER BY started_date;
