-- Q: Does conversion move with the calendar (holiday season, special days)?
-- Conversion rate per month, ordered by the normalized month number. Jan and Apr are
-- absent from the data, so the series has gaps. SpecialDay is averaged in to show
-- proximity to holidays alongside the rate.

SELECT
  month_txt                          AS month,
  month_num,
  COUNT(*)                           AS sessions,
  SUM(revenue)                       AS conversions,
  ROUND(100 * AVG(revenue), 2)       AS conversion_pct,
  ROUND(AVG(special_day), 3)         AS avg_special_day
FROM sessions
GROUP BY month_txt, month_num
ORDER BY month_num;
