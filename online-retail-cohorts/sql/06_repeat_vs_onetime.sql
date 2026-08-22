-- Q: How much of the business rests on repeat buyers versus one-time buyers, and
--    when repeat buyers come back, how long does the second order take?
--
-- Orders are collapsed to one row per customer-invoice, then ROW_NUMBER orders them
-- per customer so the 1st and 2nd order timestamps can be picked out and differenced.
-- Guests excluded (need a customer to judge repeat behavior).

WITH orders AS (
  SELECT customer_id, invoice,
         MIN(invoice_ts)   AS order_ts,
         SUM(line_revenue) AS order_revenue
  FROM retail_clean
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id, invoice
),
sequenced AS (
  SELECT customer_id, order_ts, order_revenue,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_ts) AS order_seq
  FROM orders
),
per_customer AS (
  SELECT
    customer_id,
    COUNT(*)                                        AS n_orders,
    SUM(order_revenue)                              AS monetary,
    MAX(CASE WHEN order_seq = 1 THEN order_ts END)  AS first_ts,
    MAX(CASE WHEN order_seq = 2 THEN order_ts END)  AS second_ts
  FROM sequenced
  GROUP BY customer_id
)
SELECT
  CASE WHEN n_orders = 1 THEN 'one-time' ELSE 'repeat' END      AS customer_type,
  COUNT(*)                                                      AS customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS pct_customers,
  ROUND(SUM(monetary), 2)                                       AS revenue,
  ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1)    AS revenue_share_pct,
  ROUND(AVG(DATEDIFF(second_ts, first_ts)))                     AS avg_days_to_2nd_order
FROM per_customer
GROUP BY customer_type
ORDER BY customer_type;
