-- Q: Once a customer makes a first purchase in month X, what share come back in
--    each later month? Monthly acquisition cohorts by months-since-first-order.
--
-- Guest (NULL customer) rows are dropped here: retention needs a customer to follow.
-- month_offset 0 is the acquisition month and is 100% by construction; the decay
-- after it is the signal. Output is long-format (one row per cohort x offset);
-- analysis/plot_cohort_retention.py pivots it into the heatmap.

WITH first_purchase AS (
  SELECT customer_id, MIN(invoice_month) AS cohort_month
  FROM retail_clean
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(*) AS cohort_size
  FROM first_purchase
  GROUP BY cohort_month
),
customer_activity AS (             -- distinct months each customer was active
  SELECT DISTINCT
    rc.customer_id,
    fp.cohort_month,
    TIMESTAMPDIFF(MONTH, fp.cohort_month, rc.invoice_month) AS month_offset
  FROM retail_clean rc
  JOIN first_purchase fp ON fp.customer_id = rc.customer_id
)
SELECT
  ca.cohort_month,
  cs.cohort_size,
  ca.month_offset,
  COUNT(DISTINCT ca.customer_id)                              AS active_customers,
  ROUND(100 * COUNT(DISTINCT ca.customer_id) / cs.cohort_size, 1) AS retention_pct
FROM customer_activity ca
JOIN cohort_sizes cs ON cs.cohort_month = ca.cohort_month
GROUP BY ca.cohort_month, cs.cohort_size, ca.month_offset
ORDER BY ca.cohort_month, ca.month_offset;
