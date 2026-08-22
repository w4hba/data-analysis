-- Q: If we score every customer on Recency, Frequency, and Monetary value, which
--    segments hold the revenue, and which are slipping away?
--
-- NTILE(5) is the natural tool: it splits customers into equal fifths on each axis
-- in one pass, no manual thresholds. Recency is ordered DESC so the most recent
-- buyers land in tile 5 (fewer days = better), matching frequency and monetary where
-- higher is better. Snapshot = the day after the last transaction in the data.
-- Guests (NULL customer) are excluded: RFM needs an identifiable customer.

WITH customer AS (
  SELECT
    customer_id,
    DATEDIFF(
      (SELECT DATE_ADD(MAX(invoice_ts), INTERVAL 1 DAY) FROM retail_clean),
      MAX(invoice_ts)
    )                          AS recency_days,
    COUNT(DISTINCT invoice)    AS frequency,
    SUM(line_revenue)          AS monetary
  FROM retail_clean
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id
),
scored AS (
  SELECT
    customer_id, recency_days, frequency, monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
  FROM customer
),
segmented AS (
  SELECT
    customer_id, recency_days, frequency, monetary, r_score, f_score, m_score,
    CASE
      WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
      WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
      WHEN r_score >= 4 AND f_score <= 2 THEN 'New / Promising'
      WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
      WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating'
      ELSE 'Others'
    END AS segment
  FROM scored
)
SELECT
  segment,
  COUNT(*)                                                    AS customers,
  ROUND(AVG(recency_days))                                    AS avg_recency_days,
  ROUND(AVG(frequency), 1)                                    AS avg_orders,
  ROUND(AVG(monetary), 2)                                     AS avg_revenue,
  ROUND(SUM(monetary), 2)                                     AS total_revenue,
  ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1)  AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
