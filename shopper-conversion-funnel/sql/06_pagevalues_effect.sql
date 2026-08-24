-- Q: How strongly does PageValues separate converting sessions from the rest?
-- PageValues is the average value of the pages a session visited (a Google Analytics
-- metric). Sessions with zero are one bucket; the rest are split into quartiles by
-- NTILE so the gradient is visible. NTILE runs only over the >0 rows, so the 78% of
-- sessions at exactly zero don't swamp the quartile cut points.

WITH positive AS (
  SELECT revenue, NTILE(4) OVER (ORDER BY page_values) AS q
  FROM sessions
  WHERE page_values > 0
),
labeled AS (
  SELECT 'PV = 0' AS pv_bucket, 0 AS ord, revenue FROM sessions WHERE page_values = 0
  UNION ALL
  SELECT CONCAT('PV > 0 · Q', q), q, revenue FROM positive
)
SELECT
  pv_bucket,
  COUNT(*)                     AS sessions,
  SUM(revenue)                 AS conversions,
  ROUND(100 * AVG(revenue), 2) AS conversion_pct
FROM labeled
GROUP BY pv_bucket, ord
ORDER BY ord;
