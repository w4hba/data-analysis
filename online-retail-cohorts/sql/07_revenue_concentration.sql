-- Q: How concentrated is revenue across the customer base? (Pareto view.)
--
-- Customers are ranked by lifetime spend and split into deciles; a running SUM over
-- the same descending order gives the cumulative share, so each row reads as
-- "the top N0% of customers account for this much revenue".

WITH customer AS (
  SELECT customer_id, SUM(line_revenue) AS monetary
  FROM retail_clean
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id
),
ranked AS (
  SELECT
    customer_id,
    monetary,
    NTILE(10) OVER (ORDER BY monetary DESC)                         AS spend_decile,
    SUM(monetary) OVER ()                                           AS total_revenue,
    SUM(monetary) OVER (ORDER BY monetary DESC
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
  FROM customer
)
SELECT
  spend_decile,                                     -- 1 = top spenders
  COUNT(*)                                                  AS customers,
  ROUND(SUM(monetary), 2)                                   AS revenue,
  ROUND(100 * SUM(monetary) / MAX(total_revenue), 1)        AS revenue_share_pct,
  ROUND(100 * MAX(running_revenue) / MAX(total_revenue), 1) AS cumulative_share_pct
FROM ranked
GROUP BY spend_decile
ORDER BY spend_decile;
