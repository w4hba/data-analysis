-- Q: As sessions engage more deeply, how does conversion change?
-- Sessions split into three mutually exclusive engagement stages built from the
-- page-group counts (this is an engineered funnel on session aggregates, not a
-- per-user event trace). The windowed SUM gives each stage's share of all sessions.

WITH staged AS (
  SELECT
    CASE
      WHEN product_related = 0 THEN '1. No product views'
      WHEN page_values     = 0 THEN '2. Browsed, no page value'
      ELSE                          '3. Reached valued pages'
    END AS engagement_stage,
    revenue
  FROM sessions
)
SELECT
  engagement_stage,
  COUNT(*)                                             AS sessions,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct_of_sessions,
  SUM(revenue)                                         AS conversions,
  ROUND(100 * AVG(revenue), 1)                         AS conversion_rate_pct
FROM staged
GROUP BY engagement_stage
ORDER BY engagement_stage;
