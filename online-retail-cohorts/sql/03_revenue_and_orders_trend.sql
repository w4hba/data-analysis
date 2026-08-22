-- Q: How did revenue, orders, and the active customer base move month to month?
-- Establishes the baseline the cohort and RFM work sits on top of.
-- LAG gives month-over-month growth; the windowed SUM gives the cumulative curve —
-- both read from one pass rather than a self-join per month.

WITH monthly AS (
  SELECT
    invoice_month                    AS month,
    COUNT(DISTINCT invoice)          AS orders,
    COUNT(DISTINCT customer_id)      AS active_customers,   -- COUNT DISTINCT ignores guest (NULL) rows
    SUM(line_revenue)                AS revenue
  FROM retail_clean
  GROUP BY invoice_month
)
SELECT
  month,
  orders,
  active_customers,
  ROUND(revenue, 2)                                              AS revenue,
  ROUND(SUM(revenue) OVER (ORDER BY month), 2)                   AS revenue_cumulative,
  ROUND(100 * (revenue / LAG(revenue) OVER (ORDER BY month) - 1), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;
