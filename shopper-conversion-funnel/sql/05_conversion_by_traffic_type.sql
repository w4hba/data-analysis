-- Q: Which traffic sources convert best and worst?
-- Ranked conversion rate per channel with a Wilson 95% CI. Only channels with at
-- least 100 sessions are shown — below that the rate is too noisy to rank. Traffic
-- types are anonymized integer codes, so this ranks channels without naming them.

WITH g AS (
  SELECT traffic_type,
         COUNT(*)     AS n,
         SUM(revenue) AS x,
         AVG(revenue) AS p
  FROM sessions
  GROUP BY traffic_type
  HAVING n >= 100
)
SELECT
  RANK() OVER (ORDER BY p DESC) AS conv_rank,
  traffic_type,
  n AS sessions,
  x AS conversions,
  ROUND(100 * p, 2) AS conversion_pct,
  ROUND(100 * (p + 3.8416/(2*n) - 1.96*SQRT((p*(1-p) + 3.8416/(4*n))/n)) / (1 + 3.8416/n), 2) AS ci_low_pct,
  ROUND(100 * (p + 3.8416/(2*n) + 1.96*SQRT((p*(1-p) + 3.8416/(4*n))/n)) / (1 + 3.8416/n), 2) AS ci_high_pct
FROM g
ORDER BY p DESC;
