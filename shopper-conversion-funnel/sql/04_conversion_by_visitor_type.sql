-- Q: Do new and returning visitors convert at different rates, and is the gap real
--    or just sampling noise?
-- Point conversion rate plus a Wilson 95% confidence interval. Wilson (not the naive
-- normal interval) because conversion is a proportion and some groups are small, where
-- the naive interval misbehaves near 0/1. z = 1.96, z^2 = 3.8416. Non-overlapping
-- intervals flag a difference that is unlikely to be chance.

WITH g AS (
  SELECT visitor_type,
         COUNT(*)     AS n,
         SUM(revenue) AS x,
         AVG(revenue) AS p
  FROM sessions
  GROUP BY visitor_type
)
SELECT
  visitor_type,
  n AS sessions,
  x AS conversions,
  ROUND(100 * p, 2) AS conversion_pct,
  ROUND(100 * (p + 3.8416/(2*n) - 1.96*SQRT((p*(1-p) + 3.8416/(4*n))/n)) / (1 + 3.8416/n), 2) AS ci_low_pct,
  ROUND(100 * (p + 3.8416/(2*n) + 1.96*SQRT((p*(1-p) + 3.8416/(4*n))/n)) / (1 + 3.8416/n), 2) AS ci_high_pct
FROM g
ORDER BY p DESC;
